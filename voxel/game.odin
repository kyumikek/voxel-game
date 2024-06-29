package voxel
import rl "../raylib"
import perlin "../noise"
import "core:fmt"
setupGame :: proc(_game : ^Game, width : i32, height : i32) {
	//reset vars
	_game.cam = genCam()
    _game.meshes = {}
    _game.aliveCubes = {}
	_game.renderDistance = 16
    _game.y_velocity = 0;
	//setup raylib stuff
	rl.InitWindow(width,height,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
   
    loadStructure("data/structures/house.struct","house",_game)
    loadStructure("data/structures/tree.struct","tree",_game)
}

runGame :: proc(_game : ^Game, width : i32, height : i32) {
	setupGame(_game,width,height)
    genWorld(_game);
    
    _game.material = rl.LoadMaterialDefault();

    _game.material.maps[0].texture = rl.LoadTexture("textures/texture_pack.png");
    //colors : []rl.Color = {rl.GREEN,rl.BROWN,rl.YELLOW,rl.BLUE,rl.LIME,rl.RED,rl.GRAY,rl.SKYBLUE,rl.WHITE,rl.PINK}
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.SKYBLUE);
        
        rl.BeginMode3D(_game.cam);
		updateWorld(_game);
        rl.EndMode3D();
        
        rl.DrawFPS(0,0);
    }
}