module scene;

/*
 * this is the whole map, only a small part is shown in the scene
 */
class Map {
    int width = 100; // default width
    int height = 100; // default height
    int tile_size = 10;
    Place places[]; // fixed locations
}

class Place {
    int x;
    int y;

}

class Scene {

    int width;
    int height;

}
