module menu;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import std.stdio;
import std.string;
import std.conv;

import sdlutil;

class Widget {

    int width;
    int height;
    SDL_Texture* active;
    SDL_Texture* inactive;

    this() {
    }

    void on_click(SDL_Event e) {

    }
}

class Container : Widget {

    int padding = 1;
    int border_width = 1;
    int border_color[3] = [0, 0, 0];

    Widget children[];

    this() {}

}
