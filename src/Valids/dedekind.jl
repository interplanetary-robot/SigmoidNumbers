glb{N,ES}(x::Vnum{N,ES}) = isulp(x) ? prev(x) : x
lub{N,ES}(x::Vnum{N,ES}) = isulp(x) ? next(x) : x
upper_ulp{N,ES}(x::Vnum{N,ES}) = isulp(x) ? x : next(x)
lower_ulp{N,ES}(x::Vnum{N,ES}) = isulp(x) ? x : prev(x)

outer_exact{N,ES}(x::Vnum{N,ES}) = reinterpret((@Int), x) < 0 ? lub(x) : glb(x)
inner_exact{N,ES}(x::Vnum{N,ES}) = reinterpret((@Int), x) < 0 ? glb(x) : lub(x)

function outer_ulp{N,ES}(x::Vnum{N,ES})
  xint = reinterpret(@Int, x)
  if xint == 0
    throw(NaNError(:inner_exact, [x]))
  elseif xint < 0
    lower_ulp(x)
  else
    upper_ulp(x)
  end
end

function inner_ulp{N,ES}(x::Vnum{N,ES})
  xint = reinterpret(@Int, x)
  if xint == 0
    throw(NaNError(:inner_exact, [x]))
  elseif xint < 0
    upper_ulp(x)
  else
    lower_ulp(x)
  end
end
