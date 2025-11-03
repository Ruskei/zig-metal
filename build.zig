const std = @import("std");

pub const Package = struct {
    module: *std.Build.Module,

    // pub fn link(pkg: Package, exe: *std.Build.Step.Compile) void {
    //     exe.addModule("zig-metal", pkg.module);
    // }
};

// pub fn package(b: *std.Build) Package {
//     const module = b.createModule(
//         .{
//             .root_source_file = b.path(thisDir() ++ "/src/main.zig"),
//         },
//     );
//
//     module.addImport("zigtrait", zigTraitModule(b));
//     return .{ .module = module };
// }

// pub fn zigTraitModule(b: *std.Build) *std.Build.Module {
//     return b.createModule(.{ .root_source_file = b.path(thisDir() ++ "/libs/zigtrait/src/zigtrait.zig") });
// }

pub fn addExample(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    comptime name: []const u8,
    comptime path: []const u8,
) void {
    const metal = b.addModule("zig-metal", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const trait = b.addModule("zigtrait", .{
        .root_source_file = b.path("libs/zigtrait/src/zigtrait.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });

    metal.addImport("zigtrait", trait);
    exe.root_module.addImport("zig-metal", metal);
    b.installArtifact(exe);

    exe.root_module.linkFramework("Foundation", .{});
    exe.root_module.linkFramework("Foundation", .{});
    exe.root_module.linkFramework("AppKit", .{});
    exe.root_module.linkFramework("Metal", .{});
    exe.root_module.linkFramework("MetalKit", .{});

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run-" ++ name, "Run the sample '" ++ name ++ "'");
    run_step.dependOn(&run_cmd.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    addExample(b, target, optimize, "window", "examples/01-window/main.zig");
    addExample(b, target, optimize, "primitive", "examples/02-primitive/main.zig");
    addExample(b, target, optimize, "argbuffers", "examples/03-argbuffers/main.zig");
    addExample(b, target, optimize, "animation", "examples/04-animation/main.zig");
    addExample(b, target, optimize, "instancing", "examples/05-instancing/main.zig");
    addExample(b, target, optimize, "perspective", "examples/06-perspective/main.zig");
    addExample(b, target, optimize, "lighting", "examples/07-lighting/main.zig");
    addExample(b, target, optimize, "texturing", "examples/08-texturing/main.zig");
    addExample(b, target, optimize, "compute", "examples/09-compute/main.zig");
    addExample(b, target, optimize, "compute-to-render", "examples/10-compute_to_render/main.zig");
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
