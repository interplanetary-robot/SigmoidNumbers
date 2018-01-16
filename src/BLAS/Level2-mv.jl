#level 2 matrix vector multiplication


################################################################################
## GBMV - general band matrix vector multiply

function BLAS.gbmv!{T<:Posit}(tA::Char, m::Integer, kl::Integer, ku::Integer, alpha::T, A::Matrix{T}, x::Vector{T}, beta::T, y::Vector{T})
    if tA == 'N' || tA == 'n'
        ngbmv!(m, kl, ku, alpha, A, x, beta, y)
    elseif tA == 'T' || tA == 't' || tA == "C" || tA == "c"
        tgbmv!(m, kl, ku, alpha, A, x, beta, y)
    else
        throw(ArgumentError("unknown tA specification for gbmv"))
    end
end

function BLAS.gbmv!{N,ES}(tA::Char,
        m::Integer,
        kl::Integer,
        ku::Integer,
        alpha::PositOrComplex{N,ES},
        A::Matrix{Complex{Posit{N,ES}}},
        x::Vector{Complex{Posit{N,ES}}},
        beta::PositOrComplex{N,ES},
        y::Vector{Complex{Posit{N,ES}}})

    println("using special blas!")

    if tA == 'N' || tA == 'n'
        ngbmv!(m, kl, ku, alpha, A, x, beta, y)
    elseif tA == 'T' || tA == 't'
        tgbmv!(m, kl, ku, alpha, A, x, beta, y)
    elseif tA == "C" || tA == "c"
        cgbmv!(m, kl, ku, alpha, A, x, beta, y)
    else
        throw(ArgumentError("unknown tA specification for gbmv"))
    end
end

function ngbmv!{N, ES}(
    m::Integer,
    kl::Integer,
    ku::Integer,
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 2) != length(x))
        throw(DimensionMismatch("matrix A has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 1) != length(y))
        throw(DimensionMismatch("matrix A has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        res = naked_dot(A[start:stop, row], x[start:stop], alpha, beta, y[row])
        y[row] = res
    end
end

function tgbmv!{N,ES}(
    m::Integer,
    kl::Integer,
    ku::Integer,
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 1) != length(x))
        throw(DimensionMismatch("matrix A' has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 1) != m)
        throw(DimensionMismatch("matrix A' has dimension 1 $(size(A,1)), but passed value m is $(m)"))
    elseif (size(A, 2) != length(y))
        throw(DimensionMismatch("matrix A' has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        start = clamp(row - kl, 1, m)
        stop =  clamp(row + kl, 1, m)
        res = naked_dot(A[row, start:stop], x[start:stop], alpha, beta, y[row])
        y[row] = res
    end
end

function cgbmv!{N,ES}(
    m::Integer,
    kl::Integer,
    ku::Integer,
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 1) != length(x))
        throw(DimensionMismatch("matrix A' has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 2) != length(y))
        throw(DimensionMismatch("matrix A' has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        start = clamp(row - kl, 1, m)
        stop =  clamp(row + kl, 1, m)
        res = naked_dot(A[row, start:stop], x[start:stop], alpha, beta, y[row], Val{:conj})
        y[row] = res
    end
end

################################################################################
## GEMV - general matrix vector multiply

function BLAS.gemv!{T<:Posit}(tA::Char, alpha::T, A::Matrix{T}, x::Vector{T}, beta::T, y::Vector{T})

    if tA == 'N' || tA == 'n'
        ngemv!(alpha, A, x, beta, y)
    elseif tA == 'T' || tA == 't' || tA == "C" || tA == "c"
        tgemv!(alpha, A, x, beta, y)
    else
        throw(ArgumentError("unknown tA specification for gemv"))
    end
end

function BLAS.gemv!{N,ES}(tA::Char,
        alpha::PositOrComplex{N,ES},
        A::Matrix{Complex{Posit{N,ES}}},
        x::Vector{Complex{Posit{N,ES}}},
        beta::PositOrComplex{N,ES},
        y::Vector{Complex{Posit{N,ES}}})

    if tA == 'N' || tA == 'n'
        ngemv!(alpha, A, x, beta, y)
    elseif tA == 'T' || tA == 't'
        tgemv!(alpha, A, x, beta, y)
    elseif tA == "C" || tA == "c"
        cgemv!(alpha, A, x, beta, y)
    else
        throw(ArgumentError("unknown tA specification for gemv"))
    end
end

################################################################################

function ngemv!{N,ES}(
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 2) != length(x))
        throw(DimensionMismatch("matrix A has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 1) != length(y))
        throw(DimensionMismatch("matrix A has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        res = naked_dot(A[:, row], x, alpha, beta, y[row])
        y[row] = res
    end
end

function tgemv!{N,ES}(
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 1) != length(x))
        throw(DimensionMismatch("matrix A' has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 2) != length(y))
        throw(DimensionMismatch("matrix A' has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        res = naked_dot(A[row, :], x, alpha, beta, y[row])
        y[row] = res
    end
end

function cgemv!{N,ES}(
    alpha::PositOrComplex{N,ES},
    A::Matrix{<:PositOrComplex{N,ES}},
    x::Vector{<:PositOrComplex{N,ES}},
    beta::PositOrComplex{N,ES},
    y::Vector{<:PositOrComplex{N,ES}})

    #dimension checking.
    if (size(A, 1) != length(x))
        throw(DimensionMismatch("matrix A' has dimension 2 $(size(A,2)), but x has length $(length(x))"))
    elseif (size(A, 1) != length(y))
        throw(DimensionMismatch("matrix A has dimension 1 $(size(A,1)), but y has length $(length(y))"))
    end

    for row = 1:size(A,1)
        res = naked_dot(A[row, :], x, alpha, beta, y[row], Val{:conj})
        y[row] = res
    end
end


#hermitian matrices
#hbmv
#hemv
#hpmv

#symmetric band matrices
#sbmv
#spmv

#symmetric matrices
#symv

#triangular matrices
#tbmv
#tpmv
#trmv
