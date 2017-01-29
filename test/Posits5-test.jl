M5 = Posit{5, 0}

#begin comprehensive testing of conversion from Float64 -> M5
@test M5(0b10000) == M5(Inf)
@test M5(0b10001) == M5(-8.0)
@test M5(0b10010) == M5(-4.0)
@test M5(0b10011) == M5(-3.0)
@test M5(0b10100) == M5(-2.0)
@test M5(0b10101) == M5(-1.75)
@test M5(0b10110) == M5(-1.5)
@test M5(0b10111) == M5(-1.25)
@test M5(0b11000) == M5(-1.0)
@test M5(0b11001) == M5(-0.875)
@test M5(0b11010) == M5(-0.75)
@test M5(0b11011) == M5(-0.625)
@test M5(0b11100) == M5(-0.5)
@test M5(0b11101) == M5(-0.375)
@test M5(0b11110) == M5(-0.25)
@test M5(0b11111) == M5(-0.125)
@test M5(0b00000) == M5(0.0)
@test M5(0b00001) == M5(0.125)
@test M5(0b00010) == M5(0.25)
@test M5(0b00011) == M5(0.375)
@test M5(0b00100) == M5(0.5)
@test M5(0b00101) == M5(0.625)
@test M5(0b00110) == M5(0.75)
@test M5(0b00111) == M5(0.875)
@test M5(0b01000) == M5(1.0)
@test M5(0b01001) == M5(1.25)
@test M5(0b01010) == M5(1.5)
@test M5(0b01011) == M5(1.75)
@test M5(0b01100) == M5(2.0)
@test M5(0b01101) == M5(3.0)
@test M5(0b01110) == M5(4.0)
@test M5(0b01111) == M5(8.0)

#test overflowing.
@test M5(0b01111) == M5(10.0)
@test M5(0b01111) == M5(16.0)
@test M5(0b01111) == M5(12345678.9)
@test M5(0b00001) == M5(0.0001)

#test h-layer stuff
@test "10000" == bits(M5(Inf))
@test "10001" == bits(M5(-8.0))
@test "10010" == bits(M5(-4.0))
@test "10011" == bits(M5(-3.0))
@test "10100" == bits(M5(-2.0))
@test "10101" == bits(M5(-1.75))
@test "10110" == bits(M5(-1.5))
@test "10111" == bits(M5(-1.25))
@test "11000" == bits(M5(-1.0))
@test "11001" == bits(M5(-0.875))
@test "11010" == bits(M5(-0.75))
@test "11011" == bits(M5(-0.625))
@test "11100" == bits(M5(-0.5))
@test "11101" == bits(M5(-0.375))
@test "11110" == bits(M5(-0.25))
@test "11111" == bits(M5(-0.125))
@test "00000" == bits(M5(0.0))
@test "00001" == bits(M5(0.125))
@test "00010" == bits(M5(0.25))
@test "00011" == bits(M5(0.375))
@test "00100" == bits(M5(0.5))
@test "00101" == bits(M5(0.625))
@test "00110" == bits(M5(0.75))
@test "00111" == bits(M5(0.875))
@test "01000" == bits(M5(1.0))
@test "01001" == bits(M5(1.25))
@test "01010" == bits(M5(1.5))
@test "01011" == bits(M5(1.75))
@test "01100" == bits(M5(2.0))
@test "01101" == bits(M5(3.0))
@test "01110" == bits(M5(4.0))
@test "01111" == bits(M5(8.0))
#test going too far.

#test build_numeric

#test build_arithmetic
@test M5(3.0)  == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 1, 0xC000_0000_0000_0000)
@test M5(2.0)  == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 1, 0x8000_0000_0000_0000)
@test M5(1.5)  == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 0, 0xC000_0000_0000_0000)
@test M5(1.0)  == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 0, 0x8000_0000_0000_0000)
@test M5(0.75) == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 0, 0x6000_0000_0000_0000)
@test M5(0.5)  == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 0, 0x4000_0000_0000_0000)
@test M5(0.25) == SigmoidNumbers.build_arithmetic( SigmoidNumbers.SigmoidSmall{5,0,:guess}, false, 0, 0x2000_0000_0000_0000)
@test M5(-0.25) == SigmoidNumbers.build_arithmetic(SigmoidNumbers.SigmoidSmall{5,0,:guess}, true, 0, 0x2000_0000_0000_0000)
@test M5(-1.5)  == SigmoidNumbers.build_arithmetic(SigmoidNumbers.SigmoidSmall{5,0,:guess}, true, 0, 0xC000_0000_0000_0000)

#test cross-conversions.
for tile in M5
  @test tile == M5(Float64(tile))
end
