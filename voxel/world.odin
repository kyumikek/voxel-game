package voxel
import rl "../raylib"
import noise "../noise"
import "core:fmt"
genTree :: proc(_game : ^Game, x : i16, highest_point : i16, z : i16) { //temporary we will want to make a structure loading file and use that to generate terrain. Tho it's good enough for now.
	for y : i16 = 0; y< 5; y+=1 {
		_game.aliveCubes[x][y+highest_point][z] = 8
		
    }
    for tx : i16 = -2; tx < 3; tx+=1 {
		for tz : i16 = -2; tz < 3; tz+=1 {
			for ty : i16 = 0; ty < 2; ty+=1 {
				if (tx+x>0 && tx+x<1024 && ty+highest_point+5>0 && ty+highest_point+5<256 && tz+z>0 && tz+z<1024) {
					if (_game.aliveCubes[tx+x][ty+highest_point+5][tz+z]==255) {
						_game.aliveCubes[tx+x][ty+highest_point+5][tz+z] = 10
					}
					
				}
				
			}
		}
    }
    for tx : i16 = -1; tx < 2; tx+=1 {
		for tz : i16 = -1; tz < 2; tz+=1 {
			for ty : i16 = 2; ty < 4; ty+=1 {
				if (tx+x>0 && tx+x<1024 && ty+highest_point+5>0 && ty+highest_point+5<256 && tz+z>0 && tz+z<1024) {
					if (_game.aliveCubes[tx+x][ty+highest_point+5][tz+z]==255) {
						_game.aliveCubes[tx+x][ty+highest_point+5][tz+z] = 10
					}
					
				}
				
			}
		}
    }
}
genTreeFallenOver :: proc(_game : ^Game, x : i16, highest_point : i16, z : i16) { //temporary we will want to make a structure loading file and use that to generate terrain. Tho it's good enough for now.
	for y : i16 = 0; y< 5; y+=1 {
		if (x+y>0 && x+y<1024) {
			_game.aliveCubes[x+y][highest_point][z] = 8
		
		}
    }
    for tx : i16 = -1; tx < 2; tx+=1 {
		for tz : i16 = -1; tz < 2; tz+=1 {
			for ty : i16 = 0; ty < 2; ty+=1 {
				if (tx+x+5>0 && tx+x+5<1024 && ty+highest_point>0 && ty+highest_point<256 && tz+z>0 && tz+z<1024) {
					if (_game.aliveCubes[tx+x+5][ty+highest_point][tz+z]==255) {
						_game.aliveCubes[tx+x+5][ty+highest_point][tz+z] = 10
					}
					
				}
				
			}
		}
    }
    
}

flatLands :: proc(_game : ^Game, x : i16, z : i16, structures : ^[dynamic] WorldStructure, p : []int) {
	height := noise.perlin(cast(f32)x/20,0,cast(f32)z/20,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
	highest_point : i16
	for y : i16 = 1; y < 256; y+=1 { 
		if  ((y<80 && height<0) || (y<81 && height>=0)) {
			_game.aliveCubes[x][y][z] = 0
			highest_point = y
		}
		else {
			_game.aliveCubes[x][y][z] = 255
		}
	}
	if (rl.GetRandomValue(0,200)==1) {
		tree_type : u8 = 0
		if (rl.GetRandomValue(0,5)==1) {
			tree_type = 1
		}
		append(structures,WorldStructure{x,highest_point+1,z,tree_type})			
	}
}
highLands :: proc(_game : ^Game, x : i16, z : i16, structures : ^[dynamic] WorldStructure, p : []int) { //finished, only need o add structure generation. Overall I am very happy with the result ;)
	height2 := noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
	height := noise.perlin(cast(f32)x/80,0,cast(f32)z/80,p)  + noise.perlin(cast(f32)x/80,0,cast(f32)z/80,p);
	mountain_height := height* 60;
	for y : i16 = 1; y < 256; y+=1 { 
		if  ((y<80 && height2<0) || (y<81 && height2>=0)) {
			_game.aliveCubes[x][y][z] = 2
			if ((y==79 && height2<0) || (y==80 && height2>=0)) {
				_game.aliveCubes[x][y][z] = 0
				_game.aliveCubes[x][y-1][z] = 4
				
				if rl.GetRandomValue(0,200)==1 {
					append(structures,WorldStructure{x,y,z,0})	
				}
				
			}
			
		}
		else if  (y<=cast(i16)mountain_height+80 && y>79) {
			_game.aliveCubes[x][y][z] = 2
			
			if (y==cast(i16)mountain_height+80) {
				_game.aliveCubes[x][y][z] = 0
				_game.aliveCubes[x][y-1][z] = 4
				
				if rl.GetRandomValue(0,200)==1 {
					append(structures,WorldStructure{x,y,z,0})	
				}
				
			}
			
		}
		else {
			_game.aliveCubes[x][y][z] = 255
		}
		
	}
}

genWorld :: proc(_game : ^Game) {
    p := noise.init_permutation()
    structures : [dynamic] WorldStructure
    for x : i16 = 1; x < 1024; x+=1 {
        for z : i16 = 1; z < 1024; z+=1 {
            highLands(_game,x,z,&structures,p);
        }
    }
    for structure in structures { //temporary, will be made into a hashmap
		switch structure.kind {
			case 0:
				genTree(_game,structure.x,structure.y,structure.z);
			break;
			case 1:
				genTreeFallenOver(_game,structure.x,structure.y,structure.z);
			break;
		}
		fmt.println(structure)
    }
    for x : i16 = 0; x < 32; x+=1 {
        for y : i16 = 0; y < 32; y+=1 {
            genChunkModel(_game,x,0,y)
            
        }    
    }
}
changeBlock :: proc(_game : ^Game, pos : Cube, _type : u8) {

    if (pos.x>-1 && pos.z > -1 && pos.y > -1) {
		//check whether the block is air and needs to be replaced
		//check whether the block is solid and is gonna be destroyed
        if (_game.aliveCubes[pos.x][pos.y][pos.z] == 255 && _type != 255) || (_game.aliveCubes[pos.x][pos.y][pos.z] != 255 && _type == 255) { 
            _game.aliveCubes[pos.x][pos.y][pos.z] = _type
            chunkPos := Cube{i16(int(pos.x/16)),0,i16(int(pos.z/16))}
            //get the chunk pos
            rl.UnloadMesh(_game.meshes[chunkPos.x][chunkPos.z]) //there needs to be some thinking done here because it seems not everything is working correctly
            _game.meshes[chunkPos.x][chunkPos.z].vertices = nil
            _game.meshes[chunkPos.x][chunkPos.z].texcoords = nil
            genChunkModel(_game,chunkPos.x,0,chunkPos.z) 
        
        }
    }
}
updateWorld :: proc(_game :^Game) {
	chunkCamX := cast(i16)_game.cam.position.x/16
    chunkCamZ := cast(i16)_game.cam.position.z/16
    for x : i16 = chunkCamX-_game.renderDistance; x < _game.renderDistance+chunkCamX; x+=1 {
		for z : i16 = chunkCamZ-_game.renderDistance; z < _game.renderDistance+chunkCamZ; z+=1 {
			if (x>-1 && x < 64 && z > -1 && z < 64) {
				rl.DrawMesh(_game.meshes[x][z],_game.material,rl.MatrixTranslate(1,1,1))
				
				
			}
                
        }
    }
	updatePlayer(_game);
}
setupWorld :: proc(_game : ^Game) {
	
}
