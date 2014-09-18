import derelict.sdl2.sdl;
import derelict.sdl2.image;
// import derelict.sdl2.mixer;
// import derelict.sdl2.ttf;
// import derelict.sdl2.net;

import std.stdio;
import std.file;
import core.thread;
import std.cstream;
import std.conv;

int main()
{
    DerelictSDL2.load();
    DerelictSDL2Image.load();


    int screen_width = 640;
    int screen_height = 480;
    int tile_size = 40;

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
        auto error = SDL_GetError();
        // error is a pointer to a const(char), no need to cast it to string to writeln
        logSDLError( "SDL_Init Error: " ~ *error );
        return 1;
    }

    if ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) != IMG_INIT_PNG){
        auto error = SDL_GetError();
        logSDLError("IMG_Init " ~ *error);
        SDL_Quit();
        return 1;
    }


    SDL_Window *win = SDL_CreateWindow("Hello World!", 100, 100, screen_width, screen_height, SDL_WINDOW_SHOWN);
    if (win == null){
        auto error = SDL_GetError();
        logSDLError( "SDL_CreateWindow Error: " ~ *error);
        SDL_Quit();
        return 1;
    }

    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren == null ){
        SDL_DestroyWindow(win);
        auto error = SDL_GetError();
        logSDLError("SDL_CreateRenderer Error: " ~ *error);
        SDL_Quit();
        return 1;
    }



    SDL_Texture *background = loadTexture("/home/emilper/mnt/little/work/abm/source/background.png", ren);
    SDL_Texture *image = loadTexture("/home/emilper/mnt/little/work/abm/source/mob.png", ren);
    SDL_Texture *target = loadTexture("/home/emilper/mnt/little/work/abm/source/target.png", ren);

    if (background == null || image == null || target == null){
        writeln("one texture is null");
        IMG_Quit();
        SDL_Quit();
        return 1;
    }

    int iW, iH;
    SDL_QueryTexture(image, null, null, &iW, &iH);
    int mx = screen_width / 2 - iW / 2;
    int my = screen_height / 2 - iH / 2;
    Position mob_position = Position(mx, my );
    Position mouse_target = Position(0,0);

    SDL_Event e;
    bool quit = false;
    SDL_Delay(20);
    while (!quit){
        while (SDL_PollEvent(&e)){
            if( e.type == SDL_QUIT ) {
                quit = true;
            }
            else if( e.type == SDL_KEYDOWN ) { //User presses a key
                mob_position = follow_keyboard_arrows(e, mob_position);
            } else if ( e.type == SDL_MOUSEBUTTONDOWN ) {
                writeln("mouse is down");
                mouse_target = get_mouse_clicks(e, mouse_target);
            }
        }


        //Render the scene
        SDL_RenderClear(ren);
        render_background(background, ren, screen_width, screen_height, tile_size);
        renderTexture(image, ren, mob_position.x, mob_position.y);
        if (mouse_target.x != 0 && mouse_target.y != 0) {
            renderTexture(target, ren, mouse_target.x, mouse_target.y);
            mob_position = follow_target(mob_position, mouse_target);
        }
        SDL_RenderPresent(ren);
    }

    writeln("quit is true");
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    IMG_Quit();
    SDL_Quit();
    return 0;
}


SDL_Texture* loadTexture(string file_path, SDL_Renderer *ren) {
    if (!exists(file_path)) {
        throw new Exception("file not found: " ~ file_path);
    }

    SDL_Texture *texture = IMG_LoadTexture(ren, std.string.toStringz(file_path));
    if (texture == null) {
        logSDLError("failed to load texture from " ~ file_path);
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
        renderTexture(background, ren, x * tile_size, y * tile_size, tile_size, tile_size);
    }
}

/**
* Draw an SDL_Texture to an SDL_Renderer at position x, y, with some desired
* width and height
* @param tex The source texture we want to draw
* @param ren The renderer we want to draw to
* @param x The x coordinate to draw to
* @param y The y coordinate to draw to
* @param w The width of the texture to draw
* @param h The height of the texture to draw
*/
void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, int w, int h){
    //Setup the destination rectangle to be at the position we want
    SDL_Rect dst;
    dst.x = x;
    dst.y = y;
    dst.w = w;
    dst.h = h;
    SDL_RenderCopy(ren, tex, null, &dst);
}

/**
* Draw an SDL_Texture to an SDL_Renderer at position x, y, preserving
* the texture's width and height
* @param tex The source texture we want to draw
* @param ren The renderer we want to draw to
* @param x The x coordinate to draw to
* @param y The y coordinate to draw to
*/
void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y){
    int w, h;
    SDL_QueryTexture(tex, null, null, &w, &h);
    renderTexture(tex, ren, x, y, w, h);
}

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

Position get_mouse_clicks(SDL_Event e, Position mouse_target) {
    int x, y;
    if (SDL_GetMouseState(&x, &y) & SDL_BUTTON(SDL_BUTTON_LEFT)) {
        mouse_target.x = x - 5;
        mouse_target.y = y - 5;
    }
    return mouse_target;
}

Position follow_target(Position mob_position, Position mouse_target) {

    int move_x, move_y;
    if (mouse_target.x != 0 && mouse_target.y != 0) {
        if (mouse_target.x - mob_position.x > 0) {
            move_x = 1;
        } else if ( mouse_target.x - mob_position.x < 0) {
            move_x = -1;
        }

        if (mouse_target.y - mob_position.y > 0) {
            move_y = 1;
        } else if (mouse_target.y - mob_position.y < 0) {
            move_y = -1;
        }

        mob_position.y += move_y;
        mob_position.x  += move_x;
    }
    return mob_position;
}

void logSDLError(string message) {
    std.stdio.stderr.writeln(message);
}

void cleanup(SDL_Texture* tex) {
    SDL_DestroyTexture(tex);
}

void cleanup(SDL_Surface* surface) {
    SDL_FreeSurface(surface);
}

void cleanup(SDL_Renderer* ren) {
    SDL_DestroyRenderer(ren);
}

struct Position {
    int x;
    int y;
}

