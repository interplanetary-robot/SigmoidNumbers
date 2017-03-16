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

function bits{N,ES}(x::Valid{N,ES})
  string(bits(x.lower),bits(x.upper))
end

function bits{N,ES}(x::Valid{N,ES}, separator::AbstractString)
  string(bits(x.lower, separator),"|",bits(x.upper, separator))
end


export describe
