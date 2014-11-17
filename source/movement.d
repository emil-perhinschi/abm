module movement;

import std.stdio;
import std.math;
import std.conv;

struct Position {
    float x;
    float y;
}

alias Mover = float function(float, float, float);

pure float move(float unit_position, float destination_position, float speed) {
    float direction = compute_direction(destination_position, unit_position);
    float distance = std.math.abs(destination_position - unit_position);
    return unit_position + direction * compute_speed(distance, speed);
}

pure float compute_direction(float destination_position, float current_position) {
    float direction = 0;

    if (destination_position - current_position > 0) {
        direction = 1;
    } else if (destination_position - current_position < 0) {
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

pure bool check_for_colision_radius(float x1, float y1, float radius1, float x2, float y2, float radius2) {

    float distance = sqrt( (x1 - x2)^^2 + (y1 - y2)^^2);
    float in_between = distance - radius1 - radius2;
    bool is_colision = false;
    // writeln(" in between is " ~ to!string(in_between));
    if (in_between > 0 ) {
        is_colision = false;
    } else {
        is_colision = true;
    }
    return is_colision;
}


// returns radians
pure float compute_movement_angle(float x1, float x2, float y1, float y2) {
	return atan2( y2 - y1,  x2 - x1 );
}

pure Position move_one_unit(float speed, float x1, float y1, float x2, float y2) {
	// angle is in radians
	float angle = compute_movement_angle(x1, x2, y1, y2);

	float diff_x = std.math.sin(angle) * speed;
	float diff_y = std.math.cos(angle) * speed;
	Position new_position = { x : x1 + diff_x, y: y1 + diff_y };
	return new_position;
}

// http://www.cplusplus.com/forum/beginner/90710/
pure float degrees_to_radians(float degrees) {
	return (degrees * std.math.PI) / 180.0;
}

// http://www.cplusplus.com/forum/beginner/90710/
pure float radians_to_degrees(float radians) {
	return (180 * radians) / std.math.PI;
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
