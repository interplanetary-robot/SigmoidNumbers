#testing the fused dot product

#test constructing a posit from the following tuple:

# a helper function.
# (sign::bool, exponent::Int64, fraction::UInt64)
# relevant formula:  value = ((-1) ^ sign) * (2 ^ exp) + (2^exp) * (fraction / 2^(64))
function float_4_component(sign::Bool, exp::Int64, frac::UInt64)
  ((-1)^sign) * (2.0^exp) + frac * (2.0^(exp - 64 - sign))
end
#test float_construction
@test float_4_component(false, 0, 0x0000_0000_0000_0000) == 1.0
@test float_4_component(false, 0, 0x8000_0000_0000_0000) == 1.5
@test float_4_component(false, 1, 0x0000_0000_0000_0000) == 2.0
@test float_4_component(false, 1, 0x8000_0000_0000_0000) == 3.0
@test float_4_component(false, -1, 0x0000_0000_0000_0000) == 0.5
@test float_4_component(false, -1, 0x8000_0000_0000_0000) == 0.75

@test float_4_component(true, 0, 0x0000_0000_0000_0000) == -1.0
@test float_4_component(true, 0, 0x8000_0000_0000_0000) == -0.75
@test float_4_component(true, 1, 0x0000_0000_0000_0000) == -2.0
@test float_4_component(true, 1, 0x8000_0000_0000_0000) == -1.5
@test float_4_component(true, -1, 0x0000_0000_0000_0000) == -0.5
@test float_4_component(true, -1, 0x8000_0000_0000_0000) == -0.375

#test a fixed point construction.
float_4_fixed(data::UInt8) = reinterpret(Int8, data) / 16.0

@test float_4_fixed(0b0001_0000) == 1.0
@test float_4_fixed(0b0001_1000) == 1.5
@test float_4_fixed(0b0010_0000) == 2.0
@test float_4_fixed(0b0011_0000) == 3.0
@test float_4_fixed(0b0000_1000) == 0.5
@test float_4_fixed(0b0000_1100) == 0.75

@test float_4_fixed(0b1111_0000) == -1.0
@test float_4_fixed(0b1111_0100) == -0.75
@test float_4_fixed(0b1110_0000) == -2.0
@test float_4_fixed(0b1110_1000) == -1.5
@test float_4_fixed(0b1111_1000) == -0.5
@test float_4_fixed(0b1111_1010) == -0.375

#test breaking up a fixed point construction as the descriptive components.
function component_4_fixed(data::UInt8)
  if (data & 0x80) != 0
    #then we're negative.  Meaure exponent by counting leading ones.
    lo = leading_ones(data)
    exponent = 4 - lo
    fraction = UInt64(data << (lo + 1)) << 56
    (true, exponent, fraction)
  else
    #else we're positive
    lz = leading_zeros(data)
    exponent = 3 - lz
    fraction = UInt64(data << (lz + 1)) << 56
    (false, exponent, fraction)
  end
end

#comprehensively test that fixed breakup correctly generates the desired value (except for zero)
for test_val = 0x01:0xff
  @test (float_4_component(component_4_fixed(test_val)...), test_val) == (float_4_fixed(test_val), test_val)
end

#comprehensively test that fixed breakup correctly generates the desired value (except for zero)
for test_val = 0x01:0xff
  @test (Posit{8,0}(component_4_fixed(test_val)...), test_val) == (Posit{8,0}(float_4_fixed(test_val)), test_val)
end

for test_val = 0x01:0xff
  @test (Posit{8,1}(component_4_fixed(test_val)...), test_val) == (Posit{8,1}(float_4_fixed(test_val)), test_val)
end

#test breaking up a posit into descriptive elements.
for test_val = 0x01:0xff
  if (test_val != 0x80)
    @test Posit{8,1}(SigmoidNumbers.posit_components(Posit{8,1}(test_val))...) == Posit{8,1}(test_val)
  end
end

#test loading a posit into a new quire and pulling it back out.
test_q = Quire(Posit{8,1})
for test_val = 0x00:0xff
  set!(test_q, Posit{8,1}(test_val))
  @test Posit{8,1}(test_val) == Posit{8,1}(test_q)
end

#test loading a posit into a new quire and pulling it back out in 32 bits
for idx = 1:10000
  test_val = rand(UInt32)
  set!(test_q, Posit{32,2}(test_val))
  @test Posit{32,2}(test_val) == Posit{32,2}(test_q)
end

################################################################################
# test adding two 32-bit posits.

for test_val1 = 0x00:0xff, test_val2 = 0x00:0xff

  (test_val1 == 0x80 && test_val2 == 0x80) && continue

  p1 = Posit{8,1}(test_val1)
  p2 = Posit{8,1}(test_val2)

  set!(test_q, p1)
  add!(test_q, p2)

  @test (Float64(Posit{32,2}(test_q)), test_val1, test_val2) == (Float64(p1) + Float64(p2), test_val1, test_val2)
end

################################################################################
# test multiplying two 32-bit posits.

for test_val1 = 0x00:0xff, test_val2 = 0x00:0xff

  (test_val1 == 0x80 && test_val2 == 0x80) && continue

  p1 = Posit{8,1}(test_val1)
  p2 = Posit{8,1}(test_val2)

  SigmoidNumbers.zero!(test_q)
  fdp!(test_q, p1, p2)

  @test (Float64(Posit{32,2}(test_q)), test_val1, test_val2) == (Float64(p1) * Float64(p2), test_val1, test_val2)
end
