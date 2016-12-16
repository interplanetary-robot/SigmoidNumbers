import Base: *

function *{N}(lhs::MLSigmoid{N}, rhs::MLSigmoid{N})
  #adding infinities is infinite.
  isfinite(lhs) || return reinterpret(MLSigmoid{N}, @signbit)
  isfinite(rhs) || return reinterpret(MLSigmoid{N}, @signbit)
  #adding zeros is zero
  iszero(lhs) && return reinterpret(MLSigmoid{N}, zero(@UInt))
  iszero(rhs) && return reinterpret(MLSigmoid{N}, zero(@UInt))

  #generate the lhs and rhs subcomponents.
  @breakdown lhs arithmetic
  @breakdown rhs arithmetic

  #sign is the xor of both signs.
  mul_sgn = lhs_sgn $ rhs_sgn

  #the multiplicative exponent is the product of the two exponents.
  mul_exp = lhs_exp + rhs_exp

  #then calculate the fraction.
  mul_frc = demote(promote(lhs_frc) * promote(rhs_frc))

  #if mul_exp > 0
    shift = min(leading_zeros(mul_frc) - 1, mul_exp)
    mul_frc <<= shift + 1
    mul_exp -= shift
  #end

  build_arithmetic(MLSigmoid{N}, mul_sgn, mul_exp, mul_frc)
end
