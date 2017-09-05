#warlpiri-test.jl

#tests using the "modified warlpiri" numbers
W = Valid{4,0}
WP = Vnum{4,0}

const WP0000 = WP(0b0000)
const WP0001 = WP(0b0001)
const WP0010 = WP(0b0010)
const WP0011 = WP(0b0011)
const WP0100 = WP(0b0100)
const WP0101 = WP(0b0101)
const WP0110 = WP(0b0110)
const WP0111 = WP(0b0111)
const WP1000 = WP(0b1000)
const WP1001 = WP(0b1001)
const WP1010 = WP(0b1010)
const WP1011 = WP(0b1011)
const WP1100 = WP(0b1100)
const WP1101 = WP(0b1101)
const WP1110 = WP(0b1110)
const WP1111 = WP(0b1111)

#make sure our representations are accurate.
@test describe(WP0000, identity) == "Vnum{4,0}(0.0 ex)"
@test describe(WP0001, identity) == "Vnum{4,0}(0.0 op → 0.5 op)"
@test describe(WP0010, identity) == "Vnum{4,0}(0.5 ex)"
@test describe(WP0011, identity) == "Vnum{4,0}(0.5 op → 1.0 op)"
@test describe(WP0100, identity) == "Vnum{4,0}(1.0 ex)"
@test describe(WP0101, identity) == "Vnum{4,0}(1.0 op → 2.0 op)"
@test describe(WP0110, identity) == "Vnum{4,0}(2.0 ex)"
@test describe(WP0111, identity) == "Vnum{4,0}(2.0 op → Inf op)"
@test describe(WP1000, identity) == "Vnum{4,0}(Inf ex)"
@test describe(WP1001, identity) == "Vnum{4,0}(Inf op → -2.0 op)"
@test describe(WP1010, identity) == "Vnum{4,0}(-2.0 ex)"
@test describe(WP1011, identity) == "Vnum{4,0}(-2.0 op → -1.0 op)"
@test describe(WP1100, identity) == "Vnum{4,0}(-1.0 ex)"
@test describe(WP1101, identity) == "Vnum{4,0}(-1.0 op → -0.5 op)"
@test describe(WP1110, identity) == "Vnum{4,0}(-0.5 ex)"
@test describe(WP1111, identity) == "Vnum{4,0}(-0.5 op → 0.0 op)"

@test describe(WP0000 → WP0000, identity) == "Valid{4,0}(0.0 ex)"
@test describe(WP0000 → WP0001, identity) == "Valid{4,0}(0.0 ex → 0.5 op)"
@test describe(WP0000 → WP0010, identity) == "Valid{4,0}(0.0 ex → 0.5 ex)"
@test describe(WP0000 → WP0011, identity) == "Valid{4,0}(0.0 ex → 1.0 op)"
@test describe(WP0000 → WP0100, identity) == "Valid{4,0}(0.0 ex → 1.0 ex)"
@test describe(WP0000 → WP0101, identity) == "Valid{4,0}(0.0 ex → 2.0 op)"
@test describe(WP0000 → WP0110, identity) == "Valid{4,0}(0.0 ex → 2.0 ex)"
@test describe(WP0000 → WP0111, identity) == "Valid{4,0}(ℝ(+))"
@test describe(WP0000 → WP1000, identity) == "Valid{4,0}(0.0 ex → Inf ex)"

@test describe(WP0001 → WP0001, identity) == "Valid{4,0}(0.0 op → 0.5 op)"
@test describe(WP0001 → WP0010, identity) == "Valid{4,0}(0.0 op → 0.5 ex)"
@test describe(WP0001 → WP0011, identity) == "Valid{4,0}(0.0 op → 1.0 op)"
@test describe(WP0001 → WP0100, identity) == "Valid{4,0}(0.0 op → 1.0 ex)"
@test describe(WP0001 → WP0101, identity) == "Valid{4,0}(0.0 op → 2.0 op)"
@test describe(WP0001 → WP0110, identity) == "Valid{4,0}(0.0 op → 2.0 ex)"
@test describe(WP0001 → WP0111, identity) == "Valid{4,0}(ℝ(+*))"
@test describe(WP0001 → WP1000, identity) == "Valid{4,0}(0.0 op → Inf ex)"

#special symbols
@test describe(WP1001 → WP0000, identity) == "Valid{4,0}(ℝ(-))"
@test describe(WP1001 → WP1111, identity) == "Valid{4,0}(ℝ(-*))"
@test describe(WP1001 → WP0111, identity) == "Valid{4,0}(ℝ)"
@test describe(WP1000 → WP0111, identity) == "Valid{4,0}(ℝp)"
@test describe(WP0000 → WP1111, identity) == "Valid{4,0}(∅)"

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
