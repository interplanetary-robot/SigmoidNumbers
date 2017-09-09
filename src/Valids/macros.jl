
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
