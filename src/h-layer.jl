
import Base: bits, show

bits{N, ES, mode}(x::Sigmoid{N, ES, mode}) = bits(reinterpret(@UInt, x))[1:N]
function bits{N, ES, mode}(x::Sigmoid{N, ES, mode}, separator::AbstractString)
  #we're going to create this as a string array, then join() it at the end.
  stringarray = Vector{String}()

  bitstring = bits(x)

  push!(stringarray, bitstring[1:1])
  seek_idx = 2
  term_idx = N - (mode == :ubit) #store the index of termination.

  #calculate how many regime bits there are
  r_length = regimebits(x)

  push!(stringarray, bitstring[seek_idx:(seek_idx + r_length - 1)])
  seek_idx += r_length

  (seek_idx > term_idx) && @goto finish

  if (ES > 0)
    if ((seek_idx + ES) < term_idx)
      push!(stringarray, bitstring[seek_idx:seek_idx + ES - 1])
      seek_idx += ES
    else
      push!(stringarray, bitstring[seek_idx:term_idx])
      @goto finish
    end
  end

  push!(stringarray, bitstring[seek_idx:term_idx])

  @label finish

  if mode == :ubit
    push!(stringarray, bitstring[end:end])
  end

  return join(stringarray, separator)
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
