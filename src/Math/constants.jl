import Base: one, zero, realmax, eps, issubnormal, isnan, isfinite

one{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}) = reinterpret(T, @invertbit)
zero{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}) = reinterpret(T, zero(@UInt))

@generated function realmax{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}})
  v = (@signbit) - increment(Sigmoid{N, ES, mode})
  :(reinterpret(T, $v))
end

@generated function pos_smallest{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}})
  v = zero(@UInt) + increment(Sigmoid{N, ES, mode})
  :(reinterpret(T, $v))
end

@generated function neg_smallest{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}})
  v = zero(@UInt) - increment(Sigmoid{N, ES, mode})
  :(reinterpret(T, $v))
end

@generated function eps{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}})
  if mode == :ubit
  else
  end
end

#no subnormals, no NaNs
issubnormal{N,ES,mode}(x::Sigmoid{N, ES, mode}) = false
isnan{N,ES,mode}(x::Sigmoid{N, ES, mode}) = false
isfinite{N,ES,mode}(x::Sigmoid{N, ES, mode}) = (@u(x) != @signbit)

#iszeroinf
iszeroinf(x::Sigmoid) = reinterpret(@UInt, x) & (~@signbit) == 0

#special constant type symbols
struct ∞; end
struct ∞n; end

Base.:-(::Type{∞}) = ∞n
Base.convert{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, ::Type{∞}) = T(Inf)
Base.convert{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, ::Type{∞n}) = T(Inf)

export ∞
