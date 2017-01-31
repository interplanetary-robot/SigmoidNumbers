
type ∅; end
type ℝ; end
type ℝp; end

Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{∅})  = Valid(zero(     Vnum{N,ES}), neg_smallest( Vnum{N,ES}))
Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{ℝ})  = Valid(-realmax( Vnum{N,ES}), realmax(      Vnum{N,ES}))
Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{ℝp}) = Valid(Vnum{N,ES}(Inf),       realmax(      Vnum{N,ES}))

type __plusstar; end
Base.:+(::typeof(Base.:*)) = __plusstar
type __minusstar; end
Base.:-(::typeof(Base.:*)) = __minusstar
type __positives; end
type __negatives; end

(::Type{ℝ})(::Type{__plusstar}) =      __plusstar
(::Type{ℝ})(::Type{__minusstar}) =     __minusstar
(::Type{ℝ})(::typeof(+)) =             __positives
(::Type{ℝ})(::typeof(-)) =             __negatives

Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__plusstar}) =  Valid(pos_smallest(Vnum{N, ES}),  realmax(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__minusstar}) = Valid(-realmax(Vnum{N, ES}), neg_smallest(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__positives}) = Valid(zero(Vnum{N, ES}),          realmax(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__negatives}) = Valid(-realmax(Vnum{N, ES}),         zero(Vnum{N, ES}))

export ∅, ℝ, ℝp
