function Base.:/{N,ES}(lhs::Valid{N,ES}, rhs::Valid{N,ES})

  (isempty(lhs)    || isempty(rhs))    && (return Valid{N,ES}(∅))
  (isallreals(lhs) || isallreals(rhs)) && (return Valid{N,ES}(ℝp))

#  if roundsinf(lhs)
#    infmul(lhs, rhs)
#  elseif roundsinf(rhs)
#    infmul(rhs, lhs)
#  elseif containszero(lhs)
#    zeromul(lhs, rhs)
#  elseif containszero(rhs)
#    zeromul(rhs, lhs)
#  else
#    stdmul(rhs, lhs)
#  end
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
