import Base: one, zero

one{N, mode}(T::Type{Sigmoid{N, mode}}) = reinterpret(T, @invertbit)
zero{N, mode}(T::Type{Sigmoid{N, mode}}) = reinterpret(T, zero(@UInt))
