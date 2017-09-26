function Base.:*{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    (isempty(lhs)    || isempty(rhs))    && (return Valid{N,ES}(∅))
    (isallreals(lhs) || isallreals(rhs)) && (return Valid{N,ES}(ℝp))

    #println("multiplying $lhs with $rhs")

    if roundsinf(lhs)
        infmul(lhs, rhs)
    elseif roundsinf(rhs)
        infmul(rhs, lhs)
    elseif containszero(lhs)
        zeromul(lhs, rhs)
    elseif containszero(rhs)
        zeromul(rhs, lhs)
    else
        stdmul(rhs, lhs)
    end
end

const __LHS_POS_RHS_POS = 0
const __LHS_NEG_RHS_POS = 1
const __LHS_POS_RHS_NEG = 2
const __LHS_NEG_RHS_NEG = 3

doc"""
  nonnegative(::Valid) is true if no values in x are negative.
"""
function nonnegative{N,ES}(x::Valid{N,ES})
    (x.lower <= zero(Vnum{N,ES})) && (!isfinite(x.upper) || zero(num{N,ES}) <= x.upper <= maxpos(Vnum{N,ES}))
end

doc"""
  nonpositive(::Valid) is true if no values in x are positive.
"""
function nonpositive{N,ES}(x::Valid{N,ES})
    (x.upper <= zero(Vnum{N,ES})) && (!isfinite(x.lower) || minneg(Vnum{N,ES}) <= x.lower <= zero(Vnum{N,ES}))
end

function min_not_inf{N,ES,mode1,mode2}(x::Sigmoid{N,ES,mode1}, y::Sigmoid{N,ES,mode2})
    isfinite(x) || return y
    isfinite(y) || return x
    if mode1 == mode2
        min(x, y)
    end
end

function max_not_inf{N,ES,mode1,mode2}(x::Sigmoid{N,ES,mode1}, y::Sigmoid{N,ES,mode2})
    isfinite(x) || return y
    isfinite(y) || return x
    if mode1 == mode2
        max(x, y)
    end
end

function infmul{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    if containszero(rhs)
        return Valid{N,ES}(ℝp)
    elseif containszero(lhs)  #lhs contains zero AND infinity
        roundsinf(rhs) && return Valid{N,ES}(ℝp)

        #=
        #at this juncture, the value lhs must round both zero and infinity, and
        #the value rhs must be a standard, nonflipped double interval that is only on
        #one side of zero.

        # (100, 1) * (3, 4)     -> (300, 4)    (l * l, u * u)
        # (100, 1) * (-4, -3)   -> (-4, -300)  (u * l, l * u)
        # (-1, -100) * (3, 4)   -> (-4, -300)  (l * u, u * l)
        # (-1, -100) * (-4, -3) -> (300, 4)    (u * u, l * l)
        =#

        _state = nonpositive(lhs) * 1 + nonpositive(rhs) * 2

        if _state == __LHS_POS_RHS_POS
            res = ((@d_lower lhs) * (@d_lower rhs)) → ((@d_upper lhs) * (@d_upper rhs))
        elseif (_state == __LHS_NEG_RHS_POS)
            res = ((@d_lower lhs) * (@d_upper rhs)) → ((@d_upper lhs) * (@d_lower rhs))
        elseif (_state == __LHS_POS_RHS_NEG)
            res = ((@d_upper lhs) * (@d_lower rhs)) → ((@d_lower lhs) * (@d_upper rhs))
        else   #state == 3
            res = ((@d_upper lhs) * (@d_upper rhs)) → ((@d_lower lhs) * (@d_lower rhs))
        end

        (@s prev(res.lower)) <= (@s res.upper) && (return Valid{N,ES}(ℝp))
        return res

    elseif roundsinf(rhs)  #now we must check if rhs rounds infinity.

        lower1 = (@d_lower lhs) * (@d_lower rhs)
        lower2 = (@d_upper lhs) * (@d_upper rhs)

        upper1 = (@d_lower lhs) * (@d_upper rhs)
        upper2 = (@d_upper lhs) * (@d_lower rhs)

        min_not_inf(lower1, lower2) → max_not_inf(upper1, upper2)
    else
        #the last case is if lhs rounds infinity but rhs is a "well-behaved" value.
        #canonical example:
        # (2, -3) * (5, 7) -> (10, -15)
        # (2, -3) * (-7, -5) -> (15, -10)

        if (rhs.lower > zero(Vnum{N,ES}))
            ((@d_lower lhs) * (@d_lower rhs)) → ((@d_upper lhs) * (@d_lower rhs))
        else
            ((@d_upper lhs) * (@d_upper rhs)) → ((@d_lower lhs) * (@d_upper rhs))
        end
    end
end

__simple_roundszero{T <: Valid}(v::T) = ((@s v.lower) < 0) & ((@s v.upper) > 0)

function zeromul{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
  #lhs and rhs guaranteed to not cross infinity.  lhs guaranteed to contain zero.
  if __simple_roundszero(rhs)
     #=
    # when rhs spans zero, we have to check four possible endpoints.
    lower1 = __lower_mul(lhs.lower, rhs.upper)
    lower2 = __lower_mul(lhs.upper, rhs.lower)
    upper1 = __upper_mul(lhs.lower, rhs.lower)
    upper2 = __upper_mul(lhs.upper, rhs.upper)

    return Valid{N,ES}(min(lower1, lower2), max(lower1, lower2))

    # in the case where the rhs doesn't span zero, we must only multiply by the
    # extremum.
    =#
  else
      _state = nonpositive(lhs) * 1 + nonpositive(rhs) * 2

      if _state == __LHS_POS_RHS_POS
          ((@d_lower lhs) * (@d_upper rhs)) → ((@d_upper lhs) * (@d_upper rhs))
      elseif (_state == __LHS_NEG_RHS_POS)
          ((@d_lower lhs) * (@d_upper rhs)) → ((@d_upper lhs) * (@d_lower rhs))
      elseif (_state == __LHS_POS_RHS_NEG)
          ((@d_upper lhs) * (@d_lower rhs)) → ((@d_lower lhs) * (@d_upper rhs))
      else
          ((@d_upper lhs) * (@d_upper rhs)) → ((@d_lower lhs) * (@d_lower rhs))
      end
  end
end

function stdmul{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
  #both values are "reasonable."
  _state = nonpositive(lhs) * 1 + nonpositive(rhs) * 2

  if _state == __LHS_POS_RHS_POS
    ((@d_lower lhs) * (@d_lower rhs)) → ((@d_upper lhs) * (@d_upper rhs))
  elseif _state == __LHS_NEG_RHS_POS
    ((@d_lower lhs) * (@d_upper rhs)) → ((@d_upper lhs) * (@d_lower rhs))
  elseif _state == __LHS_POS_RHS_NEG
    ((@d_upper lhs) * (@d_lower rhs)) → ((@d_lower lhs) * (@d_upper rhs))
  else #__LHS_NEG_RHS_NEG
    ((@d_upper lhs) * (@d_upper rhs)) → ((@d_lower lhs) * (@d_lower rhs))
  end
end
