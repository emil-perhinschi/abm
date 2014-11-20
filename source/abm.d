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
    int screen_width = 800;
    int screen_height = 800;
    int tile_size = 40;
    int how_many_hunters = 1;

    App app = new App(
        screen_width,
        screen_height,
        tile_size,
        "/home/emilper/work/abm/");

    app.run(how_many_hunters);

    writeln("quit is true");
    app.destroy();
    return 0;
}


