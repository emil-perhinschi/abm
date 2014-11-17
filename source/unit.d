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

    SDL_Texture *live_texture;
    SDL_Texture *dead_texture;
    float speed = 1;
    bool is_dead = false;

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

    void move(Destination destination, Mover move) {
        if (destination.active) {
			std.stdio.writeln(this.x, " ", this.y);
			float old_x = this.x;
			float old_y = this.y;	
            Position new_position = move_one_unit(this.speed, this.x, this.y, destination.x, destination.y);
            this.x = new_position.x;
            this.y = new_position.y;
			
			// TODO send movement.move as a callback to allow different strategies
            // this.x = move(this.x, destination.x, this.speed);
            // this.y = move(this.y, destination.y, this.speed);
        }
    }
}

