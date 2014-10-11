module sdlutil;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.file;
import std.stdio;

TTF_Font* load_font(string font_file_path, int font_size) {
    writeln(font_file_path);
    if(!exists(font_file_path) ) {
        throw new Exception("font path not found " ~ font_file_path);
    }
    return TTF_OpenFont(std.string.toStringz(font_file_path), 25);
}

SDL_Texture* load_texture(string file_path, SDL_Renderer *ren) {
    if (!exists(file_path)) {
        throw new Exception("file not found: " ~ file_path);
    }

    SDL_Texture *texture = IMG_LoadTexture(ren, std.string.toStringz(file_path));
    if (texture == null) {
        log_SDL_error("failed to load texture from " ~ file_path);
    }
    return texture;
}

void render_background(SDL_Texture* background, SDL_Renderer* ren, int screen_width, int screen_height, int tile_size) {
    //Determine how many tiles we'll need to fill the screen
    int xTiles = screen_width / tile_size;
    int yTiles = screen_height / tile_size;

    //Draw the tiles by calculating their positions
    for (int i = 0; i < xTiles * yTiles; ++i){
        int x = i % xTiles;
        int y = i / xTiles;
        render_texture(background, ren, x * tile_size, y * tile_size, tile_size, tile_size);
    }
}

void render_texture(SDL_Texture *tex, SDL_Renderer *ren, float x, float y, int w, int h){
    //Setup the destination rectangle to be at the position we want
    SDL_Rect dst;
    dst.x = cast(int)x;
    dst.y = cast(int)y;
    dst.w = w;
    dst.h = h;
    SDL_RenderCopy(ren, tex, null, &dst);
}

void render_texture(SDL_Texture *tex, SDL_Renderer *ren, float x, float y){
    int w, h;
    SDL_QueryTexture(tex, null, null, &w, &h);
    render_texture(tex, ren, cast(int)x, cast(int)y, w, h);
}

void destroy_texture(SDL_Texture *tex) {
    SDL_DestroyTexture(tex);
}

void log_SDL_error(string message) {
    auto error = SDL_GetError();
    std.stdio.stderr.writeln(message ~ *error);
}
