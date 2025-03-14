const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

var window: ?*sdl.struct_SDL_Window = null;
var renderer: ?*sdl.struct_SDL_Renderer = null;

pub fn start() void {
    // Init libs
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        std.debug.print("SDL_Init error: {s}\n", .{sdl.SDL_GetError()});
        @panic("Could not initialize SDL lib.");
    }

    if (sdl.TTF_Init() != 0) {
        std.debug.print("TTF_Init error: {s}\n", .{sdl.TTF_GetError()});
        @panic("Could not initialize TTF lib.");
    }

    // Init window
    const maybe_window = sdl.SDL_CreateWindow("ZIG!", sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, 800, 600, sdl.SDL_WINDOW_SHOWN);
    if (maybe_window == null) {
        std.debug.print("SDL_CreateWindow error: {s}\n", .{sdl.SDL_GetError()});
        @panic("Could not initialize GUI window.");
    }
    window = maybe_window;

    // Init renderer
    const maybe_renderer = sdl.SDL_CreateRenderer(window.?, -1, sdl.SDL_RENDERER_ACCELERATED);

    if (maybe_renderer) |r| {
        renderer = r;
    } else {
        std.debug.print("SDL_CreateRenderer error: {s}\n", .{sdl.SDL_GetError()});
        @panic("Could not initialize GUI window.");
    }

    // Render text
    const maybe_font = sdl.TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24);
    if (maybe_font == null) {
        std.debug.print("TTF_OpenFont error: {s}\n", .{sdl.TTF_GetError()});
        @panic("Could not initialize GUI font.");
    }
    const font = maybe_font.?;  // Since we are checking that it is not null above, we know "orelse unreachable"
    defer sdl.TTF_CloseFont(font);

    const white = sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    const surface = sdl.TTF_RenderText_Solid(font, "TESTEEEEEEEEEEEE", white);
    if (surface == null) {
        std.debug.print("TTF_RenderText_Solid error: {s}\n", .{sdl.TTF_GetError()});
    }
    defer sdl.SDL_FreeSurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
    if (texture == null) {
        std.debug.print("SDL_RenderCopy error: {s}\n", .{sdl.SDL_GetError()});
    }
    defer sdl.SDL_DestroyTexture(texture);

    const dst_rect = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 150, .h = 50 };

    const ret = sdl.SDL_RenderCopy(renderer, texture, null, &dst_rect);
    if (ret != 0) {
        std.debug.print("SDL_RenderCopy error: {s}\n", .{sdl.SDL_GetError()});
    }

    sdl.SDL_RenderPresent(renderer);
}

pub fn renderText(text: []const u8) void {
    var err = sdl.SDL_RenderClear(renderer);
    if (err != 0) {
        std.debug.print("SDL_RenderClear error: {s}\n", .{sdl.SDL_GetError()});
    }

    const maybe_font = sdl.TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24);
    if (maybe_font == null) {
        std.debug.print("TTF_OpenFont error: {s}\n", .{sdl.TTF_GetError()});
        @panic("Could not initialize GUI font.");
    }
    const font = maybe_font.?;  // Since we are checking that it is not null above, we know "orelse unreachable"
    defer sdl.TTF_CloseFont(font);

    const white = sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    const surface = sdl.TTF_RenderText_Solid(font, @ptrCast(text), white);
    if (surface == null) {
        std.debug.print("TTF_RenderText_Solid error: {s}\n", .{sdl.TTF_GetError()});
    }
    defer sdl.SDL_FreeSurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
    if (texture == null) {
        std.debug.print("SDL_RenderCopy error: {s}\n", .{sdl.SDL_GetError()});
    }
    defer sdl.SDL_DestroyTexture(texture);

    const dst_rect = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 150, .h = 50 };

    err = sdl.SDL_RenderCopy(renderer, texture, null, &dst_rect);
    if (err != 0) {
        std.debug.print("SDL_RenderCopy error: {s}\n", .{sdl.SDL_GetError()});
    }

    sdl.SDL_RenderPresent(renderer);
}

pub fn renderBitmap(filename: []const u8) void {
    const surface = sdl.SDL_LoadBMP_RW(sdl.SDL_RWFromFile(@ptrCast(filename), "rb"), 1);
    if (surface == null) {
        @panic("");
    }
    defer sdl.SDL_FreeSurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
    defer sdl.SDL_DestroyTexture(texture);
    // check err

    _ = sdl.SDL_RenderClear(renderer);
    _ = sdl.SDL_RenderCopy(renderer, texture, null, null);
    _ = sdl.SDL_RenderPresent(renderer);
    // check err
}

pub fn quit() void {
    const ren = renderer;
    renderer = null;
    const win = window;
    window = null;

    sdl.SDL_DestroyRenderer(ren);
    sdl.SDL_DestroyWindow(win);
    sdl.TTF_Quit();
    sdl.SDL_Quit();
}
