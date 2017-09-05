
function describe{N, ES}(x::Valid{N, ES}, f = println)
  isnan(x)      && return string("Valid{$N,$ES}(∅)")                               |> f
  isallreals(x) && return string("Valid{$N,$ES}(ℝp)")                              |> f

  if (x.upper == realmax(Vnum{N,ES}))
    (x.lower == zero(Vnum{N,ES})) && return string("Valid{$N,$ES}(ℝ(+))")          |> f
    (x.lower == pos_smallest(Vnum{N,ES})) && return string("Valid{$N,$ES}(ℝ(+*))") |> f
    (x.lower == -realmax(Vnum{N,ES})) && return string("Valid{$N,$ES}(ℝ)")         |> f
  end

  if (x.lower == -realmax(Vnum{N,ES}))
    (x.upper == zero(Vnum{N,ES})) && return string("Valid{$N,$ES}(ℝ(-))")          |> f
    (x.upper == neg_smallest(Vnum{N,ES})) && return string("Valid{$N,$ES}(ℝ(-*))") |> f
  end

  if N <= 32
    lower_u = isulp(x.lower)
    upper_u = isulp(x.upper)

    lvalue = Float64(glb(x.lower))
    rvalue = Float64(lub(x.upper))

    if (lvalue == rvalue)
      string("Valid{$N,$ES}(", lvalue, " ex)") |> f
    else
      string("Valid{$N,$ES}(", lvalue, lower_u ? " op" : " ex", " → ", rvalue, upper_u ? " op)": " ex)") |> f
    end
  else
  end
end

function describe{N,ES}(x::Vnum{N,ES}, f = println)
  lvalue = Float64(glb(x))
  rvalue = Float64(lub(x))

  if (lvalue == rvalue)
    string("Vnum{$N,$ES}(", lvalue, " ex)") |> f
  else
    string("Vnum{$N,$ES}(", lvalue, " op", " → ", rvalue, " op)") |> f
  end
end

function bits{N,ES}(x::Valid{N,ES})
  string(bits(x.lower),bits(x.upper))
end

function bits{N,ES}(x::Valid{N,ES}, separator::AbstractString)
  string(bits(x.lower, separator),"|",bits(x.upper, separator))
end

function show{N,ES}(io::IO, x::Valid{N,ES})
  println(io, x.lower, " → " , x.upper)
end

export describe
