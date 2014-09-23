module app;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
// import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
// import derelict.sdl2.net;

import std.stdio;
import std.random;
import std.conv;
import std.string;

import sdlutil;
import destination;
import unit;
import movement;

class App {

    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Color score_color = { 0, 255, 0 };
    float score;
    TTF_Font *score_font;

    uint time;
    int clicks;
    bool give_up_and_quit = false;
    bool units_all_dead;
    int height;
    int width;
    int background_tile_size;

    string base_path; // where to look for resources
    int app_speed; // how fast to render

    SDL_Texture *background;
//    SDL_Texture *destination_texture;
//    SDL_Texture *mouse_texture;

    Destination destination;
    Unit[7] units;

    this(int width, int height, int tile_size, string base_path){
        this.width = width;
        this.height = height;
        this.background_tile_size = tile_size;
        this.base_path = base_path;
        this();
    }

    this() {
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        DerelictSDL2ttf.load();
        TTF_Init();

        if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
            log_SDL_error("SDL_Init Error");
            this.give_up_and_quit = true;
        }

        if ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) != IMG_INIT_PNG){
            log_SDL_error("IMG_Init");
            this.give_up_and_quit = true;
        }

        this.window = SDL_CreateWindow("Hello World!", 100, 100, this.width, this.height, SDL_WINDOW_SHOWN);
        if (this.window == null){
            log_SDL_error( "SDL_CreateWindow");
            this.give_up_and_quit = true;
        }

        this.renderer = SDL_CreateRenderer(this.window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        if (this.renderer == null ){
            log_SDL_error("SDL_CreateRenderer");
            this.give_up_and_quit = true;
        }
    }

    ~this() {
        this.destination.destroy();

        for (int i = 0; i < this.units.length; i++) {
            this.units[i].destroy();
        }
        TTF_CloseFont(score_font);
        SDL_DestroyTexture(this.background);
        SDL_DestroyWindow(this.window);
        IMG_Quit();
        SDL_Quit();
    }

    void set_background(string file_path) {
        writeln(this.base_path ~ file_path);
        SDL_Texture *background = load_texture(
            this.base_path ~ file_path,
            this.renderer
        );
        this.background = background;
        if (background == null ){
            writeln("background is null");
            this.give_up_and_quit = true;
        }
    }

    void set_destination(string file_path) {
        SDL_Texture *destination = load_texture(this.base_path ~ file_path, this.renderer);
        if (destination == null ){
            this.give_up_and_quit = true;
        } else {
            this.destination = new Destination(destination);
        }
    }

    void load_units(int how_many) {
        SDL_Texture *live_texture = sdlutil.load_texture(
            this.base_path ~ "source/mob.png",
            this.renderer
        );

        SDL_Texture *dead_texture = sdlutil.load_texture(
            this.base_path ~ "source/mob_dead.png",
            this.renderer
        );

        for (int i = 0; i < how_many; i++) {
            float x = uniform(5, this.width  - 5);
            float y = uniform(5, this.height - 5);
            this.units[i] = new Unit(live_texture, dead_texture);
            this.units[i].place_on_map(x,y);
        }
    }

    void render_units() {
        for (int i = 0; i < this.units.length; i++) {
            if (this.units[i] !is null) {
                if (this.units[i].is_dead) {
                    render_texture(
                        this.units[i].dead_texture,
                        this.renderer,
                        this.units[i].x,
                        this.units[i].y
                    );
                } else {
                    render_texture(
                        this.units[i].live_texture,
                        this.renderer,
                        this.units[i].x,
                        this.units[i].y
                    );
                }
            }
        }
    }

    void move_units() {
        writeln("moving units");
        int dead_units = 0;
        if (this.destination.active) {
            colision_check_center_distance();
            for (int i = 0; i < this.units.length; i++) {
                if (this.units[i].is_dead == true) {
                    dead_units++;
                    continue;
                }
                this.units[i].move(this.destination, &movement.move);
            }
        }
        this.score = dead_units;
        if (dead_units == this.units.length) {
            this.units_all_dead = true;
        }
    }

    void colision_check_center_coordinates() {
        int[string] occupied_spots;

        for (int i = 0; i < this.units.length; i++) {

            if (this.units[i] !is null) {
                if(this.units[i].is_dead == true) {
                    string dead_unit_position = to!string(this.units[i].x) ~ " " ~ to!string(this.units[i].y);
                    occupied_spots[dead_unit_position] = i;
                    continue;
                }

                this.units[i].move(this.destination, &movement.move);

                string test_key = to!string(this.units[i].x) ~ " " ~ to!string(this.units[i].y);

                if ( test_key in occupied_spots ) {
                    if ( this.units[occupied_spots[test_key]].is_dead == false) {
                        this.units[occupied_spots[test_key]].is_dead = true;
                    }
                    writeln( "units died !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " ~ to!string(occupied_spots[test_key]) ~ " and " ~ to!string(i) );
                    this.units[i].is_dead = true;
                } else {
                    occupied_spots[test_key] = i;
                }
            }

        }
    }

    void colision_check_center_distance() {
        for (int i = 0; i < this.units.length; i++) {
            Unit unit1 = this.units[i];
            if (unit1.is_dead == true) {
                continue;
            }
            for (int j = 0; j < this.units.length; j++) {
                if (i == j) {
                    continue;
                }

                Unit unit2 = this.units[j];
                float in_between = movement.check_for_colision_radius(unit1.x, unit1.y, unit1.radius, unit2.x, unit2.y, unit2.radius);
                if ( in_between == true ) {
                    unit1.is_dead = true;
                    unit2.is_dead = true;
                    writeln("!!!!!!!!!!!!!!!! colision " ~ to!string(in_between));
                }
            }
        }


        // compute the distance between all the units
        // if distance smaller than a threshold, set the two units as dead
        // needs a new property in Unit: size
    }

    void clear_scene() {
        SDL_RenderClear(this.renderer);
    }

    void render_scene() {
        this.render_background();
        this.render_destination();
        this.render_units();
        this.render_score();
    }

    void render_score() {
        this.score_font = TTF_OpenFont("/usr/share/fonts/truetype/msttcorefonts/arial.ttf", 25);
        string score_text = "Score: " ~ to!string(this.score);
        SDL_Surface* score_surface = TTF_RenderText_Solid( this.score_font, std.string.toStringz(score_text), score_color );

        if ( score_surface == null ) {
            writeln( "Unable to render text surface! SDL_ttf Error: " ~ to!string(TTF_GetError()) );
        } else {
            SDL_Texture* score_texture = SDL_CreateTextureFromSurface( this.renderer, score_surface );
            if( score_texture == null ) {
                log_SDL_error( "Unable to create texture from rendered text! SDL Error: ");
            } else {
                SDL_FreeSurface( score_surface );
                render_texture(score_texture, this.renderer, 3, 3);
            }
        }
    }

    void render_background() {
        sdlutil.render_background(
            this.background,
            this.renderer,
            this.width, this.height, this.background_tile_size);
    }

    void render_destination() {
        if (this.destination.active) {
            sdlutil.render_texture(
                this.destination.texture,
                this.renderer,
                this.destination.x -5, this.destination.y - 5
            );
        }
    }

    void handle_events() {
        SDL_Event e;
        SDL_Delay(50);
        while (SDL_PollEvent(&e)){
            if( e.type == SDL_QUIT ) {
                this.give_up_and_quit = true;
            } else if ( e.type == SDL_MOUSEBUTTONDOWN ) {
                writeln("mouse is down");
                int x, y;
                if (SDL_GetMouseState(&x, &y) & SDL_BUTTON(SDL_BUTTON_LEFT)) {
                    this.destination.active = true;
                    this.destination.set_position(x,y);
                }
            }
        }
    }

    void draw_all() {
        SDL_RenderPresent(this.renderer);
    }
}

