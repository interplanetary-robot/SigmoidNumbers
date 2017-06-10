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
for test_val = 0x01:0xff
  set!(test_q, Posit{8,1}(test_val))
  @test Posit{8,1}(test_val) == Posit{8,1}(test_q)
end

#test that the quire fixed point array has the correct values.
for test_val = 0x01:0xff
  println("===============")
  println(hex(test_val,2))
  println("---------------")
  set!(test_q, Posit{8,1}(test_val))
  println(hex(test_q.fixed_point_value[33],16))
  println(hex(test_q.fixed_point_value[32],16))
  println(test_q.train1_pos)
  println(test_q.train1_len)
  prefix_val = 2.0^(test_q.train1_pos + 1) - 2.0^(test_q.train1_pos - test_q.train1_len + 1)
  println(prefix_val)
  test_f = test_q.fixed_point_value[33] + ((test_q.fixed_point_value[32] >> 56) / 256.0) + prefix_val
  @test Float64(Posit{8,1}(test_val)) == test_f
end


#=
#next test that adding two posits into a quire works fine.
test_q = Quire(Posit{8,1})
for test_x = 0x00:0xff
  for test_y = 0x00:0xff
    px = Posit{8,1}(test_x)
    py = Posit{8,1}(test_y)
    set!(test_q, px)
    @test add!(test_q, py) == px + py
  end
end
=#
