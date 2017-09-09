
function Base.:+{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})

  (isempty(lhs)    || isempty(rhs))    && (return Valid{N,ES}(∅))
  (isallreals(lhs) || isallreals(rhs)) && (return Valid{N,ES}(ℝp))

  check_roundsinf::Bool = roundsinf(lhs) || roundsinf(rhs)

  result = ((@lower rhs) + (@lower lhs)) → ((@upper rhs) + (@upper lhs))

  if (check_roundsinf)
    # let's make sure our result still rounds inf, this is a property which is
    # invariant under addition.  Losing this property suggests that the answer
    # should be recast as "allreals."  While we're at it, check to see if the
    # answer ends now "touch", which makes them "allreals".
    roundsinf(result) || (return Valid{N,ES}(ℝp))
  end

  return result
end

Base.:-{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES}) = lhs + (-rhs)
Base.:-{N,ES}(x::Valid{N,ES}) = Valid{N,ES}(-x.upper, -x.lower)
