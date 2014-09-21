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
    SDL_Texture *live_texture;
    SDL_Texture *dead_texture;
    float speed = 1;
    bool is_dead = false;

    this(SDL_Texture *live_texture, SDL_Texture *dead_texture) {
        this.live_texture = live_texture;
        this.dead_texture = dead_texture;
    }

    ~this() {
        destroy_texture(this.live_texture);
        destroy_texture(this.dead_texture);
    }

    bool place_on_map(float x, float y) {
        this.x = x;
        this.y = y;
        return true;
    }

    void move(Destination destination) {
        if (destination.active) {
            // TODO send movement.move as a callback to allow different strategies
            this.x = movement.move(this.x, destination.x, this.speed);
            this.y = movement.move(this.y, destination.y, this.speed);
        }
    }
}

