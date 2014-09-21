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
        "/home/emilper/mnt/little/work/abm/");
    app.set_background("source/background.png");
    app.set_destination("source/destination.png");
    app.load_units(7);

    while (!app.give_up_and_quit){
        app.handle_events();
        app.move_units();
        app.clear_scene();
        app.render_scene();
        app.draw_all();
    }

    writeln("quit is true");
    app.destroy();
    return 0;
}

void cleanup(SDL_Texture* tex) {
    SDL_DestroyTexture(tex);
}

void cleanup(SDL_Surface* surface) {
    SDL_FreeSurface(surface);
}

void cleanup(SDL_Renderer* ren) {
    SDL_DestroyRenderer(ren);
}

struct Position {
    float x;
    float y;
}

//    SDL_Texture *image = load_texture("/home/emilper/mnt/little/work/abm/source/mob.png", ren);
//    SDL_Texture *destination = load_texture("/home/emilper/mnt/little/work/abm/source/destination.png", ren);

/*
    int iW, iH;
    SDL_QueryTexture(image, null, null, &iW, &iH);
    int mx = screen_width / 2 - iW / 2;
    int my = screen_height / 2 - iH / 2;
    float speed = 3;

    Position mob_position = Position(mx, my );
    Position mouse_destination = Position(0,0);
*/

/*
writeln(
      "destination x:" ~ to!string(mouse_destination.x) ~ " y:" ~ to!string(mouse_destination.y)
    ~ " position x:" ~ to!string(mob_position.x) ~ " y:" ~ to!string(mob_position.y)
    ~ " distance x:" ~ to!string(distance_x) ~ " y:" ~ to!string(distance_y)
    ~ " speed x:" ~ to!string(speed_x) ~ " y:" ~ to!string(speed_y));
*/
