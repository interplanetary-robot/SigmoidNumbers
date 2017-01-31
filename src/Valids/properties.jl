@generated function isulp{N,ES}(x::Vnum{N, ES})
  inc = increment(Vnum{N, ES})
  :( (@u(x) & $inc) != 0 )
end

function isempty{N,ES}(x::Valid{N,ES})
  (@u(x.lower) == increment(Vnum{N,ES})) && (@u(x.upper) == zero(@UInt))
end

function isnan{N,ES}(x::Valid{N,ES})
  (@u(x.lower) == zero(@UInt)) && (@u(x.upper) == -increment(Vnum{N,ES}))
end

@generated function isallreals{N,ES}(x::Valid{N,ES})
  inc = increment(Vnum{N,ES})
  quote
    (@u(x.lower) != 0) && (@u(x.upper) != 0) && (@u(x.lower) == @u(x.upper) + $inc)
  end
end

function roundsinf{N,ES}(x::Valid{N,ES})
  (@s(x.upper) < @s(x.lower))
end

function containszero{N,ES}(x::Valid{N,ES})
  (@s(x.upper) >= zero(@Int)) && (@s(x.lower) <= zero(@Int))
end

function ispositive{N,ES}(x::Valid{N,ES})
  zero(@Int) < (@s(x.lower)) < (@s(x.upper))
end

function isnegative{N,ES}(x::Valid{N,ES})
  (@s(x.lower)) < (@s(x.upper)) < zero(@Int)
end
