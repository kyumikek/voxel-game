package voxel
import rl "../raylib"
setupGame :: proc(_game : ^Game) {
	//reset vars
	_game.cam = genCam()
    _game.models = {}
    _game.meshes = {}
    _game.aliveCubes = {}

	//setup raylib stuff
	rl.InitWindow(1200,600,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
   
}
runGame :: proc(_game : ^Game) {
	setupGame(_game)
    genWorld(_game);
    _game.texture = rl.LoadTexture("textures/texture_pack.png")
    for x : i16 = 0; x < 32; x+=1 {
        for y : i16 = 0; y < 32; y+=1 {
            genChunkModel(_game,x,0,y,_game.texture)
            
        }    
    }
    mat : rl.Material = rl.LoadMaterialDefault();

    mat.maps[0].texture = _game.texture;

    //DrawMesh(yourMesh, yourMatrix, mat);
    //model := rl.LoadModelFromMesh(genMesh(_game.cubes))
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.SKYBLUE);
        
        rl.BeginMode3D(_game.cam);
        for x : i16 = 0; x < 32; x+=1 {
            for y : i16 = 0; y < 32; y+=1 {
                rl.DrawMesh(_game.meshes[x][y],mat,rl.MatrixTranslate(1,1,1))
        
            }
        }
        updatePlayer(_game);
        rl.EndMode3D();
        rl.DrawFPS(0,0);
    }
}
