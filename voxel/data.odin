package voxel
import rl "../raylib"
Cube :: struct {
    x : i16,
    y : i16, 
    z : i16
}
Rect :: struct {
    x : f32,
    y : f32,
}
Faces :: struct { 
    front : bool,
    back : bool,
    top : bool,
    bottom : bool,
    left : bool,
    right : bool
}
Game :: struct #packed {
    cam : rl.Camera3D,
    aliveCubes : [1024][257][1024]u8,
    meshes : [64][64]rl.Mesh,
    material : rl.Material,
    renderDistance : i16,
    
}
ChunkModel :: struct {
    vertex_count : int,
    text_count : int
}
WorldStructure :: struct {
	x : i16,
	y : i16,
	z : i16,
	kind : u8
}
