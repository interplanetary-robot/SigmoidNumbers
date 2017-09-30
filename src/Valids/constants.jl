
Base.one{N,ES}(T::Type{Valid{N,ES}}) = Valid(one(Vnum{N,ES}), one(Vnum{N,ES}))
Base.zero{N,ES}(T::Type{Valid{N,ES}}) = Valid(zero(Vnum{N,ES}), zero(Vnum{N,ES}))

type ∅; end
type ℝ; end
type ℝp; end

Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{∅})  = Valid(zero(     Vnum{N,ES}), maxneg( Vnum{N,ES}))
Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{ℝ})  = Valid(-maxpos( Vnum{N,ES}), maxpos(      Vnum{N,ES}))
Base.convert{N, ES}(T::Type{Valid{N, ES}}, ::Type{ℝp}) = Valid(Vnum{N,ES}(Inf),       maxpos(      Vnum{N,ES}))

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

Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__plusstar}) =  Valid(minpos(Vnum{N, ES}),  maxpos(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__minusstar}) = Valid(-maxpos(Vnum{N, ES}), maxneg(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__positives}) = Valid(zero(Vnum{N, ES}),          maxpos(Vnum{N, ES}))
Base.convert{N,ES}(T::Type{Valid{N,ES}}, ::Type{__negatives}) = Valid(-maxpos(Vnum{N, ES}),         zero(Vnum{N, ES}))

export ∅, ℝ, ℝp
