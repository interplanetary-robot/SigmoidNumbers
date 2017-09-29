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

function min_not_inf{N,ES,mode1,mode2}(x::Sigmoid{N,ES,mode1}, y::Sigmoid{N,ES,mode2})
    isfinite(x) || return (mode1 == :inward_ulp) ? x : y
    isfinite(y) || return (mode2 == :inward_ulp) ? y : x
    min(x, y)
end

function max_not_inf{N,ES,mode1,mode2}(x::Sigmoid{N,ES,mode1}, y::Sigmoid{N,ES,mode2})
    isfinite(x) || return (mode1 == :inward_ulp) ? x : y
    isfinite(y) || return (mode2 == :inward_ulp) ? y : x
    max(x, y)
end

function Base.min{N,ES}(x::Sigmoid{N,ES,:inward_exact}, y::Sigmoid{N,ES,:inward_ulp})
    rx = reinterpret(Vnum{N,ES}, x)
    ry = reinterpret(Vnum{N,ES}, y)
    (rx < zero(Vnum{N,ES})) && (rx == ry) && return x
    (rx < ry) ? x : y
end
function Base.max{N,ES}(x::Sigmoid{N,ES,:inward_exact}, y::Sigmoid{N,ES,:inward_ulp})
    rx = reinterpret(Vnum{N,ES}, x)
    ry = reinterpret(Vnum{N,ES}, y)
    (rx > zero(Vnum{N,ES})) && (rx == ry) && return x
    (rx > ry) ? x : y
end

function Base.min{N,ES}(x::Sigmoid{N,ES,:outward_exact}, y::Sigmoid{N,ES,:outward_ulp})
    rx = reinterpret(Vnum{N,ES}, x)
    ry = reinterpret(Vnum{N,ES}, y)
    (rx > zero(Vnum{N,ES})) && (rx == ry) && return x
    (rx < ry) ? x : y
end
function Base.max{N,ES}(x::Sigmoid{N,ES,:outward_exact}, y::Sigmoid{N,ES,:outward_ulp})
    rx = reinterpret(Vnum{N,ES}, x)
    ry = reinterpret(Vnum{N,ES}, y)
    (rx < zero(Vnum{N,ES})) && (rx == ry) && return x
    (rx > ry) ? x : y
end

Base.min{N,ES}(x::Sigmoid{N,ES,:inward_ulp},y::Sigmoid{N,ES,:inward_exact})   = min(y, x)
Base.max{N,ES}(x::Sigmoid{N,ES,:inward_ulp},y::Sigmoid{N,ES,:inward_exact})   = max(y, x)
Base.min{N,ES}(x::Sigmoid{N,ES,:outward_ulp},y::Sigmoid{N,ES,:outward_exact}) = min(y, x)
Base.max{N,ES}(x::Sigmoid{N,ES,:outward_ulp},y::Sigmoid{N,ES,:outward_exact}) = max(y, x)

function infmul{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    if containszero(rhs)
        return Valid{N,ES}(ℝp)
    elseif containszero(lhs)  #lhs contains zero AND infinity
        roundsinf(rhs) && return Valid{N,ES}(ℝp)

        #at this juncture, the value lhs must round both zero and infinity, and
        #the value rhs must be a standard, nonflipped double interval that is only on
        #one side of zero.

        # (100, 1) * (3, 4)     -> (300, 4)    (l * l, u * u)
        # (-1, -100) * (3, 4)   -> (-4, -300)  (l * u, u * l)
        # (100, 1) * (-4, -3)   -> (-4, -300)  (u * l, l * u)
        # (-1, -100) * (-4, -3) -> (300, 4)    (u * u, l * l)

        _state = rounds_positive(lhs) * 1 + nonpositive(rhs) * 2

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
        # when rhs spans zero, we have to check four possible endpoints.
        lower1 = (@d_lower lhs) * (@d_upper rhs)
        lower2 = (@d_upper lhs) * (@d_lower rhs)
        upper1 = (@d_lower lhs) * (@d_lower rhs)
        upper2 = (@d_upper lhs) * (@d_upper rhs)

        return min_not_inf(lower1, lower2) → max_not_inf(upper1, upper2)
        # in the case where the rhs doesn't span zero, we must only multiply by the
        # extremum.
    else
        if nonpositive(rhs)
            return ((@d_lower rhs) * (@d_upper lhs)) → ((@d_lower rhs) * (@d_lower lhs))
        else
            return ((@d_lower lhs) * (@d_upper rhs)) → ((@d_upper lhs) * (@d_upper rhs))
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
