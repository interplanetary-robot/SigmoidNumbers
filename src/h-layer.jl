
import Base: bits, show

bits{N, ES, mode}(x::Sigmoid{N, ES, mode}) = bits(reinterpret(@UInt, x))[1:N]
function bits{N, ES, mode}(x::Sigmoid{N, ES, mode}, separator::AbstractString)
  bitstring = bits(x)
  signstring = bitstring[1]
  r_length = 1 + regimelength(x)
  regimestring = bitstring[2:r_length]
  exponentstring = bitstring[r_length+1:min(r_length + ES, N)]
  if (r_length + ES < N)
    join((signstring, regimestring, exponentstring), separator)
  else
    join((signstring, regimestring, exponentstring, bitstring[r_length + ES + 1:end]), separator)
  end
end

function show{N, ES, mode}(io::IO, x::Sigmoid{N, ES, mode})

  show(io,typeof(x))

  #isfinite(x) || (print(io, "$classname(Inf)"); return)
  #iszero(x)   || (print(io, "zero($classname)"); return)

  innerval = hex(reinterpret(@UInt, x),(__BITS ÷ 4))

  print(io, "(0x$innerval)")
end

@generated function show{T<:Sigmoid}(io::IO, ::Type{T})
  _N  = N(T)
  _ES = ES(T)
  _m  = mode(T)
  if (_m == :guess)
    sig = "{$_N,$_ES}"
    :(print(io, "Posit", $sig))
  elseif (_m == :ubit)
    sig = "{$_N,$_ES}"
    :(print(io, "Valid", $sig))
  else
    sig = "{$_N,$_ES,$_m}"
    :(print(io, "Sigmoid", $sig))
  end
end
