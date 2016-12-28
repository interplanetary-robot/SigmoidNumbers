import Base: *

*{N}(lhs::Bool, rhs::Posit{N}) = reinterpret(Posit{N}, @s(rhs) * lhs)
*{N}(lhs::Posit{N}, rhs::Bool) = reinterpret(Posit{N}, @s(lhs) * rhs)

function *{N}(lhs::Posit{N}, rhs::Posit{N})
  #multiplying infinities is infinite.
  isfinite(lhs) || return reinterpret(Posit{N}, @signbit)
  isfinite(rhs) || return reinterpret(Posit{N}, @signbit)
  #mulitplying zeros is zero
  iszero(lhs) && return reinterpret(Posit{N}, zero(@UInt))
  iszero(rhs) && return reinterpret(Posit{N}, zero(@UInt))

  #generate the lhs and rhs subcomponents.
  @breakdown lhs arithmetic
  @breakdown rhs arithmetic

  #sign is the xor of both signs.
  mul_sgn = lhs_sgn $ rhs_sgn

  #the multiplicative exponent is the product of the two exponents.
  mul_exp = lhs_exp + rhs_exp

  #then calculate the fraction.
  mul_frc = demote(promote(lhs_frc) * promote(rhs_frc))

  shift = min(leading_zeros(mul_frc) - 1, mul_exp)
  mul_frc <<= shift + 1
  mul_exp -= shift

  __round(build_arithmetic(Posit{N}, mul_sgn, mul_exp, mul_frc))
end

@generated function Base.:/{N}(lhs::Posit{N}, rhs::Posit{N})
  #calculate the number of rounds we should apply the goldschmidt method.
  rounds = Int(ceil(log(2,N))) + 1
  top_bit = promote(one(@UInt) << (__BITS - 1))
  bot_bit = (one(@UInt) << (__BITS - N - 1))
  quote
    #dividing infinities or by zero is infinite.
    isfinite(lhs) || return reinterpret(Posit{N}, @signbit)
    iszero(rhs) && return reinterpret(Posit{N}, @signbit)
    #dividing zeros or by infinity is zero
    isfinite(rhs) || return reinterpret(Posit{N}, zero(@UInt))
    iszero(lhs) && return reinterpret(Posit{N}, zero(@UInt))

    const cq_mask = promote(-one(@UInt))

    #generate the lhs and rhs subcomponents.  Unlike multiplication, however,
    #we want there to 'always be a hidden bit', so we should use the "numeric" method.
    @breakdown lhs numeric
    @breakdown rhs numeric

    #sign is the xor of both signs.
    div_sgn = lhs_sgn $ rhs_sgn

    #do something different if rhs_frc is zero.
    if rhs_frc == 0
      div_exp = lhs_exp * (lhs_inv ? - 1 : 1) - rhs_exp * (rhs_inv ? - 1 : 1)
      return __round(build_numeric(Posit{N}, div_sgn, div_exp, lhs_frc))
    end

    #the multiplicative exponent is the product of the two exponents.
    div_exp = lhs_exp * (lhs_inv ? - 1 : 1) - rhs_exp * (rhs_inv ? - 1 : 1) - 1

    #calculate the number of zeros in the solution.
    lhs_zeros = trailing_zeros(lhs_frc) - (__BITS - N)
    rhs_zeros = trailing_zeros(rhs_frc) - (__BITS - N)

    cumulative_quotient = promote(lhs_frc)
    cumulative_zpower   = promote(-rhs_frc) >> 1
    power_gain = 0

    #then calculate the fraction, using binomial goldschmidt.
    # binomial goldschmidt algorithm:  x ∈ [1, 2), y ∈ [0.5, 1)
    #   define z ≡ 1 - y ⇒ y == 1 - z.
    #   Note (1 - z)(1 + z)(1 + z^2)(1 + z^4) == (1 - z^2n) → 1
    for rd = 1:($rounds - 1)
      #update the quotient
      cumulative_quotient += ((cumulative_quotient * cumulative_zpower) >> __BITS) + cumulative_zpower
      cumulative_zpower = (cumulative_zpower ^ 2) >> __BITS
      shift = __BITS - leading_zeros(cumulative_quotient)
      if (shift > 0)
        cumulative_quotient &= cq_mask
        cumulative_quotient >>= 1
        power_gain += 1
        (shift == 2) && (cumulative_quotient |= $top_bit)
      end
    end
    #update the cumulative quotient one last time.
    cumulative_quotient += ((cumulative_quotient * cumulative_zpower) >> __BITS) + cumulative_zpower
    shift = __BITS - leading_zeros(cumulative_quotient)
    if (shift > 0)
      cumulative_quotient &= cq_mask
      cumulative_quotient >>= 1
      power_gain += 1
      (shift == 2) && (cumulative_quotient |= $top_bit)
    end

    div_frc = demoteright(cumulative_quotient)

    result_ones = trailing_ones(div_frc >> (__BITS - N))

    if (result_ones + rhs_zeros == lhs_zeros + N + 1)
      #increment the lowest bit
      div_frc += $bot_bit
      #mask out all the other ones that were trailing.
      div_frc &= -$bot_bit
    end

    num = build_numeric(Posit{N}, div_sgn, div_exp + power_gain, div_frc)

    __round(build_numeric(Posit{N}, div_sgn, div_exp + power_gain, div_frc))
  end
end
