module movement;

import std.stdio;

struct Position {
    float x;
    float y;
}


pure float move(float unit_position, float destination_position, float speed) {
    float new_position;
    float direction = compute_direction(destination_position, unit_position);
    float distance = std.math.abs(destination_position - unit_position);
    new_position = destination_position + direction * compute_speed(distance, speed);
    return new_position;
}

pure float compute_direction(float destination, float position) {
    float direction = 0;

    if (destination - position > 0) {
        direction = 1;
    } else if (destination - position < 0) {
        direction = -1;
    }
    return direction;
}

pure float compute_speed(float distance, float base_speed) {
    float speed;
    if (distance >= base_speed ) {
        speed = base_speed;
    } else if (distance > 0 && distance < base_speed ) {
        speed = 1;
    } else {
        speed = 0;
    }
    return speed;
}

/*
 * this module should have no clue about sdl, this has to be done some other way
Position follow_keyboard_arrows(SDL_Event e, Position mob_position) {
    switch( e.key.keysym.sym ) {
        case SDLK_UP:
            mob_position.y--;
            break;
        case SDLK_DOWN:
            mob_position.y++;
            break;
        case SDLK_LEFT:
            mob_position.x--;
            break;
        case SDLK_RIGHT:
            mob_position.x++;
            break;
        default:
            break;
    }
    return mob_position;
}
*/
