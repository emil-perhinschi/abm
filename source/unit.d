module unit;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import movement;
import sdlutil;
import destination;

class Unit {

    string type;
    float x;
    float y;
    float radius = 5; // how large is the unit assuming it is a circle

    float speed = 1;
    bool is_dead = false;

    SDL_Texture *live_texture;
    SDL_Texture *dead_texture;
    
    this(string type, SDL_Texture *live_texture, SDL_Texture *dead_texture) {
        this.type = type;
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

    void move(Destination destination, Mover mover) {
        if (destination.active) {
			// std.stdio.writeln(this.x, " ", this.y);	
            Position new_position = mover(this.speed, this.x, -1 * this.y, destination.x, -1 * destination.y);
            // debug std.stdio.writeln(new_position);
            this.x = new_position.x;
            this.y = -1 * new_position.y;
			// debug std.stdio.writeln(this);
			// TODO send movement.move as a callback to allow different strategies
            // this.x = movement.move(this.x, destination.x, this.speed);
            // this.y = movement.move(this.y, destination.y, this.speed);
        }
    }
}

