import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import core.thread;
import std.cstream;
import std.conv;

import app;
import unit;
import sdlutil;
import movement;

int main()
{
    int screen_width = 1024;
    int screen_height = 768;
    int tile_size = 40;

    App app = new App(
        screen_width,
        screen_height,
        tile_size,
        "/home/emilper/work/abm/");
    app.load_prey();
    app.load_units(7);
    writeln("after units");
    while (!app.give_up_and_quit){
        app.handle_events();
        if ( app.game_over != true) {
            app.move_units();
            app.clear_scene();
            app.render_scene();
        } else {
            app.render_game_over();
            writeln("rendered game over");
        }
        app.draw_all();
    }

    writeln("quit is true");
    app.destroy();
    return 0;
}

