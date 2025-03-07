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
    const maybe_renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED);

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
    const surface = sdl.TTF_RenderText_Solid(font, "abc", white);
    defer sdl.SDL_FreeSurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface) orelse unreachable;
    const dst_rect = sdl.SDL_Rect{ .x = 50, .y = 50, .w = 150, .h = 50 };
    _ = sdl.SDL_RenderCopy(renderer, texture, null, &dst_rect);
}

pub fn quit() void {
    const ren = renderer;
    renderer = null;
    const win = window;
    window = null;

    sdl.SDL_DestroyRenderer(ren);
    sdl.SDL_DestroyWindow(win);
    sdl.SDL_Quit();
    sdl.TTF_Quit();
}
