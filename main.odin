package main
import rl "raylib"
import "core:math"
import "core:fmt"
import noise "noise"
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
Game :: struct  {
    cam : rl.Camera3D,
    aliveCubes : [1024][257][1024]u8,
    meshes : [64][64]rl.Mesh,
    models : [64][64]rl.Model,
    texture : rl.Texture2D
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
b2f32 :: proc(boolean : bool) -> f32 {
    if (boolean) {
        return 1;
    }
    return 0;
}
addCube :: proc(model : ^ChunkModel, mesh : ^rl.Mesh, x : int, y : int, z : int, width : int, height : int, length : int, tx1 : f32, tx2 : f32, face : Faces, ambients : Faces) {
    //front face
    if (!face.front) {
        ft := 0.0626 + b2f32(ambients.front)
        setTriangle(model, mesh, x, y, z, tx1 + ft, tx2 + ft);                      // Bottom-left
        setTriangle(model, mesh, x + length, y, z, tx1 + ft, tx2 + ft);             // Bottom-right
        setTriangle(model, mesh, x + length, y + height, z, tx1 + ft, tx2 + ft);    // Top-right
        setTriangle(model, mesh, x, y, z, tx1 + ft, tx2 + ft);                      // Bottom-left
        setTriangle(model, mesh, x + length, y + height, z, tx1 + ft, tx2 + ft);    // Top-right
        setTriangle(model, mesh, x, y + height, z, tx1 + ft, tx2 + ft);             // Top-left        
    }

    // Back face
    if (!face.back) {
        bk := 0.0626 + b2f32(ambients.back)
        setTriangle(model, mesh, x, y, z + width, tx1 + bk, tx2 + bk);                  // Bottom-left
        setTriangle(model, mesh, x + length, y, z + width, tx1 + bk, tx2 + bk);         // Bottom-right
        setTriangle(model, mesh, x + length, y + height, z + width, tx1 + bk, tx2 + bk);// Top-right
        setTriangle(model, mesh, x, y, z + width, tx1 + bk, tx2 + bk);                  // Bottom-left
        setTriangle(model, mesh, x + length, y + height, z + width, tx1 + bk, tx2 + bk);// Top-right
        setTriangle(model, mesh, x, y + height, z + width, tx1 + bk, tx2 + bk);         // Top-left    
    }

    // Left face
    if (!face.left) {
        lt := 0.0626 + b2f32(ambients.left)
        setTriangle(model, mesh, x, y, z, tx1 + lt, tx2 + lt);                      // Bottom-left
        setTriangle(model, mesh, x, y + height, z, tx1 + lt, tx2 + lt);             // Top-left
        setTriangle(model, mesh, x, y + height, z + width, tx1 + lt, tx2 + lt);     // Top-right
        setTriangle(model, mesh, x, y, z, tx1 + lt, tx2 + lt);                      // Bottom-left
        setTriangle(model, mesh, x, y + height, z + width, tx1 + lt, tx2 + lt);     // Top-right
        setTriangle(model, mesh, x, y, z + width, tx1 + lt, tx2 + lt);              // Bottom-right    
    }

    // Right face
    if (!face.right) {
        rt := 0.0626 + b2f32(ambients.right)
        setTriangle(model, mesh, x + length, y, z, tx1 + rt, tx2 + rt);                 // Bottom-left
        setTriangle(model, mesh, x + length, y + height, z, tx1 + rt, tx2 + rt);        // Top-left
        setTriangle(model, mesh, x + length, y + height, z + width, tx1 + rt, tx2 + rt);// Top-right
        setTriangle(model, mesh, x + length, y, z, tx1 + rt, tx2 + rt);                 // Bottom-left
        setTriangle(model, mesh, x + length, y + height, z + width, tx1 + rt, tx2 + rt);// Top-right
        setTriangle(model, mesh, x + length, y, z + width, tx1 + rt, tx2 + rt);         // Bottom-right    
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

genMesh :: proc(_blocks : [dynamic]Cube, _faces : [dynamic]Faces, _types : [dynamic]u8, _ambients : [dynamic]Faces) -> rl.Mesh {
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
        addCube(&model, &mesh, cast(int)block.x,cast(int)block.y,cast(int)block.z,1,1,1,cords[_types[r]].x,cords[_types[r]].y, _faces[r], _ambients[r])
        //fmt.println(block.x,block.y,block.z)
        r+=1
    }
    rl.UploadMesh(&mesh,false)
    return mesh
}
genWorld :: proc(_game : ^Game) {
    p := noise.init_permutation()
    for x : i16 = 1; x < 1024; x+=1 {
        for z : i16 = 1; z < 1024; z+=1 {
            height := noise.perlin(cast(f32)x/20,0,cast(f32)z/20,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
            //height *= 200+50
            highest_point : i16
            for y : i16 = 1; y < 256; y+=1 { 
                _game.aliveCubes[x][y][z] = 255
                if  ((y<100 && height<0) || (y<101 && height>=0)) {
                    _game.aliveCubes[x][y][z] = 0
                    highest_point = y
                }
            }
            if (rl.GetRandomValue(0,200)==1) {
                for y : i16 = 0; y< 5; y+=1 {
                    _game.aliveCubes[x][y+highest_point][z] = 8

                }
                    
            }
        }
    }
}
checkObscures :: proc(_game : ^Game, x : i16, y : i16, z : i16) -> Faces {
    faces : Faces = {false, false, false, false, false, false}
    if (z+1 < 1024) { if (_game.aliveCubes[x][y][z+1]!=255) { faces.back = true } } // back
    if (z > 0) { if (_game.aliveCubes[x][y][z-1]!=255) { faces.front = true } } // front
    if (y+1 < 256) { if (_game.aliveCubes[x][y+1][z]!=255) { faces.top = true } } // top
    if (y > 0) { if (_game.aliveCubes[x][y-1][z]!=255) { faces.bottom = true } } // bottom
    if (x > 0) { if (_game.aliveCubes[x-1][y][z]!=255) { faces.left = true } } // left
    if (x+1 < 1024) { if (_game.aliveCubes[x+1][y][z]!=255) { faces.right = true } } // right

    return faces
}
checkAmbience :: proc(_game : ^Game, x : i16, y : i16, z : i16) -> Faces {
    faces : Faces = {false, false, false, false, false, false}
    if (y+1<256) {
        if (z+1 < 1024) { if (_game.aliveCubes[x][y+1][z+1]!=255) { faces.back = true } } // back
        if (z-1 > 0) { if (_game.aliveCubes[x][y+1][z-1]!=255) { faces.front = true } } // front
        if (x > 0) { if (_game.aliveCubes[x-1][y+1][z]!=255) { faces.left = true } } // left
        if (x+1 < 1024) { if (_game.aliveCubes[x+1][y+1][z]!=255) { faces.right = true } } // right
    }
    
    return faces
}
genChunkModel :: proc(_game : ^Game, x : i16, y : i16, z : i16, texture : rl.Texture2D) {
    blocks : [dynamic]Cube
    faces : [dynamic]Faces
    types : [dynamic]u8
    ambients : [dynamic]Faces
    for chunkx : i16 = 0; chunkx < 17; chunkx+=1 {
        for chunkz : i16 = 0; chunkz < 17; chunkz+=1 {
            for chunky : i16 = 0; chunky < 256; chunky+=1 { 
                if(chunkx+x*16>0 && chunky+y*16 > 0 && chunkz+z*16>0 && chunkx+x*16<1024 && chunky+y*16 <256 && chunkz+z*16<1024) {
                    if (_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]!=255) {
                        append(&blocks,Cube{chunkx+x*16,chunky+y*16,chunkz+z*16})
                        append(&faces,checkObscures(_game,chunkx+x*16,chunky+y*16,chunkz+z*16))
                        append(&ambients,checkAmbience(_game,chunkx+x*16,chunky+y*16,chunkz+z*16))
                        append(&types,_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]) 
                    }
                }
                
            }
        }
    }
    _game.meshes[x][z] = genMesh(blocks,faces,types,ambients)
    //_game.models[x][z] = rl.LoadModelFromMesh(_game.meshes[x][z])
    //_game.models[x][z].materials[0].maps[0].texture = texture
}
changeBlock :: proc(_game : ^Game, pos : Cube, _type : u8) {

    if (pos.x>-1 && pos.z > -1 && pos.y > -1) {
        if (_game.aliveCubes[pos.x][pos.y][pos.z] == 255 && _type != 255) || (_game.aliveCubes[pos.x][pos.y][pos.z] != 255 && _type == 255) {
            _game.aliveCubes[pos.x][pos.y][pos.z] = _type
            chunkPos := Cube{i16(int(pos.x/16)),0,i16(int(pos.z/16))}
            
            rl.UnloadMesh(_game.meshes[chunkPos.x][chunkPos.z])
            //rl.UnloadModel(_game.models[chunkPos.x][chunkPos.z])
            genChunkModel(_game,chunkPos.x,0,chunkPos.z, _game.texture)
        
        }
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

    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
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
    _game.texture = rl.LoadTexture("textures/texture_pack.png")
    for x : i16 = 0; x < 64; x+=1 {
        for y : i16 = 0; y < 64; y+=1 {
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
        for x : i16 = 0; x < 64; x+=1 {
            for y : i16 = 0; y < 64; y+=1 {
                rl.DrawMesh(_game.meshes[x][y],mat,rl.MatrixTranslate(1,1,1))
        
            }
        }
        updatePlayer(_game);
        rl.EndMode3D();
        rl.DrawFPS(0,0);
    }
}

main :: proc() {
    _game := new(Game)
    runGame(_game)
    
}