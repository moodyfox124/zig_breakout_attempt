const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const SCREEN_WIDTH = 640;
const SCREEN_HEIGHT = 400;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to init SDL: %s", c.SDL_GetError());
    }
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("breakout", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to init window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const ball_size = 50;

    const ball_speed = 1;

    var ball_x: i32 = 0;
    var ball_y: i32 = 0;

    var ball_velocity_x: i32 = 1;
    var ball_velocity_y: i32 = 1;

    var frame: usize = 0;
    mainloop: while (true) {
        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        _ = c.SDL_RenderClear(renderer);

        var rect = c.SDL_Rect{ .x = ball_x, .y = ball_y, .w = ball_size, .h = ball_size };

        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0, 0, 0xff);
        _ = c.SDL_RenderFillRect(renderer, &rect);

        var ball_new_x_pos = ball_x + ball_velocity_x * ball_speed;
        if (ball_new_x_pos < 0 or ball_new_x_pos + ball_size > SCREEN_WIDTH) {
            ball_velocity_x = -ball_velocity_x;
            ball_new_x_pos = ball_x + ball_velocity_x * ball_speed;
        }

        var ball_new_y_pos = ball_y + ball_velocity_y * ball_speed;
        if (ball_new_y_pos < 0 or ball_new_y_pos + ball_size > SCREEN_HEIGHT) {
            ball_velocity_y = -ball_velocity_y;
            ball_new_y_pos = ball_y + ball_velocity_y * ball_speed;
        }

        ball_x = ball_new_x_pos;
        ball_y = ball_new_y_pos;

        c.SDL_RenderPresent(renderer);
        frame += 1;
    }
}
