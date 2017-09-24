
#these four macros convert the Vnum value into the appropriate type of rounding
#sigmoid by calling the call constructors which are designed to handle bumping
#up or down the ubit.

macro upper(value)
  esc(:(isulp(($value).upper) ? reinterpret(Sigmoid{N,ES,:upper}, ($value).upper |> lub) : reinterpret(Sigmoid{N,ES,:exact}, ($value).upper)))
end

macro lower(value)
  esc(:(isulp(($value).lower) ? reinterpret(Sigmoid{N,ES,:lower}, ($value).lower |> glb) : reinterpret(Sigmoid{N,ES,:exact}, ($value).lower)))
end

macro exact(value)
  esc(:(reinterpret(Sigmoid{N,ES,:exact}, ($value).lower)))
end

recast_as_lower{N,ES}(x::Sigmoid{N,ES,:exact}) = x
recast_as_lower{N,ES}(x::Sigmoid{N,ES,:lower}) = x
recast_as_lower{N,ES}(x::Sigmoid{N,ES,:cross}) = reinterpret(Sigmoid{N,ES,:lower}, x)
recast_as_lower{N,ES}(x::Sigmoid{N,ES,:upper}) = reinterpret(Sigmoid{N,ES,:lower}, x)
macro rl(value)
  esc(:(recast_as_lower($value)))
end

recast_as_upper{N,ES}(x::Sigmoid{N,ES,:exact}) = x
recast_as_upper{N,ES}(x::Sigmoid{N,ES,:upper}) = x
recast_as_upper{N,ES}(x::Sigmoid{N,ES,:cross}) = reinterpret(Sigmoid{N,ES,:upper}, x)
recast_as_upper{N,ES}(x::Sigmoid{N,ES,:lower}) = reinterpret(Sigmoid{N,ES,:upper}, x)
macro ru(value)
  esc(:(recast_as_upper($value)))
end
