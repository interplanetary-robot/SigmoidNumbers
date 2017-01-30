import Base: +, -

@generated function +{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode})
  if (ES == 0)
    breakdown = :(@breakdown lhs arithmetic; @breakdown rhs arithmetic)
    sub_algorithm = arithmetic_sub
    add_algorithm = arithmetic_add
    build_algorithm = build_arithmetic
  else
    breakdown = :(@breakdown lhs; @breakdown rhs)
    sub_algorithm = numeric_sub
    add_algorithm = numeric_add
    build_algorithm = build_numeric
  end

  S = Sigmoid{N, ES, mode}

  quote
    #adding infinities is infinite.
    if !isfinite(lhs)
       isfinite(rhs) || throw(NaNError(+, [$S(Inf), $S(Inf)]))
       return $S(Inf)
    end

    isfinite(rhs) || return $S(Inf)

    #adding zeros is identity.
    (reinterpret((@UInt), lhs) == zero(@UInt)) && return rhs
    (reinterpret((@UInt), rhs) == zero(@UInt)) && return lhs

    (reinterpret((@UInt), lhs) == -reinterpret((@UInt), rhs)) && return zero($S)

    $breakdown

    if (lhs_sgn != rhs_sgn)

      (dif_sgn, dif_exp, dif_frc) = $sub_algorithm(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)

      __round($build_algorithm($S, dif_sgn, dif_exp, dif_frc))
    else
      (sum_exp, sum_frc) = $add_algorithm(lhs_exp, lhs_frc, rhs_exp, rhs_frc)

      __round($build_algorithm($S, lhs_sgn, sum_exp, sum_frc))
    end
  end
end

-{N, ES, mode}(operand::Sigmoid{N, ES, mode}) = reinterpret(Sigmoid{N, ES, mode}, -@s(operand))
-{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode}) = lhs + (-rhs)

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
    #infer sign and exponent from the top.
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  elseif (rhs_exp > lhs_exp)
    top_frc = rhs_frc
    sub_exp_shift = rhs_exp - lhs_exp
    bot_frc = (lhs_frc >> sub_exp_shift) | ((@signbit) >> (sub_exp_shift - 1))
    #set the carry and the guard
    carry_lost = false
    #infer sign and exponent from the top.
    diff_sgn = rhs_sgn
    diff_exp = rhs_exp
  elseif (lhs_frc > rhs_frc)
    top_frc = lhs_frc
    bot_frc = rhs_frc
    #set the carry and the guard
    carry_lost = true
    diff_sgn = lhs_sgn
    diff_exp = lhs_exp
  else
    top_frc = rhs_frc
    bot_frc = lhs_frc
    #set the carry and the guard
    carry_lost = true
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
  end

  #return the base sign, the adjusted exponent, and the result fraction.
  (diff_sgn, diff_exp, diff_frc)
end

function numeric_add(lhs_exp, lhs_frc, rhs_exp, rhs_frc)

  carry = 1

  if (lhs_exp > rhs_exp)
    add_exp_shift = lhs_exp - rhs_exp
    rhs_frc >>= add_exp_shift
    rhs_frc |= (@signbit) >> (add_exp_shift - 1)
    sum_exp = lhs_exp
    carry = 1
  elseif (lhs_exp < rhs_exp)
    add_exp_shift = rhs_exp - lhs_exp
    lhs_frc >>= add_exp_shift
    lhs_frc |= (@signbit) >> (add_exp_shift - 1)
    sum_exp = rhs_exp
    carry = 1
  else
    sum_exp = lhs_exp
    carry = 2
  end

  #add the two together, with carry check.
  sum_frc = rhs_frc + lhs_frc

  #carry check.
  carry += (sum_frc < rhs_frc)

  if carry > 1
    sum_exp += 1
    #move the fraction over one, and append the top bit.
    sum_frc >>= 1
    (carry == 3) && (sum_frc |= (@signbit))
  end

  (sum_exp, sum_frc)
end

function arithmetic_add(lhs_exp, lhs_frc, rhs_exp, rhs_frc)
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
