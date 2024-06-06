package main
import rl "raylib"

import "core:fmt"

Cube :: struct #align(16) {
    x : u16,
    y : u16, 
    z : u16
}

Faces :: struct {
    front : bool,
    back : bool,
    top : bool,
    bottom : bool,
    left : bool,
    right : bool
}

Game :: struct {
    cam : rl.Camera3D,
    aliveCubes : map[Cube]bool,
    faces : map[Cube]Faces,
    meshes : map[Cube]rl.Mesh,
    models : map[Cube]rl.Model
}

ChunkModel :: struct {
    vertex_count : int,
}

genCam :: proc() -> rl.Camera3D {
    cam : rl.Camera3D
    cam.position = {5,5,5};
    cam.target = {0,0,0}
    cam.up = {0,1,0}
    cam.fovy = 45
    
    cam.projection = .PERSPECTIVE
    return cam
}

setTriangle :: proc(model : ^ChunkModel,mesh : ^rl.Mesh,x : int, y : int, z : int, tx1 : f32,  tx2 : f32) {
    
    mesh.vertices[model.vertex_count] = cast(f32)x
    model.vertex_count+=1;
    mesh.vertices[model.vertex_count] = cast(f32)y
    model.vertex_count+=1;
    mesh.vertices[model.vertex_count] = cast(f32)z
    model.vertex_count+=1;
}

addCube :: proc(model : ^ChunkModel, mesh : ^rl.Mesh, x : int, y : int, z : int, width : int, height : int, length : int, tx1 : f32, tx2 : f32, face : Faces) {
    //front face
    if (!face.front) {
        setTriangle(model,mesh, x, y, z, tx1, tx2);           // Bottom-left
        setTriangle(model,mesh, x + length, y, z, tx1, tx2);  // Bottom-right
        setTriangle(model,mesh, x + length, y + height, z, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z, tx1, tx2);           // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y + height, z, tx1, tx2);  // Top-left        
    }

    // Back face
    if (!face.back) {
        setTriangle(model,mesh, x, y, z + width, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y, z + width, tx1, tx2);   // Bottom-right
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z + width, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y + height, z + width, tx1, tx2);   // Top-left    
    }

    // Left face
    if (!face.left) {
        setTriangle(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x, y + height, z, tx1, tx2);   // Top-left
        setTriangle(model,mesh, x, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z + width, tx1, tx2);    // Bottom-right    
    }
    

    // Right face
    if (!face.right) {
        setTriangle(model,mesh, x + length, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z, tx1, tx2);   // Top-left
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x + length, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x + length, y, z + width, tx1, tx2);    // Bottom-right    
    }

    // Top face
    if (!face.top) {
        setTriangle(model,mesh, x, y + height, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z, tx1, tx2);   // Bottom-right
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y + height, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y + height, z + width, tx1, tx2);    // Top-left
            
    }
    
    // Bottom face
    if (!face.bottom) {
        setTriangle(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y, z, tx1, tx2);   // Bottom-right
        setTriangle(model,mesh, x + length, y, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setTriangle(model,mesh, x + length, y, z + width, tx1, tx2); // Top-right
        setTriangle(model,mesh, x, y, z + width, tx1, tx2);    // Top-left
    }
    
}

genMesh :: proc(_blocks : [dynamic]Cube, _faces : [dynamic]Faces) -> rl.Mesh {
    mesh : rl.Mesh
    trang_count : i32 = 0
    for face in _faces {
        if (!face.front) {trang_count += 2;}
        if (!face.back) {trang_count += 2;}
        if (!face.top) {trang_count += 2;}
        if (!face.bottom) {trang_count += 2;}
        if (!face.right) {trang_count += 2;}
        if (!face.left) {trang_count += 2;}
    }
    mesh.triangleCount = trang_count
    mesh.vertexCount = mesh.triangleCount*3;
    mesh.vertices = cast(^f32)rl.MemAlloc(cast(u32)mesh.vertexCount*3*size_of(f32))
    mesh.texcoords = cast(^f32)rl.MemAlloc(cast(u32)mesh.vertexCount*2*size_of(f32))
    model := ChunkModel{0}
    r : int = 0
    for block in _blocks {
        addCube(&model, &mesh, cast(int)block.x,cast(int)block.y,cast(int)block.z,1,1,1,0,0, _faces[r])
        //fmt.println(block.x,block.y,block.z)
        r+=1
    }
    rl.UploadMesh(&mesh,false)
    return mesh
}
genWorld :: proc(_game : ^Game) {
    for x : u16 = 0; x < 128; x+=1 {
        for z : u16 = 0; z < 128; z+=1 {
            for y : u16 = 0; y < 128; y+=1 { 
                _game.aliveCubes[{x,y,z}] = true
                _game.faces[{x,y,z}] = {false,false,false,false,false,false}
            }
        }
    }
}
checkObscures :: proc(_game : ^Game, x : u16, y : u16, z : u16) {
    faces : Faces = {
        _game.aliveCubes[{x,y,z+1}], //front
        _game.aliveCubes[{x,y,z-1}], //back
        _game.aliveCubes[{x,y+1,z}], //top
        _game.aliveCubes[{x,y-1,z}], //bottom
        _game.aliveCubes[{x-1,y,z}], //left
        _game.aliveCubes[{x+1,y,z}], //right
    }
    //fmt.println(faces)
    _game.faces[{x,y,z}] = faces
}
genChunkModel :: proc(_game : ^Game, x : u16, y : u16, z : u16) {
    blocks : [dynamic]Cube
    faces : [dynamic]Faces
    for chunkx : u16 = 0; chunkx < 17; chunkx+=1 {
        for chunkz : u16 = 0; chunkz < 17; chunkz+=1 {
            for chunky : u16 = 0; chunky < 256; chunky+=1 { 
                if (_game.aliveCubes[{chunkx+x*16,chunky+y*16,chunkz+z*16}]) {
                    checkObscures(_game,chunkx+x*16,chunky+y*16,chunkz+z*16)
                    append(&blocks,Cube{chunkx+x*16,chunky+y*16,chunkz+z*16})
                    append(&faces,_game.faces[{chunkx+x*16,chunky+y*16,chunkz+z*16}])
                    
                }
            }
        }
    }
    _game.meshes[{x,y,z}] = genMesh(blocks,faces)
    _game.models[{x,y,z}] = rl.LoadModelFromMesh(_game.meshes[{x,y,z}])
}
runGame :: proc(_game : ^Game) {
    rl.InitWindow(1200,800,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
    rl.rlEnableWireMode();
    genWorld(_game);
    for x : u16 = 0; x < 32; x+=1 {
        for y : u16 = 0; y < 32; y+=1 {
            genChunkModel(_game,x,0,y)
            
        }    
    }
    //model := rl.LoadModelFromMesh(genMesh(_game.cubes))
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.SKYBLUE);
        rl.UpdateCamera(&_game.cam,.FIRST_PERSON)
        rl.BeginMode3D(_game.cam);
        for x : u16 = 0; x < 32; x+=1 {
            for y : u16 = 0; y < 32; y+=1 {
                rl.DrawModel(_game.models[{x,0,y}],{cast(f32)x,0,cast(f32)y},1.0,rl.WHITE)
        
            }
        }
        rl.EndMode3D();
        rl.DrawFPS(0,0);
    }
}

main :: proc() {
    _game := Game{genCam(),{},{},{},{}}
    runGame(&_game)
    
}