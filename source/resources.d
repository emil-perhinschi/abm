module resources;


import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;


import core.thread;
import sdlutil;

class Resources {

    string base_path = "./";

    SDL_Texture *background;
    string background_path = "resource/background.png";

    SDL_Texture *live;
    string live_path = "resource/mob.png";

    SDL_Texture *dead;
    string dead_path = "resource/mob_dead.png";

    SDL_Texture *prey;
    string prey_path = "resource/prey.png";

    SDL_Texture *prey_dead;
    string prey_dead_path = "resource/prey_dead.png";

    SDL_Texture *destination;
    string destination_path = "resource/destination.png";

    TTF_Font *score_font;
    string score_font_path = "resource/times.ttf";

    this() {
    }

    ~this() {

        TTF_CloseFont(this.score_font);
        TTF_Quit();
        SDL_DestroyTexture(this.background);
    }

    bool load_all(SDL_Renderer *renderer ) {
        // Thread.sleep(dur!"seconds"(10));
        this.background = load_texture(this.base_path ~ this.background_path, renderer);
        this.live = load_texture(this.base_path ~ this.live_path, renderer);
        this.dead = load_texture(this.base_path ~ this.dead_path, renderer);
        this.prey = load_texture(this.base_path ~ this.prey_path, renderer);
        this.destination = load_texture(this.base_path ~ this.destination_path, renderer);

        TTF_Init();
        this.score_font = load_font(this.base_path ~ this.score_font_path, 25);
        return true; // TODO
    }
}
