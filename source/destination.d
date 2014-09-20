module destination;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import sdlutil;

class Destination {
    SDL_Texture *texture;
    bool active = false;
    float x;
    float y;
    int size;

    this(SDL_Texture *texture) {
        this.texture = texture;
    }

    void get_mouse_clicks(SDL_Event e) {

    }

    void set_position(float x , int y) {
        if (x >= 0 && y >= 0) {
            this.x = x;
            this.y = y;
        }
    }

    ~this() {
        destroy_texture(this.texture);
    }
}
