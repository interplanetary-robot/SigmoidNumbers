
#an internal function that performs rounding.  You can provide other __round
#implementations if you do "other" rounding modes.
@generated function __round{N, ES}(x::Sigmoid{N, ES, :guess}, extrabits::(@UInt) = zero(@UInt))
  #for convenience, store the type of x as T.
  T = x
  z = zero(@UInt)
  if N < __BITS
    innerbit = one(@UInt) << (__BITS - N)
    checkbit = one(@UInt) << (__BITS - N - 1)
    checkmask = (-(@UInt)(1)) >> (N + 1)
    blankmask = ~((-(@UInt)(1)) >> N)
    quote
      #take exact zero and exact infinity.
      if (extrabits == zero(@UInt))
        ((@u x) == @signbit) && return reinterpret($T, @signbit)
        ((@u x) == zero(@UInt)) && return reinterpret($T, zero(@UInt))
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
      ($checkbit & @u(x) == $z) && return reinterpret($T, truncated_value)
      #either the extrabits is nonzero or the checkmask is nonzero:  truncate then add one.
      ((extrabits != $z) || ((@u(x) & $checkmask) != $z)) && return reinterpret($T, truncated_value + $innerbit)
      #now we have something exactly in the middle.
      #check one bit inward, if that's one, add innerbit.  This results in "round to nearest even"
      return reinterpret($T, truncated_value + (@u(x) & $innerbit != $z) * $innerbit)
    end
  else
    checkbit = one(@UInt) << (__BITS - 1)
    checkmask = (-(@UInt)(1)) >> 1
    #requires the extrabits to ascertain rounding status.
    quote
      #if the top bit of "extra bits" is zero, then 'round down.'
      ($checkbit & extrabits == $z) && return x
      #if the remainder of "extra bits" is nonzero, always 'round up'.
      (extrabits & $checkmask != $z) && return next(x)
      #check the bottom bit and trigger a round to nearest even.
      return reinterpret($T, @u(x) + (@u(x) & one(@UInt)) * one(@UInt))
    end
  end
end
