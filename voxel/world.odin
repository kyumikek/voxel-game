package voxel
import rl "../raylib"
import noise "../noise"
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
            genChunkModel(_game,chunkPos.x,0,chunkPos.z, _game.texture) 
        
        }
    }
}

setupWorld :: proc(_game : ^Game) {

}