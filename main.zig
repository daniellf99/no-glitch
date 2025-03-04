// Objective - Startup core (retro_init)
// We should first build the core with the shared lib
// Then, we should load the core as a dynlib
// After that we should call the retro_init fn from the core

const std = @import("std");
const builtin = @import("builtin");

// Import libretro.h
const libretro = @cImport({
    @cInclude("libretro.h");
});

const stdout = std.io.getStdOut().writer();

const RetroEnvironment = struct {
    support_no_game: bool = false,
    performance_level: c_uint = 0,
    pixel_format: libretro.retro_pixel_format = 0,
};

var env = RetroEnvironment{};
var system_info = libretro.retro_system_info{};
var system_av_info = libretro.retro_system_av_info{};

export fn environment_cb(cmd: c_uint, data: ?*anyopaque) bool {
    switch (cmd) {
        libretro.RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME => {
            const num: *bool = @ptrCast(data);
            env.support_no_game = num.*;
        },
        libretro.RETRO_ENVIRONMENT_SET_PERFORMANCE_LEVEL => {
            const ptr: *c_uint = @ptrCast(@alignCast(data));
            env.performance_level = ptr.*;
        },
        libretro.RETRO_ENVIRONMENT_SET_PIXEL_FORMAT => {
            const ptr: *libretro.retro_pixel_format = @ptrCast(@alignCast(data));
            env.pixel_format = ptr.*;
        },
        else => {
            stdout.writeAll("Env behavior not implemented\n") catch unreachable;
        },
    }

    const a = libretro.retro_core_option_v2_category{};
    std.debug.print("Struct: {}\n", .{a});

    std.debug.print("Env: {}\n", .{env});

    return true;
}

fn debug_system_info() void {
    std.debug.print("==DEBUG SYSTEM INFO==\n", .{});
    const lib_name: [*:0]const u8 = system_info.library_name;
    std.debug.print("Lib name: {s}\n", .{lib_name});
    const lib_version: [*:0]const u8 = system_info.library_version;
    std.debug.print("Lib version: {s}\n", .{lib_version});
    const valid_extensions: [*:0]const u8 = system_info.valid_extensions;
    std.debug.print("Valid ext: {s}\n", .{valid_extensions});
    const need_fullpath = system_info.need_fullpath;
    std.debug.print("Need fullpath: {}\n", .{need_fullpath});
    const block_extract = system_info.block_extract;
    std.debug.print("Block extract: {}\n", .{block_extract});
}

fn debug_system_av_info() void {
    std.debug.print("==DEBUG SYSTEM AV INFO==\n", .{});
    std.debug.print("Geometry: {}\n", .{system_av_info.geometry});
    std.debug.print("Timing: {}\n", .{system_av_info.timing});
}

pub fn main() !void {
    libretro.retro_set_environment(environment_cb);

    libretro.retro_get_system_info(&system_info);
    std.debug.print("\n", .{});
    debug_system_info();

    libretro.retro_get_system_av_info(&system_av_info);
    std.debug.print("\n", .{});
    debug_system_av_info();

    std.debug.print("\n", .{});
    libretro.retro_init();

    // Load game
    var file = try std.fs.cwd().openFile("roms/IBM Logo.ch8", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(buffer);

    _ = try file.readAll(buffer);
    std.debug.print("\n\nBuffer size: {}\n\n", .{file_size});

    var game_info = libretro.retro_game_info{
        .data = @ptrCast(buffer),
        .size = @intCast(file_size),
    };
    const game_loaded = libretro.retro_load_game(&game_info);

    if (!game_loaded) {
        std.debug.print("Emulator could not load game.", .{});
        std.process.exit(0);
    }

    // Run emulator
    // TODO Run according to FPS
    std.debug.print("\n", .{});
    libretro.retro_run();

    // TODO Display video
}
