
function __add_dropout{T <: Vnum}(value1::T, value2::T, result::T)
  (@u(value1) == (@signbit)) && return reinterpret(T, @signbit)
  (@u(value2) == (@signbit)) && return reinterpret(T, @signbit)
  return result
end

function Base.:+{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})

  (isempty(lhs)    || isempty(rhs))    && (return Valid{N,ES}(∅))
  (isallreals(lhs) || isallreals(rhs)) && (return Valid{N,ES}(ℝp))

  check_roundsinf::Bool = roundsinf(lhs) || roundsinf(rhs)

  #for addition, result_upper = left_upper + right_upper, always.
  upper = __add_dropout(lhs.upper, rhs.upper, @upper_valid(@upper(lhs.upper) + @upper(rhs.upper), lhs.upper, rhs.upper))
  #for addition, result_lower = left_lower + right_lower, always.
  lower = __add_dropout(lhs.lower, rhs.lower, @lower_valid(@lower(lhs.lower) + @lower(rhs.lower), lhs.lower, rhs.lower))

  if (check_roundsinf)
    # let's make sure our result still rounds inf, this is a property which is
    # invariant under addition.  Losing this property suggests that the answer
    # should be recast as "allreals."  While we're at it, check to see if the
    # answer ends now "touch", which makes them "allreals".
    (@s (prev(lower))) <= (@s upper) && (return Valid{N,ES}(ℝp))
  end

  return Valid{N,ES}(lower, upper)
end

Base.:-{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES}) = lhs + Valid{N,ES}(-rhs.upper, -rhs.lower)
Base.:-{N,ES}(x::Valid{N,ES}) = Valid{N,ES}(-x.upper, -x.lower)
