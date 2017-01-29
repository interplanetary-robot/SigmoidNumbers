import Base: +, -

@generated function +{N, ES, mode}(lhs::SigmoidSmall{N, ES, mode}, rhs::SigmoidSmall{N, ES, mode})
  if (ES == 0)
    breakdown = :(@breakdown lhs arithmetic; @breakdown rhs arithmetic)
    sub_algorithm = arithmetic_sub
    build_algorithm = build_arithmetic
  else
    breakdown = :(@breakdown lhs; @breakdown rhs)
    sub_algorithm = numeric_sub
    build_algorithm = build_numeric
  end

  quote
    #adding infinities is infinite.
    isfinite(lhs) || return SigmoidSmall{N, ES, mode}(Inf)
    isfinite(rhs) || return SigmoidSmall{N, ES, mode}(Inf)
    #adding zeros is identity.
    (reinterpret((@UInt), lhs) == zero(@UInt)) && return rhs
    (reinterpret((@UInt), rhs) == zero(@UInt)) && return lhs

    (reinterpret((@UInt), lhs) == -reinterpret((@UInt), rhs)) && return zero(SigmoidSmall{N, ES, mode})

    $breakdown

    if (lhs_sgn != rhs_sgn)

      (dif_sgn, dif_exp, dif_frc) = $sub_algorithm(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)

      if ((dif_frc & @signbit) == 0) && (dif_exp > 0)
        dif_exp -= 1
        dif_frc <<= 1
      end

      __round($build_algorithm(SigmoidSmall{N, ES, mode}, dif_sgn, dif_exp, dif_frc))
    else
      (sum_exp, sum_frc) = add_algorithm(lhs_exp, lhs_frc, rhs_exp, rhs_frc)

      __round($build_algorithm(SigmoidSmall{N, ES, mode}, lhs_sgn, sum_exp, sum_frc))
    end
  end
end

-{N, ES, mode}(operand::SigmoidSmall{N, ES, mode}) = reinterpret(SigmoidSmall{N, ES, mode}, -@s(operand))
-{N, ES, mode}(lhs::SigmoidSmall{N, ES, mode}, rhs::SigmoidSmall{N, ES, mode}) = lhs + (-rhs)

function arithmetic_sub(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)
  ## assign top and bottom fractions, ascertain the final sign, and set the
  ## exponential realm.

  if (lhs_exp > rhs_exp)
    top_frc = lhs_frc
    bot_frc = rhs_frc >> (lhs_exp - rhs_exp)
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  elseif (rhs_exp > lhs_exp)
    top_frc = rhs_frc
    bot_frc = lhs_frc >> (rhs_exp - lhs_exp)
    diff_sgn = rhs_sgn
    diff_exp = rhs_exp
  elseif (lhs_frc > rhs_frc)
    top_frc = lhs_frc
    bot_frc = rhs_frc
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  else
    top_frc = rhs_frc
    bot_frc = lhs_frc
    diff_sgn = rhs_sgn
    diff_exp = rhs_exp
  end

  #subtract the two from each other, with carry check.
  diff_frc = top_frc - bot_frc

  #underflow check.
  if (diff_frc > top_frc)
    #decrease the exponent - note that this can't be less than zero.
    diff_exp -= 1
    diff_frc = (diff_frc << 1)
  else
    #do shifting
    shiftcount = min(leading_zeros(diff_frc), diff_exp)
    diff_exp -= shiftcount
    diff_frc <<= shiftcount
  end

  #return the base sign, the adjusted exponent, and the result fraction.
  (diff_sgn, diff_exp, diff_frc)
end

function numeric_sub(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)
  ## assign top and bottom fractions, ascertain the final sign, and set the
  ## exponential realm.

  if (lhs_exp > rhs_exp)
    top_frc = lhs_frc
    sub_exp_shift = lhs_exp - rhs_exp
    bot_frc = (rhs_frc >> sub_exp_shift) | ((@signbit) >> (sub_exp_shift - 1))
    #set the carry and the guard
    carry_lost = false
    guard_bit = (@UInt)(1) - ((rhs_frc >> (sub_exp_shift - 1)) & (@UInt)(1))
    #infer sign and exponent from the top.
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  elseif (rhs_exp > lhs_exp)
    top_frc = rhs_frc
    sub_exp_shift = rhs_exp - lhs_exp
    bot_frc = (lhs_frc >> sub_exp_shift) | ((@signbit) >> (sub_exp_shift - 1))
    #set the carry and the guard
    carry_lost = false
    guard_bit = (@UInt)(1) - ((lhs_frc >> (sub_exp_shift - 1)) & (@UInt)(1))
    #infer sign and exponent from the top.
    diff_sgn = rhs_sgn
    diff_exp = rhs_exp
  elseif (lhs_frc > rhs_frc)
    top_frc = lhs_frc
    bot_frc = rhs_frc
    #set the carry and the guard
    carry_lost = true
    guard_bit = (@UInt)(0)
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  else
    top_frc = rhs_frc
    bot_frc = lhs_frc
    #set the carry and the guard
    carry_lost = true
    guard_bit = (@UInt)(0)
    #infer sign and exponent from the top.
    diff_sgn = rhs_sgn
    diff_exp = rhs_exp
  end

  #subtract the two from each other, with carry check.
  diff_frc = top_frc - bot_frc

  #underflow check.
  carry_lost |= (diff_frc > top_frc)

  #reassign the exponent if we've lost the carry bit
  if (carry_lost)
    sub_shift = leading_zeros(diff_frc) + 1
    diff_exp -= sub_shift
    diff_frc <<= sub_shift
    diff_frc |= guard_bit
  end

  #return the base sign, the adjusted exponent, and the result fraction.
  (diff_sgn, diff_exp, diff_frc)
end


function add_algorithm(lhs_exp, lhs_frc, rhs_exp, rhs_frc)
  if (lhs_exp > rhs_exp)
    rhs_frc >>= (lhs_exp - rhs_exp)
    sum_exp = lhs_exp
  else
    lhs_frc >>= (rhs_exp - lhs_exp)
    sum_exp = rhs_exp
  end
  #add the two together, with carry check.
  sum_frc = rhs_frc + lhs_frc

  #carry check.
  if (sum_frc < rhs_frc)
    #increase the exponent.
    sum_exp += 1
    #move the fraction over one, and append the top bit.
    sum_frc = (sum_frc >> 1) | @signbit
  end

  (sum_exp, sum_frc)
end
