#ubox method.

macro vcat2(lhs, rhs)
    esc(:(vcat(ufilter(pred, $lhs, Val{verbose}), ufilter(pred, $rhs, Val{verbose}))))
end

"""
  ufilter(predicate, dataset::Vector{Any})
"""
function ufilter(pred::Function, x::Valid{N,ES}, ::Type{Val{verbose}} = Val{false}) where {N, ES, verbose}
    if pred(x)
        verbose && println("interval $x checks out.")
        if istile(x)
            return Valid{N,ES}[x]
        elseif (x.upper == next(x.lower))
            return @vcat2 tile(x.lower) tile(x.upper)
        elseif (isallreals(x))
            return @vcat2 Vnum{N,ES}(Inf) → maxneg(Vnum{N,ES}) zero(Vnum{N,ES}) → maxpos(Vnum{N,ES})
        elseif (roundsinf(x))
            if !isfinite(x.lower)
                return @vcat2 Valid{N,ES}(Inf) minneg(Vnum{N,ES}) → x.upper
            elseif !isfinite(x.upper)
                return @vcat2 Valid{N,ES}(Inf) x.lower → maxpos(Vnum{N,ES})
            else
                return @vcat2 x.lower → Vnum{N,ES}(Inf) minneg(Valid{N,ES}) → x.upper
            end
        else
            middle = reinterpret(Vnum{N,ES}, (@u x.lower) >> 1 + (@u x.upper) >> 1) |> __round
            return @vcat2 x.lower → middle next(middle) → x.upper
        end
    else
        return Valid{N,ES}[]
    end
end

export ufilter
