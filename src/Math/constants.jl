import Base: one, zero, realmax, eps, issubnormal, isnan, isfinite

one{N, ES, mode}(T::Type{SigmoidSmall{N, ES, mode}}) = reinterpret(T, @invertbit)
zero{N, ES, mode}(T::Type{SigmoidSmall{N, ES, mode}}) = reinterpret(T, zero(@UInt))

@generated function realmax{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}})
  v = (@signbit) - increment(T)
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

#special constant type symbols
type ∞; end
type ∞n; end

Base.:-(::Type{∞}) = ∞n
Base.convert{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, ::Type{∞}) = T(Inf)
Base.convert{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, ::Type{∞n}) = T(Inf)

type ∅; end
type ℝ; end
type ℝp; end

Base.convert{N, ES}(T::Type{VBound{N, ES}}, ::Type{∅}) = VBound(zero(Valid{N,ES}), neg_smallest(Valid{N,ES}))
Base.convert{N, ES}(T::Type{VBound{N, ES}}, ::Type{ℝ}) = VBound(-realmax(Valid{N,ES}),  realmax(Valid{N,ES}))
Base.convert{N, ES}(T::Type{VBound{N, ES}}, ::Type{ℝp}) = VBound(inf(Valid{N,ES}),  realmax(Valid{N,ES}))

export ∞, ∅, ℝ, ℝp
