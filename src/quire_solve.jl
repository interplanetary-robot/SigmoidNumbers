
#special type which represents an LUMatrix with permutations
immutable LUMatrix{T}
    m::Matrix{T}
    p::Vector{Int64}
end


#another testing function that makes life much easier:
luupper{T}(lu::LUMatrix{T}) = lu.m |> UpperTriangular
lulower{T}(lu::LUMatrix{T}) = (lu.m - luupper(lu) + eye(T, size(lu.m,1))) |> LowerTriangular

#just a testing function that tests the LU matrix.
function lureassemble{T}(lu::LUMatrix{T})
    lulower(lu) * luupper(lu)
end


# TODO: implement unit testing on this function.
@generated function solve_quire{T, onediag}(A::LowerTriangular{T}, B::AbstractVector{T}, quire = Quire(T), ::Type{Val{onediag}} = Val{false})
    first_factor, row_factor = if onediag
        :(B[1]), :(tmp)
    else
        :(B[1] / A[1,1]), :(tmp / A[row, row])
    end

    quote
        m,n = size(A); l = length(B)
        (l == m) || throw(DimensionMismatch("matrix is ($m x $n) and vector is $l"))
        res = Vector{T}(n)
        tmp = zero(T)

        #start with the first row, which does not require a quire.
        @inbounds res[1] = $first_factor
        #TODO: reimplement second row with a proper fused-multiply subtract instead of
        #quire.
        for row = 2:n
            set!(quire, B[row])
            for col = 1:row
                @inbounds tmp =fdp!(quire, res[col], -A[row, col])
            end
            @inbounds res[row] = $row_factor
        end
        res
    end
end

function solve_quire{T}(A::UpperTriangular{T}, B::AbstractVector{T}, quire = Quire(T))
    m,n = size(A); l = length(B)
    (l == m) || throw(DimensionMismatch("matrix is ($m x $n) and vector is $l"))
    res = Vector{T}(n)
    tmp = zero(T)

    #start with the last row, which does not require a quire.
    @inbounds res[m] = B[m] / A[m,m]
    #TODO: reimplement penultimate row with a proper fused-multiply subtract instead of
    #quire.
    for row = (m-1):-1:1
        @inbounds set!(quire, B[row])
        for col = (row+1):m
            @inbounds tmp =fdp!(quire, res[col], -A[row, col])
        end
        @inbounds res[row] = tmp / A[row, row]
    end
    res
end

function solve_quire{T}(LM::LUMatrix{T}, v::AbstractVector{T}, quire = Quire(T))
    M = LM.m
    p = LM.p
    #first, solve the lower matrix against the permuted values in the vector.

    m,n = size(M); l = length(v)
    (l == m) || throw(DimensionMismatch("matrix is ($m x $n) and vector is $l"))
    res = Vector{T}(m)
    tmp = zero(T)

    #next, permute the incoming vector
    for idx = 1:m
        res[p[idx]] = v[idx]
    end

    println("start: $res")
    res = solve_quire(LowerTriangular(M), res, quire, Val{true})
    #CONTINUE WITH CODE FOR THE UPPER MATRIX.
    println("intermediate: $res")

    solve_quire(UpperTriangular(M), res, quire)
end

function lu_factors!{T}(M::AbstractMatrix{T}, quire = Quire(T))::LUMatrix{T}
    # lufact_quire is only going to work on square matrices at this time.
    # this returns an LU factorized A along with a pivot permutation.
    m, n = size(M)
    info = 0
    #set up the pivot list.
    pivot_list = collect(1:m)
    @inbounds begin
        #here we use the doolittle algorithm for LU factorization because it
        #permits the use of the quire for numerical accuracy.  The doolittle
        #algorithm operates on one row of the upper matrix, followed by the
        #corresponding column of the lower matrix, so activity should be index
        #ed by diagonal.
        for diag = 1:m
            # here we're going to do pivots to optimize the process.
            # search for the maximum value in this column.
            pidx = indmax(M[diag:m, diag]) + diag - 1
            if pidx != diag
                #swap these rows
                (pivot_list[diag], pivot_list[pidx]) = (pivot_list[pidx], pivot_list[diag])

                #do the row interchange.
                if M[pidx, diag] != zero(T)
                    for col = 1:m
                        (M[diag, col], M[pidx, col]) = (M[pidx, col], M[diag, col])
                    end
                else
                    pivot_list[diag] = 0
                end
            end

            # solve columns in the upper matrix
            for upper_col = diag:m
                #signal which dot product we're gonna do.
                #then set up a
                accum = M[diag, upper_col]
                set!(quire, accum)
                for lower_col = 1:(diag-1)
                    accum = fdp!(
                      quire,
                      M[diag, lower_col],
                      -M[lower_col, upper_col])
                end
                M[diag, upper_col] = accum
            end

            #solve rows in the lower matrix
            factor = inv(M[diag, diag])
            for lower_row = (diag + 1):n
                accum = M[lower_row, diag]
                set!(quire, accum)
                for upper_row = 1:(diag-1)
                    accum = fdp!(
                      quire,
                      M[lower_row, upper_row],
                      -M[upper_row, diag])
                end
                M[lower_row, diag] = accum * factor
            end
        end
    end
    LUMatrix(M, pivot_list)
end

function solve_quire{T}(A::AbstractMatrix{T}, B::AbstractVector{T}, quire = Quire(T))
    m, n = size(A)
    if m == n
        if istril(A)
            if istriu(A)
                return Diagonal(A) \ B
            else
                return solve_quire(LowerTriangular(A), B, quire)
            end
        end
        if istriu(A)
            return solve_quire(UpperTriangular(A), B, quire)
        end
        return solve_quire(lu_factors!(copy(A)), B, quire)
    end
    throw(ArgumentError("currently, nonsquare matrices are not supported"))
end

function solve_quire_refine{T}(A::AbstractMatrix{T}, B::AbstractVector{T})
    res = solve_quire(A, B)
    res = refine(res, A, B)
    res = refine(res, A, B)
end
