package voxel
import rl "../raylib"
buildNDestroy :: proc(_game : ^Game) {
    vec : Cube= {cast(i16)(_game.cam.target.x-_game.cam.position.x),cast(i16)(_game.cam.target.y-_game.cam.position.y),cast(i16)(_game.cam.target.z-_game.cam.position.z)}
    vec.x += i16(_game.cam.target.x)
    vec.y += i16(_game.cam.target.y)
    vec.z += i16(_game.cam.target.z)
    vec = Cube{i16(int(vec.x)),i16(int(vec.y)),i16(int(vec.z))}
    //fmt.println(vec)
    if (rl.IsMouseButtonDown(.RIGHT)) {
        changeBlock(_game,vec,0)
    }
    if (rl.IsMouseButtonDown(.LEFT)) {
        changeBlock(_game,vec,255)
    }
}
updatePlayer :: proc(_game : ^Game) {
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
    //x : int = int(_game.cam.position.x)
    //y : int = int(_game.cam.position.y)
    //z : int = int(_game.cam.position.z)
    //if (_game.aliveCubes[x][y-1][z]==255) {
    //    _game.y_velocity += 0.01
    //}
    //else {
    //    _game.y_velocity = 0
    //}
    //_game.cam.position.y -= _game.y_velocity
    //_game.cam.target.y -= _game.y_velocity
    buildNDestroy(_game);
    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
}