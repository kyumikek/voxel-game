package voxel
import rl "../raylib"
setupGame :: proc(_game : ^Game) {
	//reset vars
	_game.cam = genCam()
    _game.meshes = {}
    _game.aliveCubes = {}
	_game.renderDistance = 16
	//setup raylib stuff
	rl.InitWindow(1200,600,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
   
}
runGame :: proc(_game : ^Game) {
	setupGame(_game)
    genWorld(_game);
    
    _game.material = rl.LoadMaterialDefault();

    _game.material.maps[0].texture = rl.LoadTexture("textures/texture_pack.png");
	
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