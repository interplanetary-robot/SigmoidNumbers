
M7 = Posit{7,0}
M7_1 = Posit{7,1}
M7_2 = Posit{7,2}

@test M7_1(0b0000000)   == M7_1(0.0)
@test M7_1(0b0000001)   == M7_1(0.0009765625)
@test M7_1(0b000001_0)  == M7_1(0.00390625)
@test M7_1(0b000001_1)  == M7_1(0.0078125)
@test M7_1(0b00001_0_0) == M7_1(0.015625)
@test M7_1(0b00001_0_1) == M7_1(0.0234375)
@test M7_1(0b00001_1_0) == M7_1(0.03125)
@test M7_1(0b00001_1_1) == M7_1(0.046875)
@test M7_1(0b0001_0_00) == M7_1(0.0625)
@test M7_1(0b0001_0_01) == M7_1(0.078125)
@test M7_1(0b0001_0_10) == M7_1(0.09375)
@test M7_1(0b0001_0_11) == M7_1(0.109375)
@test M7_1(0b0001_1_00) == M7_1(0.125)
@test M7_1(0b0001_1_01) == M7_1(0.15625)
@test M7_1(0b0001_1_10) == M7_1(0.1875)
@test M7_1(0b0001_1_11) == M7_1(0.21875)
@test M7_1(0b001_0_000) == M7_1(0.25)
@test M7_1(0b001_0_001) == M7_1(0.28125)
@test M7_1(0b001_0_010) == M7_1(0.3125)
@test M7_1(0b001_0_011) == M7_1(0.34375)
@test M7_1(0b001_0_100) == M7_1(0.375)
@test M7_1(0b001_0_101) == M7_1(0.40625)
@test M7_1(0b001_0_110) == M7_1(0.4375)
@test M7_1(0b001_0_111) == M7_1(0.46875)
@test M7_1(0b001_1_000) == M7_1(0.5)
@test M7_1(0b001_1_001) == M7_1(0.5625)
@test M7_1(0b001_1_010) == M7_1(0.625)
@test M7_1(0b001_1_011) == M7_1(0.6875)
@test M7_1(0b001_1_100) == M7_1(0.75)
@test M7_1(0b001_1_101) == M7_1(0.8125)
@test M7_1(0b001_1_110) == M7_1(0.875)
@test M7_1(0b001_1_111) == M7_1(0.9375)
@test M7_1(0b010_0_000) == M7_1(1.0)
@test M7_1(0b010_0_001) == M7_1(1.125)
@test M7_1(0b010_0_010) == M7_1(1.25)
@test M7_1(0b010_0_011) == M7_1(1.375)
@test M7_1(0b010_0_100) == M7_1(1.5)
@test M7_1(0b010_0_101) == M7_1(1.625)
@test M7_1(0b010_0_110) == M7_1(1.75)
@test M7_1(0b010_0_111) == M7_1(1.875)
@test M7_1(0b010_1_000) == M7_1(2.0)
@test M7_1(0b010_1_001) == M7_1(2.25)
@test M7_1(0b010_1_010) == M7_1(2.5)
@test M7_1(0b010_1_011) == M7_1(2.75)
@test M7_1(0b010_1_100) == M7_1(3.0)
@test M7_1(0b010_1_101) == M7_1(3.25)
@test M7_1(0b010_1_110) == M7_1(3.5)
@test M7_1(0b010_1_111) == M7_1(3.75)
@test M7_1(0b0110_0_00) == M7_1(4.0)
@test M7_1(0b0110_0_01) == M7_1(5.0)
@test M7_1(0b0110_0_10) == M7_1(6.0)
@test M7_1(0b0110_0_11) == M7_1(7.0)
@test M7_1(0b0110_1_00) == M7_1(8.0)
@test M7_1(0b0110_1_01) == M7_1(10.0)
@test M7_1(0b0110_1_10) == M7_1(12.0)
@test M7_1(0b0110_1_11) == M7_1(14.0)
@test M7_1(0b01110_0_0) == M7_1(16.0)
@test M7_1(0b01110_0_1) == M7_1(24.0)
@test M7_1(0b01110_1_0) == M7_1(32.0)
@test M7_1(0b01110_1_1) == M7_1(48.0)
@test M7_1(0b011110_0)  == M7_1(64.0)
@test M7_1(0b011110_1)  == M7_1(128.0)
@test M7_1(0b0111110)   == M7_1(256.0)
@test M7_1(0b0111111)   == M7_1(1024.0)

@test M7_2(0b0000000)   == M7_2(0.0)
@test M7_2(0b0000001)   == M7_2(0.00000095367431640625)
@test M7_2(0b000001_0)  == M7_2(0.0000152587890625)
@test M7_2(0b000001_1)  == M7_2(0.00006103515625)
@test M7_2(0b00001_00)  == M7_2(0.000244140625)
@test M7_2(0b00001_01)  == M7_2(0.00048828125)
@test M7_2(0b00001_10)  == M7_2(0.0009765625)
@test M7_2(0b00001_11)  == M7_2(0.001953125)
@test M7_2(0b0001_00_0) == M7_2(0.00390625)
@test M7_2(0b0001_00_1) == M7_2(0.005859375)
@test M7_2(0b0001_01_0) == M7_2(0.0078125)
@test M7_2(0b0001_01_1) == M7_2(0.01171875)
@test M7_2(0b0001_10_0) == M7_2(0.015625)
@test M7_2(0b0001_10_1) == M7_2(0.0234375)
@test M7_2(0b0001_11_0) == M7_2(0.03125)
@test M7_2(0b0001_11_1) == M7_2(0.046875)
@test M7_2(0b001_00_00) == M7_2(0.0625)
@test M7_2(0b001_00_01) == M7_2(0.078125)
@test M7_2(0b001_00_10) == M7_2(0.09375)
@test M7_2(0b001_00_11) == M7_2(0.109375)
@test M7_2(0b001_01_00) == M7_2(0.125)
@test M7_2(0b001_01_01) == M7_2(0.15625)
@test M7_2(0b001_01_10) == M7_2(0.1875)
@test M7_2(0b001_01_11) == M7_2(0.21875)
@test M7_2(0b001_10_00) == M7_2(0.25)
@test M7_2(0b001_10_01) == M7_2(0.3125)
@test M7_2(0b001_10_10) == M7_2(0.375)
@test M7_2(0b001_10_11) == M7_2(0.4375)
@test M7_2(0b001_11_00) == M7_2(0.5)
@test M7_2(0b001_11_01) == M7_2(0.625)
@test M7_2(0b001_11_10) == M7_2(0.75)
@test M7_2(0b001_11_11) == M7_2(0.875)
@test M7_2(0b010_00_00) == M7_2(1.0)
@test M7_2(0b010_00_01) == M7_2(1.25)
@test M7_2(0b010_00_10) == M7_2(1.5)
@test M7_2(0b010_00_11) == M7_2(1.75)
@test M7_2(0b010_01_00) == M7_2(2.0)
@test M7_2(0b010_01_01) == M7_2(2.5)
@test M7_2(0b010_01_10) == M7_2(3.0)
@test M7_2(0b010_01_11) == M7_2(3.5)
@test M7_2(0b010_10_00) == M7_2(4.0)
@test M7_2(0b010_10_01) == M7_2(5.0)
@test M7_2(0b010_10_10) == M7_2(6.0)
@test M7_2(0b010_10_11) == M7_2(7.0)
@test M7_2(0b010_11_00) == M7_2(8.0)
@test M7_2(0b010_11_01) == M7_2(10.0)
@test M7_2(0b010_11_10) == M7_2(12.0)
@test M7_2(0b010_11_11) == M7_2(14.0)
@test M7_2(0b0110_00_0) == M7_2(16.0)
@test M7_2(0b0110_00_1) == M7_2(24.0)
@test M7_2(0b0110_01_0) == M7_2(32.0)
@test M7_2(0b0110_01_1) == M7_2(48.0)
@test M7_2(0b0110_10_0) == M7_2(64.0)
@test M7_2(0b0110_10_1) == M7_2(96.0)
@test M7_2(0b0110_11_0) == M7_2(128.0)
@test M7_2(0b0110_11_1) == M7_2(192.0)
@test M7_2(0b01110_00)  == M7_2(256.0)
@test M7_2(0b01110_01)  == M7_2(512.0)
@test M7_2(0b01110_10)  == M7_2(1024.0)
@test M7_2(0b01110_11)  == M7_2(2048.0)
@test M7_2(0b011110_0)  == M7_2(4096.0)
@test M7_2(0b011110_1)  == M7_2(16384.0)
@test M7_2(0b0111110)   == M7_2(65536.0)
@test M7_2(0b0111111)   == M7_2(1048576.0)

#test cross-conversions.
for tile in M7_1
  @test tile == M7_1(Float64(tile))
end

for tile in M7_2
  @test tile == M7_2(Float64(tile))
end

#and a general purpose function for testing an operation against a matrix
function testop(op, iterable; exceptions = [])
  fails = 0
  totalsize = length(iterable) * length(iterable)
  for STile1 in iterable, STile2 in iterable
    fval1 = Float64(STile1)
    fval2 = Float64(STile2)

    texp = op(fval1, fval2)

    if isnan(texp) || (length(exceptions) > 0) && ([fval1, fval2] == exceptions) #catch NaN values.
      ok::Bool = false
      try
        op(STile1, STile2)
      catch e
        ok = isa(e, SigmoidNumbers.NaNError)
      end
      if !ok
        println("$iterable: $(fval1) $op $(fval2) failed to trap as NaN")
        fails += 1
      end
      continue
    end

    exp = iterable(texp)
    fexp = Float64(exp)

    res = op(STile1, STile2)
    fres = Float64(res)

    if (exp != res)
      println("$iterable: $(fval1) $op $(fval2) failed as $(fres); should be $(fexp)")
      fails += 1
    end

  end
  println("$iterable: $op $fails / $(totalsize) = $(100 * fails/totalsize)% failure!")
end

testop(+, M7, exceptions = [Inf, Inf])
testop(-, M7, exceptions = [Inf, Inf])
testop(*, M7)
testop(/, M7)

testop(+, M7_1, exceptions = [Inf, Inf])
testop(-, M7_1, exceptions = [Inf, Inf])
testop(*, M7_1)
testop(/, M7_1)

testop(+, M7_2, exceptions = [Inf, Inf])
testop(-, M7_2, exceptions = [Inf, Inf])
testop(*, M7_2)
testop(/, M7_2)
