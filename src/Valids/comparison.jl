#comparison.jl -- comparison operators for valids.

function Base.:(==){N,ES}(x::Valid{N,ES}, y::Valid{N,ES})
    if (next(x.upper) == x.lower) & (next(y.upper) == y.lower)

        x_null = (x.upper == zero(Vnum{N,ES})) | (x.lower == zero(Vnum{N,ES}))
        y_null = (y.upper == zero(Vnum{N,ES})) | (y.lower == zero(Vnum{N,ES}))

        return x_null == y_null
    end
    return (x.upper == y.upper) && (x.lower == y.lower)
end
