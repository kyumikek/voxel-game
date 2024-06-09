package main
import rl "raylib"

import "core:fmt"
import noise "noise"
Cube :: struct #packed{
    x : u16,
    y : u16, 
    z : u16
}
Rect :: struct {
    x : f32,
    y : f32,
}
Faces :: struct #packed{ 
    front : bool,
    back : bool,
    top : bool,
    bottom : bool,
    left : bool,
    right : bool
}
Game :: struct  {
    cam : rl.Camera3D,
    aliveCubes : [1024][257][1024]u8,
    meshes : map[Cube]rl.Mesh,
    models : map[Cube]rl.Model
}

ChunkModel :: struct {
    vertex_count : int,
    text_count : int
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
    mesh.texcoords[model.text_count] = tx1
    model.text_count+=1
    mesh.texcoords[model.text_count] = tx2
    model.text_count+=1
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

genMesh :: proc(_blocks : [dynamic]Cube, _faces : [dynamic]Faces, _types : [dynamic]u8) -> rl.Mesh {
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
    model := ChunkModel{0,0}
    r : int = 0
    cords : map[u8]Rect

    cords[0] = {0.0,0} //grass
    cords[1] = {0.0626,0} //ambient grass
    cords[2] = {0.1251,0} //stone
    cords[3] = {0.1876,0} //ambient stone
    cords[4] = {0.2501,0} //sand 
    cords[5] = {0.3126,0} //ambient sand
    cords[6] = {0.3751,0} //wood
    cords[7] = {0.4376,0} //ambient wood
    cords[8] = {0.5001,0} //dirt
    cords[9] = {0.5626,0} //ambient dirt
    cords[10] = {0.6251,0} //leaf
    cords[11] = {0.6876,0} //ambient leaf
    cords[12] = {0.7501,0} //iron ore
    cords[13] = {0.8126,0} //ambient iron ore
    cords[14] = {0.8751,0} //gold ore
    cords[15] = {0.9376,0} //ambient gold ore
    for block in _blocks {
        addCube(&model, &mesh, cast(int)block.x,cast(int)block.y,cast(int)block.z,1,1,1,cords[_types[r]].x,cords[_types[r]].y, _faces[r])
        //fmt.println(block.x,block.y,block.z)
        r+=1
    }
    rl.UploadMesh(&mesh,false)
    return mesh
}
genWorld :: proc(_game : ^Game) {
    p := noise.init_permutation()
    for x : u16 = 1; x < 1024; x+=1 {
        for z : u16 = 1; z < 1024; z+=1 {
            height := noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) * 200+50
            for y : u16 = 1; y < 256; y+=1 { 
                _game.aliveCubes[x][y][z] = 255
                if  cast(f32)y<height {
                    _game.aliveCubes[x][y][z] = cast(u8)rl.GetRandomValue(0,15)
                }
                
            }
        }
    }
}
checkObscures :: proc(_game : ^Game, x : u16, y : u16, z : u16) -> Faces {
    faces : Faces = {false, false, false, false, false, false}
    if (z+1 < 1024) { if (_game.aliveCubes[x][y][z+1]!=255) { faces.back = true } } // back
    if (z-1 > 0) { if (_game.aliveCubes[x][y][z-1]!=255) { faces.front = true } } // front
    if (y+1 < 256) { if (_game.aliveCubes[x][y+1][z]!=255) { faces.top = true } } // top
    if (y > 0) { if (_game.aliveCubes[x][y-1][z]!=255) { faces.bottom = true } } // bottom
    if (x > 0) { if (_game.aliveCubes[x-1][y][z]!=255) { faces.left = true } } // left
    if (x+1 < 1024) { if (_game.aliveCubes[x+1][y][z]!=255) { faces.right = true } } // right

    return faces
}
genChunkModel :: proc(_game : ^Game, x : u16, y : u16, z : u16, texture : rl.Texture2D) {
    blocks : [dynamic]Cube
    faces : [dynamic]Faces
    types : [dynamic]u8
    for chunkx : u16 = 0; chunkx < 17; chunkx+=1 {
        for chunkz : u16 = 0; chunkz < 17; chunkz+=1 {
            for chunky : u16 = 0; chunky < 256; chunky+=1 { 
                if(chunkx+x*16>0 && chunky+y*16 > 0 && chunkz+z*16>0 && chunkx+x*16<1024 && chunky+y*16 <256 && chunkz+z*16<1024) {
                    if (_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]!=255) {
                        append(&blocks,Cube{chunkx+x*16,chunky+y*16,chunkz+z*16})
                        append(&faces,checkObscures(_game,chunkx+x*16,chunky+y*16,chunkz+z*16))
                        append(&types,_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]) 
                    }
                }
                
            }
        }
    }
    _game.meshes[{x,y,z}] = genMesh(blocks,faces,types)
    _game.models[{x,y,z}] = rl.LoadModelFromMesh(_game.meshes[{x,y,z}])
    _game.models[{x,y,z}].materials[0].maps[0].texture = texture
}
runGame :: proc(_game : ^Game) {
    _game.cam = genCam()
    _game.models = {}
    _game.meshes = {}
    _game.aliveCubes = {}

    rl.InitWindow(1200,800,"a");
    //rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
    //rl.rlEnableWireMode();
    genWorld(_game);
    tx := rl.LoadTexture("textures/texture_pack.png")
    for x : u16 = 0; x < 32; x+=1 {
        for y : u16 = 0; y < 32; y+=1 {
            genChunkModel(_game,x,0,y,tx)
            
        }    
    }
    //model := rl.LoadModelFromMesh(genMesh(_game.cubes))
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.SKYBLUE);
        rl.UpdateCamera(&_game.cam,.FIRST_PERSON)
        if rl.IsKeyDown(.SPACE) {
            _game.cam.target.y += 1
            _game.cam.position.y += 1
        }
        rl.BeginMode3D(_game.cam);
        for x : u16 = 0; x < 32; x+=1 {
            for y : u16 = 0; y < 32; y+=1 {
                rl.DrawModel(_game.models[{x,0,y}],{cast(f32)x,0,cast(f32)y},1.0,rl.GRAY)
        
            }
        }
        rl.EndMode3D();
        rl.DrawFPS(0,0);
    }
}

main :: proc() {
    _game := new(Game)
    runGame(_game)
    
}