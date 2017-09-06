#warlpiri-test.jl

include("warlpiri-def.jl")
include("warlpiri-properties.jl")
include("warlpiri-hlayer.jl")

#test basic inversion
@test -(WP0000 → WP0000) == (WP0000 →  WP0000)
@test -(WP0000 → WP0001) == (WP1111 →  WP0000)
@test -(WP0000 → WP0010) == (WP1110 →  WP0000)
@test -(WP0000 → WP0011) == (WP1101 →  WP0000)
@test -(WP0000 → WP0100) == (WP1100 →  WP0000)
@test -(WP0000 → WP0101) == (WP1011 →  WP0000)
@test -(WP0000 → WP0110) == (WP1010 →  WP0000)
@test -(WP0000 → WP0111) == (WP1001 →  WP0000)
@test -(WP0000 → WP1000) == (WP1000 →  WP0000)

#test basic multiplicative inversion
@test /(WP0000 → WP0000) == (WP1000 →  WP1000)
@test /(WP0000 → WP0001) == (WP0111 →  WP1000)
@test /(WP0000 → WP0010) == (WP0110 →  WP1000)
@test /(WP0000 → WP0011) == (WP0101 →  WP1000)
@test /(WP0000 → WP0100) == (WP0100 →  WP1000)
@test /(WP0000 → WP0101) == (WP0011 →  WP1000)
@test /(WP0000 → WP0110) == (WP0010 →  WP1000)
@test /(WP0000 → WP0111) == (WP0001 →  WP1000)
@test /(WP0000 → WP1000) == (WP0000 →  WP1000)
