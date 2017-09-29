function Base.:/{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})

  (isempty(lhs)    || isempty(rhs))    && (return Valid{N,ES}(∅))
  (isallreals(lhs) || isallreals(rhs)) && (return Valid{N,ES}(ℝp))

  if roundsinf(lhs)
    lhs_infdiv(lhs, rhs)
  elseif roundsinf(rhs)
    rhs_infdiv(lhs, rhs)
  elseif containszero(lhs)
    lhs_zerodiv(lhs, rhs)
  elseif containszero(rhs)
    rhs_zerodiv(lhs, rhs)
  else
    stddiv(lhs, rhs)
  end
end

function lhs_infdiv{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    if roundsinf(rhs)
        return Valid{N,ES}(ℝp)
    elseif containszero(lhs)  #lhs contains zero AND infinity.  Rhs cannot contain infinity.
        containszero(rhs) && return Valid{N,ES}(ℝp) #then we have 0/0 which is all reals.
        #canonical examples:

        #(20 ,   10) / (4,   5) -> (4, 2.5)
        #(20 ,   10) / (-5, -4) -> (-2.5, -4)
        #(-10 , -20) / (4,   5) -> (-2.5, -4)
        #(-10 , -20) / (-5, -4) -> (4, 2.5)

        _state = rounds_positive(lhs) * 1 + nonpositive(rhs) * 2

        if _state == __LHS_POS_RHS_POS
            res = ((@d_lower lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_lower rhs))
        elseif (_state == __LHS_NEG_RHS_POS)
            res = ((@d_lower lhs) / (@d_lower rhs)) → ((@d_upper lhs) / (@d_upper rhs))
        elseif (_state == __LHS_POS_RHS_NEG)
            res = ((@d_upper lhs) / (@d_upper rhs)) → ((@d_lower lhs) / (@d_lower rhs))
        else   #state == 3
            res = ((@d_upper lhs) / (@d_lower rhs)) → ((@d_lower lhs) / (@d_upper rhs))
        end

        (@s prev(res.lower)) <= (@s res.upper) && (return Valid{N,ES}(ℝp))
        return res

    elseif containszero(rhs)
        #lhs rounds infinity and rhs contains zero.
        #canonical examples:

        #(20, -10) / (-1, 4) -> (-5, 2.5)

        lower1 = (@d_upper lhs) / (@d_lower rhs)
        lower2 = (@d_lower lhs) / (@d_upper rhs)

        upper1 = (@d_lower lhs) / (@d_lower rhs)
        upper2 = (@d_upper lhs) / (@d_upper rhs)


        min_not_inf(lower1, lower2) → max_not_inf(upper1, upper2)
    else
        #the last case is if lhs rounds infinity but rhs is a "well-behaved" value.
        #canonical example:
        # (10, -20) / (2, 5) -> (2, -4)
        # (10, -20) / (-5, -2) -> (4, -2)

        if (rhs.lower > zero(Vnum{N,ES}))
            ((@d_lower lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_upper rhs))
        else
            ((@d_upper lhs) / (@d_lower rhs)) → ((@d_lower lhs) / (@d_lower rhs))
        end
    end
end

function rhs_infdiv{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    if containszero(rhs)  #rhs contains zero AND infinity.
        #pass (for now)
        containszero(lhs) && return Valid{N,ES}(ℝp)

        #now address the situations where we are dividing by  round-both-horns.

        #(10,   20) / (5,   1) -> (4, 10)
        #(-20, -10) / (5,   1) -> (-10, -4)
        #(10,   20) / (-1, -5) -> (-10, -4)
        #(-20, -10) / (-1, -5) -> (4, 10)

        _state = (nonnegative(lhs)) * 1 + (rounds_negative(rhs)) * 2

        if _state == __LHS_POS_RHS_POS
            res = ((@d_upper lhs) / (@d_lower rhs)) → ((@d_lower lhs) / (@d_upper rhs))
        elseif (_state == __LHS_NEG_RHS_POS)
            res = ((@d_upper lhs) / (@d_upper rhs)) → ((@d_lower lhs) / (@d_lower rhs))
        elseif (_state == __LHS_POS_RHS_NEG)
            res = ((@d_lower lhs) / (@d_lower rhs)) → ((@d_upper lhs) / (@d_upper rhs))
        else   #state == 3
            res = ((@d_lower lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_lower rhs))
        end

        (@s prev(res.lower)) <= (@s res.upper) && (return Valid{N,ES}(ℝp))
        return res

    elseif containszero(lhs)
        #pass (for now)
        # (-10, 20) / (2, -5) -> (-4, 10)

        lower1 = (@d_upper lhs) / (@d_upper rhs)
        lower2 = (@d_lower lhs) / (@d_lower rhs)

        upper1 = (@d_upper lhs) / (@d_lower rhs)
        upper2 = (@d_lower lhs) / (@d_upper rhs)

        min_not_inf(lower1, lower2) → max_not_inf(upper1, upper2)
    else
        #the last case is if rhs rounds infinity but lhs is a "well-behaved" value.
        #canonical example:
        # (10, 20) / (2, -5) -> (-4, 10)
        # (-20, -10) / (2, -5) -> (-10, 4)
        if (lhs.lower > zero(Vnum{N,ES}))
            ((@d_upper lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_lower rhs))
        else
            ((@d_lower lhs) / (@d_lower rhs)) → ((@d_lower lhs) / (@d_upper rhs))
        end
    end
end

function lhs_zerodiv{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    #lhs and rhs guaranteed to not cross infinity.  lhs guaranteed to contain zero.
    containszero(rhs) && return Valid{N,ES}(ℝp)

    #example: (-10, 20) / (-5, -2) -> (-10, 4)

    if nonpositive(rhs)
        ((@d_lower lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_upper rhs))
    else
        ((@d_lower lhs) / (@d_lower rhs)) → ((@d_upper lhs) / (@d_lower rhs))
    end
end

function rhs_zerodiv{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
    #lhs and rhs guaranteed to not contain infinity, lhs guaranteed to not contain zero.

    #example: (10, 20) / (-2, 5) -> (-10, 4)

    if nonpositive(lhs)
        ((@d_upper lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_lower rhs))
    else
        ((@d_lower lhs) / (@d_upper rhs)) → ((@d_lower lhs) / (@d_lower rhs))
    end
end

function stddiv{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})
  #both values are "reasonable."
  _state = nonpositive(lhs) * 1 + nonpositive(rhs) * 2

  if _state == __LHS_POS_RHS_POS
    ((@d_lower lhs) / (@d_upper rhs)) → ((@d_upper lhs) / (@d_lower rhs))
  elseif _state == __LHS_NEG_RHS_POS
    ((@d_lower lhs) / (@d_lower rhs)) → ((@d_upper lhs) / (@d_upper rhs))
  elseif _state == __LHS_POS_RHS_NEG
    ((@d_upper lhs) / (@d_upper rhs)) → ((@d_lower lhs) / (@d_lower rhs))
  else #__LHS_NEG_RHS_NEG
    ((@d_upper lhs) / (@d_lower rhs)) → ((@d_lower lhs) / (@d_upper rhs))
  end
end

#do multiplicative inverses.  We cannot just chain division as a multiplication
#with this, due to the dependency problem.

function Base.inv{N,ES}(x::Valid{N,ES})
    isallreals(x) && return x
    isempty(x) && return x

    if istile(x) && !(isulp(x.lower))
        (@exact x) |> inv |> tile
    else
        inv(@upper x) → inv(@lower x)
    end
end

Base.:/{N,ES}(x::Valid{N,ES}) = inv(x)
