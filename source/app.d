module app;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
// import derelict.sdl2.mixer;
// import derelict.sdl2.ttf;
// import derelict.sdl2.net;

import std.stdio;

import sdlutil;
import destination;
import unit;
import movement;

class App {

    SDL_Window *window;
    SDL_Renderer *renderer;

    bool quit = false;

    int height;
    int width;
    int background_tile_size;

    string base_path; // where to look for resources
    int app_speed; // how fast to render

    SDL_Texture *background;
    SDL_Texture *destination_texture;
    SDL_Texture *mouse_texture;

    Destination destination;
    Unit[] units;

    this(int width, int height, int tile_size, string base_path){
        this.width = width;
        this.width = width;
        this.background_tile_size = tile_size;
        this.base_path = base_path;
        this();
    }

    this() {
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        bool init_failed = false;

        if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
            log_SDL_error("SDL_Init Error");
            this.quit = true;
        }

        if ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) != IMG_INIT_PNG){
            log_SDL_error("IMG_Init");
            this.quit = true;
        }

        this.window = SDL_CreateWindow("Hello World!", 100, 100, this.width, this.height, SDL_WINDOW_SHOWN);
        if (this.window == null){
            log_SDL_error( "SDL_CreateWindow");
            this.quit = true;
        }

        this.renderer = SDL_CreateRenderer(this.window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        if (this.renderer == null ){
            log_SDL_error("SDL_CreateRenderer");
            this.quit = true;
        }
    }

    ~this() {
        this.destination.destroy();

        for (int i = 0; i < this.units.length; i++) {
            this.units[i].destroy();
        }

        SDL_DestroyTexture(this.background);
        SDL_DestroyWindow(this.window);
        IMG_Quit();
        SDL_Quit();
    }

    void set_background(string file_path) {
        SDL_Texture *background = load_texture(this.base_path ~ file_path, this.renderer);
        if (background == null ){
            this.quit = true;
        }
    }

    void set_destination(string file_path) {
        SDL_Texture *destination = load_texture(this.base_path ~ file_path, this.renderer);
        if (destination == null ){
            this.quit = true;
        } else {
            this.destination = new Destination(destination);
        }
    }

    void move_units() {
        if (this.destination.active) {
            for (int i = 0; i < this.units.length; i++) {
                this.units[i].x = move(this.units[i].x, this.destination.x, this.units[i].speed);
                this.units[i].y = move(this.units[i].y, this.destination.y, this.units[i].speed);
            }
        }
    }

    void clear_scene() {
        SDL_RenderClear(this.renderer);
    }

    void render_scene() {
        this.render_background();
        this.render_destination();
        this.render_units();
    }

    void render_background() {
        sdlutil.render_background(
            this.background,
            this.renderer,
            this.width, this.height, this.background_tile_size);
    }

    void render_destination() {
        if (this.destination.active) {
            render_texture(this.destination.texture, this.renderer, this.destination.x, this.destination.y);
        }
    }

    void render_units() {
        for (int i = 0; i < this.units.length; i++) {
            render_texture(this.units[i].texture, this.renderer, this.units[i].x, this.units[i].y);
        }
    }

    void handle_events() {
        SDL_Event e;
        SDL_Delay(50);
        while (SDL_PollEvent(&e)){
            if( e.type == SDL_QUIT ) {
                quit = true;
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

