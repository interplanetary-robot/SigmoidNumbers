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

#do multiplicative inverses.

function inv{N,ES}(x::Valid{N,ES})
    isallreals(x) && return x
    isempty(x) && return x

end


Base.:/{N,ES}(x::Valid{N,ES}) = inv(x)
