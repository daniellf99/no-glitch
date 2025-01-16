const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("main.zig"),
        .target = b.host,
    });

    exe.addIncludePath(b.path("./include"));
    exe.addLibraryPath(b.path("./lib"));
    exe.linkSystemLibrary("libretro");
    exe.linkLibCpp();

    b.installArtifact(exe);
}
