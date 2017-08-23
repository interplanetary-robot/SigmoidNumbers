
################################################# {BITS,ES} #### RSH HEX VALUE ########## NEG ## INV # EXP ## RSH FRAC VALUE #### UBIT ##
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x4000)) == (false, false, 0, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x4000)) == (false, false, 0, 0x0000_0000_0000_0000, false)
#0b0_10_1_000000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x5000)) == (false, false, 1, 0x0000_0000_0000_0000, false)
#0b0_10_1_100000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x5800)) == (false, false, 1, 0x8000_0000_0000_0000, false)
#0b0_110_0_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6000)) == (false, false, 2, 0x0000_0000_0000_0000, false)
#0b0_110_0_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6400)) == (false, false, 2, 0x8000_0000_0000_0000, false)
#0b0_110_1_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6800)) == (false, false, 3, 0x0000_0000_0000_0000, false)
#0b0_110_1_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x6C00)) == (false, false, 3, 0x8000_0000_0000_0000, false)
#0b0_1110_0_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x7000)) == (false, false, 4, 0x0000_0000_0000_0000, false)
#0b0_111111111111111
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x7FFF)) == (false, false, 28, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFF)) == (false, false, 56, 0x0000_0000_0000_0000, false)
#0b0_111111111111110
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFE)) == (false, false, 52, 0x0000_0000_0000_0000, false)
#0b0_111111111111101[0]
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFD)) == (false, false, 50, 0x0000_0000_0000_0000, false)
#0b0_1111111111110_00
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x7FFD)) == (false, false, 50, 0x0000_0000_0000_0000, false)

#repeat some of these tests with valid numbers
#0b0_10_1_00000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x5001)) == (false, false, 1, 0x0000_0000_0000_0000, true)
#0b0_110_1_0000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x6801)) == (false, false, 3, 0x0000_0000_0000_0000, true)
#0b0_11111111111111_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x7FFF)) == (false, false, 26, 0x0000_0000_0000_0000, true)

#repeat these tests, except with inverted numbers
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x2000)) == (false, true, -1, 0x0000_0000_0000_0000, false)
#0b0_01_0000000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x3000)) == (false, true, -1, 0x8000_0000_0000_0000, false)
#0b0_01_1000000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x1000)) == (false, true, -2, 0x0000_0000_0000_0000, false)
#0b0_000000000000001
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0x0001)) == (false, true, -14, 0x0000_0000_0000_0000, false)
#0b0_01_0_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x2000)) == (false, true, -2, 0x0000_0000_0000_0000, false)
#0b0_01_1_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x3000)) == (false, true, -1, 0x0000_0000_0000_0000, false)
#0b0_01_00_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x2000)) == (false, true, -4, 0x0000_0000_0000_0000, false)
#0b0_01_01_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x2800)) == (false, true, -3, 0x0000_0000_0000_0000, false)
#0b0_01_10_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x3000)) == (false, true, -2, 0x0000_0000_0000_0000, false)
#0b0_01_11_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x3800)) == (false, true, -1, 0x0000_0000_0000_0000, false)
#0b0_0000000000001_0
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x0002)) == (false, true, -52, 0x0000_0000_0000_0000, false)
#0b0_0000000000001_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x0003)) == (false, true, -50, 0x0000_0000_0000_0000, false)

#and now with valids
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,0}(0x2000)) == (false, true, -1, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,0}(0x2001)) == (false, true, -1, 0x0000_0000_0000_0000, true)
#and then go really extreme.
#0b0_0000000000001_0
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x0002)) == (false, true, -26, 0x0000_0000_0000_0000, false)
#0b0_0000000000001_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x0003)) == (false, true, -26, 0x0000_0000_0000_0000, true)
#semantically different due to the a higher ES
#0b0_0000000000001_0
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,2}(0x0002)) == (false, true, -52, 0x0000_0000_0000_0000, false)
#0b0_0000000000001_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,2}(0x0003)) == (false, true, -52, 0x0000_0000_0000_0000, true)

## all these tests, but with negative numbers.
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,0}(0xC000)) == (true, false, 0, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0xC000)) == (true, false, 0, 0x0000_0000_0000_0000, false)
#0b0_10_1_000000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0xB000)) == (true, false, 1, 0x0000_0000_0000_0000, false)
#0b0_10_1_100000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0xA800)) == (true, false, 1, 0x8000_0000_0000_0000, false)
#0b0_110_0_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0xA000)) == (true, false, 2, 0x0000_0000_0000_0000, false)
#0b0_110_0_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x9C00)) == (true, false, 2, 0x8000_0000_0000_0000, false)
#0b0_110_1_00000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x9800)) == (true, false, 3, 0x0000_0000_0000_0000, false)
#0b0_110_1_10000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x9400)) == (true, false, 3, 0x8000_0000_0000_0000, false)
#0b0_1110_0_0000000000
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x9000)) == (true, false, 4, 0x0000_0000_0000_0000, false)
#0b0_111111111111111
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,1}(0x8001)) == (true, false, 28, 0x0000_0000_0000_0000, false)
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x8001)) == (true, false, 56, 0x0000_0000_0000_0000, false)
#0b0_111111111111110
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x8002)) == (true, false, 52, 0x0000_0000_0000_0000, false)
#0b0_111111111111101[0]
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x8003)) == (true, false, 50, 0x0000_0000_0000_0000, false)
#0b0_1111111111110_00
@test SigmoidNumbers.__numeric_breakdown_wrapper(Posit{16,2}(0x8003)) == (true, false, 50, 0x0000_0000_0000_0000, false)


#repeat some of these tests with valid numbers
#0b0_10_1_00000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0xAFFF)) == (true, false, 1, 0x0000_0000_0000_0000, true)
#0b0_110_1_0000000000_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x97FF)) == (true, false, 3, 0x0000_0000_0000_0000, true)
#0b0_11111111111111_1
@test SigmoidNumbers.__numeric_breakdown_wrapper(Vnum{16,1}(0x8001)) == (true, false, 26, 0x0000_0000_0000_0000, true)
