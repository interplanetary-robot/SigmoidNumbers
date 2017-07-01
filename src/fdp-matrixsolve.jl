
doc"""
  SigmoidNumbers.get_unscaled_replacement_row!(rr, M, row, cache, quire)

  takes the matrix M and specifies a good "replacement row" for it.  You should
  also supply a cache vector which is used to store magic values, it should be
  the length of rr.
"""
function get_unscaled_replacement_row!{T}(rr::Vector{T}, M::Matrix{T}, row, cached_coefficients::Vector{T}, quire)
  l = length(rr)

  @assert(size(M) == (l, l))
  @assert(length(cached_coefficients) == l)
  @assert(row > 1)

  #generate a quire for use in the function, and a variable to hold intermediates.
  res = zero(T)

  #first column is special.  simply set the magic value cache to be the negative
  #of the row number, then zero it out.
  cached_coefficients[1] = - M[row, 1]
  rr[1] = zero(T)

  for column = (2:row - 1)
    set!(quire, M[row, column]) #we'll subtract values from this as a tally.

    #scan down the vrows to obtain the coefficients for value reduction.
    for vrow = 1:(column - 1)
      res = fdp!(quire, cached_coefficients[vrow], M[vrow, column])
    end

    #finally, set the early column in the row to be zero.
    cached_coefficients[column] = -res
    rr[column]    = zero(T)
  end

  for column = row:l
    set!(quire, M[row, column])
    #scan down the vrows to obtain reduce the coeffients again.
    for vrow = 1:(row -1)
      res = fdp!(quire, cached_coefficients[vrow], M[vrow, column])
    end
    #set the column in the replacement row.
    rr[column] = res
  end

  #don't bother returning anything, since otherwise it would be confusing.
  nothing
end

function diminish_result_vector!{T}(v::Vector{T}, row, cached_coefficients::Vector{T}, quire)
  #alter the vector in the same fashion.
  set!(quire, v[row])
  res = zero(T)
  for trow = 1:(row - 1)
    res = fdp!(quire, v[trow], cached_coefficients[trow])
  end
  v[row] = res
end


function rescale_row!{T}(M::Matrix{T}, row)
  value = M[row, row]
  for col = (row + 1):size(M,2)
    M[row,col] /= value
  end
  M[row, row] = one(T)
  value
end

doc"""
  SigmoidNumbers.row_echelon!(M, v)

  converts (M, v) matrix/vector into row-echelon form, with partial pivoting
  Uses quires.
"""
function row_echelon!{T}(M::Matrix{T}, v::Vector{T}, quire = Quire(T))
  eqs = length(v)
  @assert size(M) == (eqs, eqs)
  #convert to row-echelon form.

  #create a temporary array that stores intermediate row values.
  t_row = zeros(T, eqs)
  #create a temporary array that stores the prime row values.
  cached_coefficients = zeros(T, eqs)
  cached_replacement_row = zeros(T, eqs)
  #a usable result variable for obtaining a quire result.
  res = zero(T)

  for row = 1:eqs           #go down each row.
    #partial pivoting.
    if row < eqs
      #find the maximum entry among things in this column.
      swap_index = indmax(abs.(M[row:eqs,row])) + row - 1
      if swap_index != row
        cached_replacement_row = M[row, :]
        M[row,:] = M[swap_index, :]
        M[swap_index, :] = cached_replacement_row

        cache = v[row]
        v[row] = v[swap_index]
        v[swap_index] = cache
      end
    end

    if row > 1
      get_unscaled_replacement_row!(cached_replacement_row, M, row, cached_coefficients, quire)

      #replace the row of the matrix.
      M[row,:] = cached_replacement_row

      diminish_result_vector!(v, row, cached_coefficients, quire)
    end

    scale = rescale_row!(M, row)
    v[row] /= scale

  end

  (M, v)
end

doc"""
  SigmoidNumbers.solve_row_echelon!(result, M, v, quire)

  solves a system of linear equations that's in row-echelon form.
"""
function solve_row_echelon!{T}(result::Vector{T}, M::Matrix{T}, v::Vector{T}, quire = Quire(T))
  l = length(v)
  @assert(length(result) == l)
  @assert(size(M) == (l,l))
  res = zero(T)
  result[l] = v[l]
  for row = l-1:-1:1
    set!(quire, v[row])
    for col = l:-1:(row+1)
      res = fdp!(quire, M[row, col], -result[col])
    end
    result[row] = res
  end
end

function solve{T}(M::Matrix{T}, v::Vector{T})
  quire = Quire(T)
  (Mre, vre) = row_echelon!(copy(M), copy(v), quire)
  r = Vector{T}(length(v))
  solve_row_echelon!(r, Mre, vre, quire)
  r
end

doc"""
  find_residual(M, r, v)
  calculates v - M * r, using exact dot products.
"""
function find_residuals{T}(M::Matrix{T}, r::Vector{T}, v::Vector{T}, quire = Quire(T))
  res = zeros(T, length(v))
  for dim = 1:length(v)
    set!(quire, v[dim])
    for (m, ri) in zip(M[dim, :], r)
      res[dim] = fdp!(quire, m, -ri)
    end
  end
  res
end

doc"""
  refine(r, M, v)

  calculates M * r and finds the residuals with respect to the solution v,
  and then solves those residuals and applies it back to r.
"""
function refine{T}(r::Vector{T}, M::Matrix{T}, v::Vector{T})
  quire = Quire(T)
  #first, find the residual.
  residual = find_residuals(M, r, v, quire)
  #then solve the residual, and augment r.
  deltas = solve(M, residual)
  r + deltas
end

################################################################################
#for testing purposes, random_exact_row(n) and random_exact_matrix(n) routines.

function obliterate_lsb{N,ES}(pvalue::Posit{N,ES})
  (s, exp, frc) = posit_components(pvalue)
  if frc == zero(UInt64)
    #bump up an exponent.
    Posit{N,ES}(s, exp + 1, frc)
  else
    #find the trailing zero, xor it out.
    Posit{N,ES}(s, exp, frc $ (one(UInt64) << trailing_zeros(frc)))
  end
end

doc"""
  SigmoidNumbers.random_exact_row(n)
  creates a row that is summable to an exact number.
"""
function random_exact_row{N,ES}(::Type{Posit{N,ES}}, count, randomizer::Function = rand, q::Quire = Quire(Posit{N,ES}))
  #first generate a <count> number of random values.
  current_row_vector = Posit{N,ES}.(randomizer(count))

  #also write a function that gets updates the lsb.
  function get_row_lsb()
    zero!(q)
    exact_sum(current_row_vector, q)
    find_lsb(q)
  end

  old_lsb = get_row_lsb()

  while true

    (old_lsb == find_lsb(Posit{N,ES}(q))) && return current_row_vector

    #next twiddle the values
    (_, idx) = findmin(map(find_lsb, current_row_vector))

    #obliterate the lsb in the indexed value
    current_row_vector[idx] = obliterate_lsb(current_row_vector[idx])

    new_lsb = get_row_lsb()

    #eject and redo in the case that our bitflipping is not trivially soluble.  The
    #less than should not strictly be necessary but it's there to prevent
    (new_lsb <= old_lsb) && return random_exact_row(Posit{N,ES}, count, randomizer, q)

    old_lsb = new_lsb
  end
end

function random_exact_matrix{N,ES}(::Type{Posit{N,ES}}, count, randomizer::Function = rand, q::Quire = Quire(Posit{N,ES}))
  M = zeros(Posit{N,ES}, count, count)
  for row = 1:count
    M[row, :] = random_exact_row(Posit{N,ES}, count, randomizer)
  end
  M
end

exact_rowsum{N,ES}(M::Matrix{Posit{N,ES}}) = [exact_sum(M[row, :]) for row = 1:size(M,1)]

Base.big{N,ES}(x::Posit{N,ES}) = big(Float64(x))

export solve, refine, random_exact_matrix, exact_rowsum
