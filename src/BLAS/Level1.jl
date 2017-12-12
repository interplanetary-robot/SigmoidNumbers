
#ASUM: BLAS function for calculating sum of absolute values.
doc"""
  asum_naive(n::Integer, X::Array{Posit}, stride::Integer)

  calculates the sum of the first n strided values in X.
"""
function asum_naive{N,ES}(n::Integer, X::DenseArray{PositOrComplex{N,ES}}, incx::Integer)
    #see LAPACK sasum.f for code reference:
    # http://www.netlib.org/lapack/explore-html/df/d28/group__single__blas__level1_gafc5e1e8d9f26907c0a7cf878107f08cf.html#gafc5e1e8d9f26907c0a7cf878107f08cf

    #corner case checking.
    (n <= 0 || incx <= 0) && return zero(Posit{N,ES})
    #throwing a bounds error early allows us to use @inbounds optimization in the
    #for loop.
    (n*incx) > length(X) && throw(BoundsError(X, n*incx))

    #when the increment is 1, we can use the builtin mapreduce function which we
    #presume should be language-optimized.
    (incx == 1) && return mapreduce(abs, +, (n == length(X)) ? X : X[1:n])

    #for non-one increment, just do a for loop manually.
    accumulator = zero(Posit{N,ES})
    for idx in 1:incx:n*incx
        @inbounds accumulator += abs(X[idx])
    end
    accumulator
end

function BLAS.asum{N,ES}(n::Integer, X::DenseArray{<:PositOrComplex{N,ES}}, incx::Integer)

    #corner case checking.
    (n <= 0 || incx <= 0) && return zero(Posit{N,ES})
    (n*incx) > length(X) && throw(BoundsError(X, n*incx))

    zero!(__real_quire)
    if (incx == 1)
        foreach(p -> add!(__real_quire, abs(p)), n == length(X) ? X : X[1:n])
        return Posit{N,ES}(__real_quire)
    end

    #declare the local accumulator value.
    accumulator = zero(Posit{N,ES})
    for idx in 1:incx:n*incx
        accumulator = add!(__real_quire, abs(X[idx]))
    end
    accumulator
end

function axpy!{N,ES}(α, x::AbstractArray{Posit{N,ES}}, y::AbstractArray{Posit{N,ES}})
    n = _length(x)
    if n != _length(y)
        throw(DimensionMismatch("x has length $n, but y has length $(_length(y))"))
    end
    for (IY, IX) in zip(eachindex(y), eachindex(x))
        @inbounds y[IY] = fma(α, x[IX], y[IY])
    end
    y
end

function Base.dot{N,ES}(n::Integer, x::AbstractArray{Posit{N,ES}}, incx::Integer, y::AbstractArray{Posit{N,ES}}, incy::Integer)
    (n <= 0 || incx <= 0) && return zero(Posit{N,ES})
    (n * incx) > length(x) && throw(BoundsError(y, n * incx))
    (n * incy) > length(y) && throw(BoundsError(y, n * incy))

    accumulator = zero(Posit{N,ES})
    zero!(__real_quire)
    for (xidx,yidx) in zip(1:incx:n*incx, 1:incy:n*incy)
        @inbounds accumulator = fdp!(__real_quire, x[xidx], y[yidx])
    end
    accumulator
end

function Base.dot{N,ES}(n::Integer, x::AbstractArray{Complex{Posit{N,ES}}}, incx::Integer, y::AbstractArray{Complex{Posit{N,ES}}}, incy::Integer)
    (n <= 0 || incx <= 0) && return zero(Posit{N,ES})
    (n * incx) > length(x) && throw(BoundsError(y, n * incx))
    (n * incy) > length(y) && throw(BoundsError(y, n * incy))

    zero!(__real_quire)
    zero!(__imag_quire)
    real_accumulator = zero(Posit{N,ES})
    imag_accumulator = zero(Posit{N,ES})
    for (xidx,yidx) in zip(1:incx:n*incx, 1:incy:n*incy)
        @inbounds real_accumulator = fdp!(__real_quire, real(x[xidx]), real(y[yidx]))
        @inbounds real_accumulator = fdp!(__real_quire, -imag(x[xidx]), imag(y[yidx]))
        @inbounds imag_accumulator = fdp!(__imag_quire, real(x[xidx]), imag(y[yidx]))
        @inbounds imag_accumulator = fdp!(__imag_quire, imag(x[xidx]), real(y[yidx]))
    end
    real_accumulator + imag_accumulator * im
end

function Base.dot{N,ES}(x::AbstractArray{Posit{N,ES}}, y::AbstractArray{Posit{N,ES}})
    if length(x) != length(y)
        throw(length(x) > length(y) ? BoundsError(x, length(y) + 1) : BoundsError(y, length(x) + 1))
    end
    zero!(__real_quire)
    accumulator = zero(Posit{N,ES})
    for idx in 1:length(x)
        @inbounds accumulator = fdp!(__real_quire, x[idx], y[idx])
    end
    accumulator
end

function Base.dot{N,ES}(x::AbstractArray{Complex{Posit{N,ES}}}, y::AbstractArray{Complex{Posit{N,ES}}})
    if length(x) != length(y)
        throw(length(x) > length(y) ? BoundsError(x, length(y) + 1) : BoundsError(y, length(x) + 1))
    end
    zero!(__real_quire)
    zero!(__imag_quire)
    real_accumulator = zero(Posit{N,ES})
    imag_accumulator = zero(Posit{N,ES})
    for idx in 1:length(x)
        @inbounds real_accumulator = fdp!(__real_quire, real(x[xidx]), real(y[yidx]))
        @inbounds real_accumulator = fdp!(__real_quire, -imag(x[xidx]), imag(y[yidx]))
        @inbounds imag_accumulator = fdp!(__imag_quire, real(x[xidx]), imag(y[yidx]))
        @inbounds imag_accumulator = fdp!(__imag_quire, imag(x[xidx]), real(y[yidx]))
    end
end
