function describe{N, ES}(x::Valid{N, ES})
  if N <= 32
    lower_u = isulp(x.lower)
    upper_u = isulp(x.upper)

    lvalue = Float64(glb(x.lower))
    rvalue = Float64(lub(x.upper))

    if (lvalue == rvalue)
      println("Valid(", lvalue, " ex)")
    else
      println("Valid(", lvalue, lower_u ? " op" : " ex", " → ", rvalue, upper_u ? " op)": " ex)")
    end
  else
  end
end

export describe
