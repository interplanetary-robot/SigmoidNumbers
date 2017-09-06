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
