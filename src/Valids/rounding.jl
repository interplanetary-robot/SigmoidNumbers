@generated function __round{N, ES}(x::Sigmoid{N, ES, :ubit}, extrabits::(@UInt) = zero(@UInt))
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

################################################################################
## UPPER, LOWER, INNER, and OUTER ROUNDING.

@generated function __round{N, ES}(x::Sigmoid{N, ES, :upper}, extrabits::(@UInt) = zero(@UInt))
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

    #first look to see if the checkbit is set.  If it's nonzero, round up.
    ($checkmask & @u(x) != $z) && return reinterpret($T, truncated_value + $innerbit)
    return reinterpret($T, truncated_value)
  end
end

@generated function __round{N, ES}(x::Sigmoid{N, ES, :lower}, extrabits::(@UInt) = zero(@UInt))
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

    #first look to see if the checkbit is set.  Always, round down.
    return reinterpret($T, truncated_value)
  end
end
