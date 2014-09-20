module unit;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import movement;
import sdlutil;
import destination;

class Unit {

    float x;
    float y;
    string name;
    string sprite_file;
    SDL_Texture *texture;
    float speed;

    this(SDL_Texture *texture) {
        this.texture = texture;
    }

    ~this() {
        destroy_texture(this.texture);
    }

    void move(Destination destination) {
        if (destination.active) {
            this.x = movement.move(this.x, destination.x, this.speed);
            this.y = movement.move(this.y, destination.y, this.speed);
        }
    }



}

