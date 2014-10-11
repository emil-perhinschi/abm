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
    float score = 0.0;
    int clicks_count = 0;



    uint time;

    bool give_up_and_quit = false;
    bool hunters_all_dead;
    int height;
    int width;
    int background_tile_size;

    string base_path; // where to look for resources
    int app_speed; // how fast to render

    SDL_Texture *background;

    Destination destination;
    Hunter[7] hunters;
    Prey prey;

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

        TTF_Init();

        this.score_font = TTF_OpenFont("resource/times.ttf", 25);
    }

    ~this() {
        this.destination.destroy();

        for (int i = 0; i < this.hunters.length; i++) {
            this.hunters[i].destroy();
        }
        TTF_CloseFont(this.score_font);
        TTF_Quit();
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

    void load_hunters(int how_many) {
        SDL_Texture *live_texture = sdlutil.load_texture(
            this.base_path ~ "resource/mob.png",
            this.renderer
        );

        SDL_Texture *dead_texture = sdlutil.load_texture(
            this.base_path ~ "resource/mob_dead.png",
            this.renderer
        );

        for (int i = 0; i < how_many; i++) {
            float x = uniform(5, this.width  - 5);
            float y = uniform(5, this.height - 5);
            this.hunters[i] = new Unit(live_texture, dead_texture);
            this.hunters[i].place_on_map(x,y);
        }
    }


    void render_hunters() {
        for (int i = 0; i < this.hunters.length; i++) {
            if (this.hunters[i] !is null) {
                if (this.hunters[i].is_dead) {
                    render_texture(
                        this.hunters[i].dead_texture,
                        this.renderer,
                        this.hunters[i].x,
                        this.hunters[i].y
                    );
                } else {
                    render_texture(
                        this.hunters[i].live_texture,
                        this.renderer,
                        this.hunters[i].x,
                        this.hunters[i].y
                    );
                }
            }
        }
    }

    void move_hunters() {
        // writeln("moving hunters");
        int dead_hunters = 0;
        if (this.destination.active) {
            colision_check_center_distance();
            for (int i = 0; i < this.hunters.length; i++) {
                if (this.hunters[i].is_dead == true) {
                    dead_hunters++;
                    continue;
                }
                this.hunters[i].move(this.destination, &movement.move);
            }
        }
        if (this.clicks_count > 0) {
            this.score = dead_hunters/this.clicks_count;
        } else {
            this.score = dead_hunters;
        }
        if (dead_hunters == this.hunters.length) {
            this.hunters_all_dead = true;
        }
    }

    void colision_check_center_coordinates() {
        int[string] occupied_spots;

        for (int i = 0; i < this.hunters.length; i++) {

            if (this.hunters[i] !is null) {
                if(this.hunters[i].is_dead == true) {
                    string dead_unit_position = to!string(this.hunters[i].x) ~ " " ~ to!string(this.hunters[i].y);
                    occupied_spots[dead_unit_position] = i;
                    continue;
                }

                this.hunters[i].move(this.destination, &movement.move);

                string test_key = to!string(this.hunters[i].x) ~ " " ~ to!string(this.hunters[i].y);

                if ( test_key in occupied_spots ) {
                    if ( this.hunters[occupied_spots[test_key]].is_dead == false) {
                        this.hunters[occupied_spots[test_key]].is_dead = true;
                    }
                    writeln( "hunters died !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " ~ to!string(occupied_spots[test_key]) ~ " and " ~ to!string(i) );
                    this.hunters[i].is_dead = true;
                } else {
                    occupied_spots[test_key] = i;
                }
            }

        }
    }

    void colision_check_center_distance() {
        for (int i = 0; i < this.hunters.length; i++) {
            Unit unit1 = this.hunters[i];
            if (unit1.is_dead == true) {
                continue;
            }
            for (int j = 0; j < this.hunters.length; j++) {
                if (i == j) {
                    continue;
                }

                Unit unit2 = this.hunters[j];
                bool colided = movement.check_for_colision_radius(unit1.x, unit1.y, unit1.radius, unit2.x, unit2.y, unit2.radius);
                if ( colided == true ) {
                    unit1.is_dead = true;
                    unit2.is_dead = true;
                    writeln("!!!!!!!!!!!!!!!! colision " ~ to!string(colided));
                }
            }
        }


        // compute the distance between all the hunters
        // if distance smaller than a threshold, set the two hunters as dead
        // needs a new property in Unit: size
    }

    void clear_scene() {
        SDL_RenderClear(this.renderer);
    }

    void render_scene() {
        this.render_background();
        this.render_destination();
        this.render_hunters();
        this.render_score();
    }

    void render_score() {
        string score_text = format("Score: %.2f", this.score );
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
                    this.clicks_count++;
                }
            }
        }
    }

    void draw_all() {
        SDL_RenderPresent(this.renderer);
    }
}

