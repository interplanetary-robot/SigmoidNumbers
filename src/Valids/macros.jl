
#these four macros convert the Vnum value into the appropriate type of rounding
#sigmoid by calling the call constructors which are designed to handle bumping
#up or down the ubit.

macro upper(value)
  :(Sigmoid{N,ES,:upper}($value))
end

macro lower(value)
  :(Sigmoid{N,ES,:lower}($value))
end

macro inner(value)
  :(Sigmoid{N,ES,:inner}($value))
end

macro outer(value)
  :(Sigmoid{N,ES,:outer}($value))
end

#generates upper and lower statements which convert back to valids, with an
#ulpstmt that ensures the result is an ulp if the results started as not ulps.

macro upper_valid(value, ulp1, ulp2)
  esc(quote
    (isulp($ulp1) | isulp($ulp2)) ? lower_ulp(reinterpret(Sigmoid{N,ES,:ubit}, $value)) : reinterpret(Sigmoid{N,ES,:ubit}, $value)
  end)
end

macro lower_valid(value, ulp1, ulp2)
  esc(quote
    (isulp($ulp1) | isulp($ulp2)) ? upper_ulp(reinterpret(Sigmoid{N,ES,:ubit}, $value)) : reinterpret(Sigmoid{N,ES,:ubit}, $value)
  end)
end
