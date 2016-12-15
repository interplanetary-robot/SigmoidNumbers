import Base: +

function +{N}(lhs::MLSigmoid{N}, rhs::MLSigmoid{N})
  #adding infinities is infinite.
  isfinite(lhs) || return reinterpret(MLSigmoid{N}, @signbit)
  isfinite(rhs) || return reinterpret(MLSigmoid{N}, @signbit)
  #adding zeros is zero
  iszero(lhs) && return rhs
  iszero(rhs) && return lhs

  #generate the lhs and rhs subcomponents.
  @breakdown lhs arithmetic
  @breakdown rhs arithmetic

  if (lhs_sgn != rhs_sgn)
    (dif_sgn, dif_exp, dif_frc) = sub_algorithm(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)

    if ((dif_frc & @signbit) == 0) && (dif_exp > 0)
      dif_exp -= 1
      dif_frc <<= 1
    end

    build_arithmetic(MLSigmoid{N}, dif_sgn, dif_exp, dif_frc)
  else
    (sum_exp, sum_frc) = add_algorithm(lhs_exp, lhs_frc, rhs_exp, rhs_frc)
    build_arithmetic(MLSigmoid{N}, lhs_sgn, sum_exp, sum_frc)
  end
end

function sub_algorithm(lhs_sgn, lhs_exp, lhs_frc, rhs_sgn, rhs_exp, rhs_frc)
  ## assign top and bottom fractions, ascertain the final sign, and set the
  ## exponential realm.
  if (lhs_exp > rhs_exp)
    top_frc = lhs_frc
    bot_frc = rhs_frc >> (lhs_exp - rhs_exp)
    base_sgn = lhs_sgn
    base_exp = lhs_exp
  elseif (lhs_exp > rhs_exp)
    top_frc = rhs_frc
    bot_frc = lhs_frc >> (rhs_exp - lhs_exp)
    base_sgn = lhs_sgn
    base_exp = lhs_exp
  elseif (lhs_frc > rhs_frc)
    top_frc = lhs_frc
    bot_frc = rhs_frc
    base_sgn = lhs_sgn
    base_exp = lhs_exp
  else
    top_frc = rhs_frc
    bot_frc = lhs_frc
    base_sgn = lhs_sgn
    base_exp = lhs_Exp
  end

  #subtract the two from each other, with carry check.
  diff_frc = top_frc - bot_frc

  #return the base sign, the adjusted exponent, and the result fraction.
  (base_sgn, diff_frc > top_frc ? base_exp - 1 : base_exp, diff_frc)
end

function add_algorithm(lhs_exp, lhs_frc, rhs_exp, rhs_frc)
  if (lhs_exp > rhs_exp)
    rhs_frc >>= (lhs_exp - rhs_exp)
    base_exp = lhs_exp
  else
    lhs_frc >>= (rhs_exp - lhs_exp)
    base_exp = rhs_exp
  end
  #add the two together, with carry check.
  sum_frc = rhs_frc + lhs_frc
  (sum_frc < rhs_frc ? base_exp + 1 : base_exp, sum_frc)
end
