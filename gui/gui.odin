package odin
import rl"../raylib"
updateButton :: proc(x : i32, y : i32, width : i32, height : i32, color : rl.Color) {
    rl.DrawRectangle(x,y,width,height,color);
}