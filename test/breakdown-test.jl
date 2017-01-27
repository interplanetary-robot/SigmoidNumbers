
################################################# {BITS,ES} #### RSH HEX VALUE ########## NEG ## INV # EXP ## RSH FRAC VALUE #### UBIT ##
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x4000_0000_0000_0000)) == (false, false, 0, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x4000_0000_0000_0000)) == (false, false, 0, 0x0000_0000_0000_0000, false)
#0b0_10_1_000000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x5000_0000_0000_0000)) == (false, false, 1, 0x0000_0000_0000_0000, false)
#0b0_10_1_100000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x5800_0000_0000_0000)) == (false, false, 1, 0x8000_0000_0000_0000, false)
#0b0_110_0_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6000_0000_0000_0000)) == (false, false, 2, 0x0000_0000_0000_0000, false)
#0b0_110_0_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6400_0000_0000_0000)) == (false, false, 2, 0x8000_0000_0000_0000, false)
#0b0_110_1_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6800_0000_0000_0000)) == (false, false, 3, 0x0000_0000_0000_0000, false)
#0b0_110_1_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6C00_0000_0000_0000)) == (false, false, 3, 0x8000_0000_0000_0000, false)
#0b0_1110_0_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x7000_0000_0000_0000)) == (false, false, 4, 0x0000_0000_0000_0000, false)
#0b0_111111111111111
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x7FFF_0000_0000_0000)) == (false, false, 28, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFF_0000_0000_0000)) == (false, false, 56, 0x0000_0000_0000_0000, false)
#0b0_111111111111110
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFE_0000_0000_0000)) == (false, false, 52, 0x0000_0000_0000_0000, false)
#0b0_111111111111101[0]
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFD_0000_0000_0000)) == (false, false, 50, 0x0000_0000_0000_0000, false)
#0b0_1111111111110_00
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFD_0000_0000_0000)) == (false, false, 50, 0x0000_0000_0000_0000, false)

#repeat some of these tests with valid numbers
#0b0_10_1_00000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Valid{16,1}(0x5001_0000_0000_0000)) == (false, false, 1, 0x0000_0000_0000_0000, true)
#0b0_110_1_0000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Valid{16,1}(0x6801_0000_0000_0000)) == (false, false, 3, 0x0000_0000_0000_0000, true)
#0b0_11111111111111_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Valid{16,1}(0x7FFF_0000_0000_0000)) == (false, false, 26, 0x0000_0000_0000_0000, true)
