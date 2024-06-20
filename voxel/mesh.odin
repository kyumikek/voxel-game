package voxel
import rl "../raylib"

genCam :: proc() -> rl.Camera3D { //setup up the camera will be moved into the player controller file once one is created and needed
    cam : rl.Camera3D
    cam.position = {5,5,5};
    cam.target = {0,0,0}
    cam.up = {0,1,0}
    cam.fovy = 45
    
    cam.projection = .PERSPECTIVE
    return cam
}

setTriangle :: proc(model : ^ChunkModel,mesh : ^rl.Mesh,x : int, y : int, z : int, tx1 : f32,  tx2 : f32) {
    //quick and dirt solution, good enuf
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
    //a quick fix because odin's system doesn't allow i for some reason
    if (boolean) {
        return 1;
    }
    return 0;
}
addCube :: proc(model : ^ChunkModel, mesh : ^rl.Mesh, x : int, y : int, z : int, width : int, height : int, length : int, tx1 : f32, tx2 : f32, face : Faces, ambients : Faces) {
    //I hate this
    //Gonna add a file that defines all the faces
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
    //count the trang count
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
    cords : map[u8]Rect
	//needs to be moved into data.odin and made loaded from a file, this is a temporary solution
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
    //go through blocks and add the data to the mesh
    index : int = 0
    for block in _blocks {
        addCube(&model, &mesh, cast(int)block.x,cast(int)block.y,cast(int)block.z,1,1,1,cords[_types[index]].x,cords[_types[index]].y, _faces[index], _ambients[index])

        index+=1
    }
    rl.UploadMesh(&mesh,false)
    return mesh
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
    faces : Faces = {false, false, false, false, false, false} //I reuse the data type for simplicity sake 
    if (y+1<256) {
        if (z+1 < 1024) { if (_game.aliveCubes[x][y+1][z+1]!=255) { faces.back = true } } // back
        if (z-1 > 0) { if (_game.aliveCubes[x][y+1][z-1]!=255) { faces.front = true } } // front
        if (x > 0) { if (_game.aliveCubes[x-1][y+1][z]!=255) { faces.left = true } } // left
        if (x+1 < 1024) { if (_game.aliveCubes[x+1][y+1][z]!=255) { faces.right = true } } // right
    }
    
    return faces
}
genChunkModel :: proc(_game : ^Game, x : i16, y : i16, z : i16, texture : rl.Texture2D) {
	//setup data
    blocks : [dynamic]Cube
    faces : [dynamic]Faces
    types : [dynamic]u8
    ambients : [dynamic]Faces
    //go through the chunk size
    for chunkx : i16 = 0; chunkx < 16; chunkx+=1 {
        for chunkz : i16 = 0; chunkz < 16; chunkz+=1 {
            for chunky : i16 = 0; chunky < 256; chunky+=1 { 
				//don't change the 0s to 1s, doesn't change anything gameplay wise and helps with the performance quite a bit 
                if(chunkx+x*16>0 && chunky+y*16 > 0 && chunkz+z*16>0 && chunkx+x*16<1024 && chunky+y*16 <256 && chunkz+z*16<1024) {
                    if (_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]!=255) {
                        append(&blocks,Cube{chunkx+x*16,chunky+y*16,chunkz+z*16}) //add cube poses
                        append(&faces,checkObscures(_game,chunkx+x*16,chunky+y*16,chunkz+z*16)) //add visible faces
                        append(&ambients,checkAmbience(_game,chunkx+x*16,chunky+y*16,chunkz+z*16)) //add the checks for lights
                        append(&types,_game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]) //add the block types
                    }
                }
                
            }
        }
    }
    _game.meshes[x][z] = genMesh(blocks,faces,types,ambients)
}
