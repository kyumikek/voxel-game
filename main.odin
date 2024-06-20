package main
import rl "raylib"
import "core:math"
import "core:fmt"
import vx"voxel"




updatePlayer :: proc(_game : ^vx.Game) {
    rl.UpdateCamera(&_game.cam,.FIRST_PERSON)
    if rl.IsKeyDown(.SPACE) {
        _game.cam.target.y += 1
        _game.cam.position.y += 1
    }
    if rl.IsKeyDown(.LEFT_CONTROL) {
        _game.cam.target.y -= 1
        _game.cam.position.y -= 1
    }
    if rl.IsKeyDown(.G) {
        rl.rlEnableWireMode()
    }
    if rl.IsKeyDown(.H) {
        rl.rlDisableWireMode();
    }
    vec : vx.Cube= {cast(i16)(_game.cam.target.x-_game.cam.position.x),cast(i16)(_game.cam.target.y-_game.cam.position.y),cast(i16)(_game.cam.target.z-_game.cam.position.z)}
    vec.x += i16(_game.cam.target.x)
    vec.y += i16(_game.cam.target.y)
    vec.z += i16(_game.cam.target.z)
    vec = vx.Cube{i16(int(vec.x)),i16(int(vec.y)),i16(int(vec.z))}
    //fmt.println(vec)
    if (rl.IsMouseButtonDown(.RIGHT)) {
        vx.changeBlock(_game,vec,0)
    }
    if (rl.IsMouseButtonDown(.LEFT)) {
        vx.changeBlock(_game,vec,255)
    }

    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
}



setupGame :: proc(_game : ^vx.Game) {
	//reset vars
	_game.cam = vx.genCam()
    _game.models = {}
    _game.meshes = {}
    _game.aliveCubes = {}

	//setup raylib stuff
	rl.InitWindow(1200,600,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
    
   
}
runGame :: proc(_game : ^vx.Game) {
	setupGame(_game)
    vx.genWorld(_game);
    _game.texture = rl.LoadTexture("textures/texture_pack.png")
    for x : i16 = 0; x < 32; x+=1 {
        for y : i16 = 0; y < 32; y+=1 {
            vx.genChunkModel(_game,x,0,y,_game.texture)
            
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

main :: proc() {
    _game := new(vx.Game)
    runGame(_game)
    
}