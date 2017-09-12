#definition of warlpiris for ease.

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

#create a matrix that will be useful for testing purposes.
const wmatrix = [WP(a) → WP(b) for a in 0b0000:0b1111, b  in 0b0000:0b1111]

#=
  structure of wmatrix:

  [ 0b0000 → 0b0001 0b0000 → 0b0010 0b0000 → 0b0011 ... 0b0000 → 0b1111
    0b0001 → 0b0001 0b0001 → 0b0010 0b0001 → 0b0011 ... 0b0001 → 0b1111
    0b0010 → 0b0001 0b0010 → 0b0010 0b0010 → 0b0011 ... 0b0010 → 0b1111
    ...
    0b1111 → 0b0001 0b1111 → 0b0010 0b1111 → 0b0011 ... 0b1111 → 0b1111]
=#

#re-alias these numbers to make them even easier to read.
const W0_0 = WP0000 → WP0000
const W0_1 = WP0000 → WP0001
const W0_2 = WP0000 → WP0010
const W0_3 = WP0000 → WP0011
const W0_4 = WP0000 → WP0100
const W0_5 = WP0000 → WP0101
const W0_6 = WP0000 → WP0110
const W0_7 = WP0000 → WP0111
const W0_8 = WP0000 → WP1000
const W1_1 = WP0001 → WP0001
const W1_2 = WP0001 → WP0010
const W1_3 = WP0001 → WP0011
const W1_4 = WP0001 → WP0100
const W1_5 = WP0001 → WP0101
const W1_6 = WP0001 → WP0110
const W1_7 = WP0001 → WP0111
const W1_8 = WP0001 → WP1000
const W2_2 = WP0010 → WP0010
const W2_3 = WP0010 → WP0011
const W2_4 = WP0010 → WP0100
const W2_5 = WP0010 → WP0101
const W2_6 = WP0010 → WP0110
const W2_7 = WP0010 → WP0111
const W2_8 = WP0010 → WP1000
const W3_3 = WP0011 → WP0011
const W3_4 = WP0011 → WP0100
const W3_5 = WP0011 → WP0101
const W3_6 = WP0011 → WP0110
const W3_7 = WP0011 → WP0111
const W3_8 = WP0011 → WP1000
const W4_4 = WP0100 → WP0100
const W4_5 = WP0100 → WP0101
const W4_6 = WP0100 → WP0110
const W4_7 = WP0100 → WP0111
const W4_8 = WP0100 → WP1000
const W5_5 = WP0101 → WP0101
const W5_6 = WP0101 → WP0110
const W5_7 = WP0101 → WP0111
const W5_8 = WP0101 → WP1000
const W6_6 = WP0110 → WP0110
const W6_7 = WP0110 → WP0111
const W6_8 = WP0110 → WP1000
const W7_7 = WP0111 → WP0111
const W7_8 = WP0111 → WP1000
const W8_8 = WP1000 → WP1000
const WALL = W(ℝp)
const WNUL = W(∅)

const pos_warlpiri = [W0_0, W0_1, W0_2, W0_3, W0_4, W0_5, W0_6, W0_7, W0_8, W1_1, W1_2, W1_3, W1_4, W1_5, W1_6, W1_7, W1_8, W2_2, W2_3, W2_4, W2_5, W2_6, W2_7, W2_8, W3_3, W3_4, W3_5, W3_6, W3_7, W3_8, W4_4, W4_5, W4_6, W4_7, W4_8, W5_5, W5_6, W5_7, W5_8, W6_6, W6_7, W6_8, W7_7, W7_8, W8_8]
