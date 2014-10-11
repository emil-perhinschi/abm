module resources;


import derelict.sdl2.sdl;
import derelict.sdl2.image;
import core.thread;
import sdlutil;

class Resources {

    string base_path = "./";

    SDL_Texture *background;
    string background_path = "resource/background.png";

    SDL_Texture *live;
    string live_path = "resource/mob.png";

    SDL_Texture *dead;
    string dead_path;

    SDL_Texture *prey;
    string prey_path;

    SDL_Texture *destination;
    string destination_path;

    TTF_Font *score_font;
    string score_font_path;

    bool load_all(SDL_Renderer *renderer ) {
        Thread.sleep(dur!"seconds"(10));
        this.background = load_texture(this.base_path ~ this.background_path, this.renderer);
    }
}
