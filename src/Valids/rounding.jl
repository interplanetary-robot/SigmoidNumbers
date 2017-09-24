
#unify the three modes because we'll use the same mode for all of them.
RoundedSigmoid{N,ES} = Union{Sigmoid{N,ES,:upper}, Sigmoid{N,ES,:lower}, Sigmoid{N,ES,:exact}, Sigmoid{N,ES,:cross}}

@generated function __round{N, ES}(x::RoundedSigmoid{N, ES}, extrabits::(@UInt) = zero(@UInt))
  #for convenience, store the type of x as T.
  T = x
  z = zero(@UInt)

  innerbit = one(@UInt) << (__BITS - N)
  checkmask = (-(@UInt)(1)) >> (N)
  blankmask = ~((-(@UInt)(1)) >> N)
  quote
    #take exact zero and exact infinity.
    if (extrabits == zero(@UInt))
      (@u(x) == @signbit) && return reinterpret($T, @signbit)
      (@u(x) == zero(@UInt)) && return reinterpret($T, zero(@UInt))
    end

    truncated_value = @u(x) & $blankmask

    #eliminate values that go towards infinity - as "maxreal"
    (truncated_value == (@signbit) - $innerbit) && return reinterpret($T, truncated_value)
    #eliminate values that go down to infinity.
    (truncated_value == (@signbit)) && return reinterpret($T, truncated_value + $innerbit)
    #eliminate values that go down to zero.
    (truncated_value == zero(@UInt)) && return reinterpret($T, $innerbit)
    #eliminate values that go up to zero.
    (truncated_value == -$innerbit) && return reinterpret($T, -$innerbit)

    #first look to see if the checkbit is set.  If it's zero, round down.
    ($checkmask & @u(x) != $z) && return reinterpret($T, truncated_value | $innerbit)
    return reinterpret($T, truncated_value)
  end
end

resolve_rounding{N,ES}(x::Sigmoid{N,ES,:lower}) = upper_ulp(reinterpret(Sigmoid{N,ES,:ubit}, x))
resolve_rounding{N,ES}(x::Sigmoid{N,ES,:upper}) = lower_ulp(reinterpret(Sigmoid{N,ES,:ubit}, x))
resolve_rounding{N,ES}(x::Sigmoid{N,ES,:exact}) = reinterpret(Sigmoid{N,ES,:ubit}, x)

→{N,ES}(lower::RoundedSigmoid{N,ES}, upper::RoundedSigmoid{N,ES}) = resolve_rounding(lower)                 → resolve_rounding(upper)
→{N,ES}(lower::Sigmoid{N,ES,:cross}, upper::RoundedSigmoid{N,ES}) = reinterpret(Sigmoid{N,ES,:lower},lower) → upper
→{N,ES}(lower::RoundedSigmoid{N,ES}, upper::Sigmoid{N,ES,:cross}) = lower                                   → reinterpret(Sigmoid{N,ES,:upper},upper)
→{N,ES}(lower::Sigmoid{N,ES,:cross}, upper::Sigmoid{N,ES,:cross}) = reinterpret(Sigmoid{N,ES,:lower},lower) → reinterpret(Sigmoid{N,ES,:upper},upper)
