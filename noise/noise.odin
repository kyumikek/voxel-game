package noise
import "core:math"
import rl"../raylib"
fade :: proc(t : f32) -> f32 {
    return t * t * t * (t * (t * 6 - 15) + 10)
}
lerp :: proc(t : f32, a : f32, b : f32) -> f32 {
    return a + t * (b - a)
}
grad :: proc(hash : int, x : f32, y : f32, z : f32) -> f32 {
    h := hash & 15  //# Take the last 4 bits of the hash
    u : f32
    v : f32
    if h < 8 {
        u = x
    }
    else {
        u = y
    }
    if (h<4) {
        v = y
    }
    else {
        v = z
        if (h==12 || h==14) {
            v = x
        }
    }
    return ((u if (h & 1) == 0 else -u) +
            (v if (h & 2) == 0 else -v))
}
init_permutation :: proc() -> []int {
    p_perm := [256]int{};
    for i : int = 0; i < 256; i+=1 {
        p_perm[i] = int(rl.GetRandomValue(0,256))
    }

    p := make([]int, 512)

    for i in 0..<256 {
        p[256+i] = p_perm[i]
        p[i] = p_perm[i]
    }

    return p
}
perlin :: proc(x: f32, y: f32, z: f32, p: []int) -> f32 {
    X := int(math.floor(x)) & 255
    Y := int(math.floor(y)) & 255
    Z := int(math.floor(z)) & 255

    fx: f32 = x - f32(int(x))
    fy: f32 = y - f32(int(y))
    fz: f32 = z - f32(int(z))

    u := fade(fx)
    v := fade(fy)
    w := fade(fz)

    A := p[X] + Y
    AA := p[A] + Z
    AB := p[A + 1] + Z
    B := p[X + 1] + Y
    BA := p[B] + Z
    BB := p[B + 1] + Z

    return lerp(w,
        lerp(v,
            lerp(u, grad(p[AA], fx, fy, fz), grad(p[BA], fx-1, fy, fz)),
            lerp(u, grad(p[AB], fx, fy-1, fz), grad(p[BB], fx-1, fy-1, fz))
        ),
        lerp(v,
            lerp(u, grad(p[AA + 1], fx, fy, fz-1), grad(p[BA + 1], fx-1, fy, fz-1)),
            lerp(u, grad(p[AB + 1], fx, fy-1, fz-1), grad(p[BB + 1], fx-1, fy-1, fz-1))
        )
    )
}