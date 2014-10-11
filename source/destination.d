module destination;

import sdlutil;
import resources;

class Destination {

    bool active = false;
    float x;
    float y;
    int size;

    this() {
    }

    this(float x, float y) {
        this.x = x;
        this.y = y;
    }

    void set_position(float x , int y) {
        if (x >= 0 && y >= 0) {
            this.x = x;
            this.y = y;
        }
    }

    ~this() {
    }
}
