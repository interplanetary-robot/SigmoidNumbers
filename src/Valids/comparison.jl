#comparison.jl -- comparison operators for valids.

function Base.:(==){N,ES}(x::Valid{N,ES}, y::Valid{N,ES})
    if (next(x.upper) == x.lower) & (next(y.upper) == y.lower)

        x_null = (x.upper == zero(Vnum{N,ES})) | (x.lower == zero(Vnum{N,ES}))
        y_null = (y.upper == zero(Vnum{N,ES})) | (y.lower == zero(Vnum{N,ES}))

        return x_null == y_null
    end
    return (x.upper == y.upper) && (x.lower == y.lower)
end

function Base.max{N,ES}(x::Sigmoid{N,ES,:exact}, y::Sigmoid{N,ES,:lower})
    x == Sigmoid{N,ES,:exact}(Inf) && return x
    (@s x) <= (@s y) ?  y : x
end
function Base.max{N,ES}(x::Sigmoid{N,ES,:exact}, y::Sigmoid{N,ES,:upper})
    x == Sigmoid{N,ES,:exact}(Inf) && return x
    (@s x) >= (@s y) ?  x : y
end
Base.max{N,ES}(x::Sigmoid{N,ES,:lower}, y::Sigmoid{N,ES,:exact}) = max(y,x)
Base.max{N,ES}(x::Sigmoid{N,ES,:upper}, y::Sigmoid{N,ES,:exact}) = max(y,x)

function Base.min{N,ES}(x::Sigmoid{N,ES,:exact}, y::Sigmoid{N,ES,:lower})
    x == Sigmoid{N,ES,:exact}(Inf) && return x
    (@s x) <= (@s y) ?  x : y
end
function Base.min{N,ES}(x::Sigmoid{N,ES,:exact}, y::Sigmoid{N,ES,:upper})
    x == Sigmoid{N,ES,:exact}(Inf) && return x
    (@u s) >= (@s y) ?  y : x
end
Base.min{N,ES}(x::Sigmoid{N,ES,:lower}, y::Sigmoid{N,ES,:exact}) = min(y,x)
Base.min{N,ES}(x::Sigmoid{N,ES,:upper}, y::Sigmoid{N,ES,:exact}) = min(y,x)
