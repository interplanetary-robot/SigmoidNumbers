#  fdp.jl
#  fused dot product and related methods.
#  this code was funded by Etaphase, inc, as part of DARPA TRADES program
#  award number BAA-16-39

doc"""
  SigmoidNumbers::Quire

  represents the 'quire' data structure.  This is a scratchpad of unsigned
  integers which represents a mutable fixed point value, useful as an
  accumulator for fused floating point operations.

  Currently, no shortcut operations are supported.
"""

type Quire
  fixed_point_value::Vector{UInt64}
  infinity::Bool
end

#a few properties:
maxpos(::Type{Quire}) = 2047
minpos(::Type{Quire}) = -2048
Base.isinf(q::Quire) = q.infinity
iszero(q::Quire) = mapreduce((n) -> (n == zero(UInt64)), &, true, q.fixed_point_value )

#a few convenience functions.
maximum_exponent{N,ES}(::Type{Posit{N,ES}}) = (2^(ES) * N - 2)
minimum_exponent{N,ES}(::Type{Posit{N,ES}}) = -(2^(ES) * N - 2)

#create a zeroed quire.
function (::Type{Quire}){N,ES}(::Type{Posit{N,ES}})
  # IN THE FUTURE:
  # calculate the  number of digits we'll need.  The top exponent is going to be
  # 2^(ES) * (N - 2).  Double that and you get 2^(ES + 1) * (N - 2)..  Then add padding.
  # bottom exponent is going to be 2^(ES) * (N - 2).

  #for now, default to accomodating an accumulator for {64, 4}.  Layout is as follows:
  # 32 words . 32 words
  Quire(zeros(UInt64, 64), false)
end

type fquire; q::Float64; end
(::Type{Quire})(::Type{Float64}) = fquire(zero(Float64))

zero!(q::fquire) = q.q = 0
#zeroes out the fused dot product accumulator.  Just throw out the old array.
function zero!(q::Quire)
  q.infinity = false
  for idx = 1:64
    q.fixed_point_value[idx] = zero(UInt64)
  end
end

doc"""
  inf!(q::Quire) forces the quire to carry an infinite value.
"""
inf!(q::Quire) = (q.infinity = true; q)
inf!(q::fquire) = (q.q = Inf; q)

doc"""
  isnegative(q::Quire) checks if the quire contains a negative value.
"""
isnegative(q::Quire) = (last(q.fixed_point_value) & 0x8000_0000_0000_0000) != 0

#this function builds a posit value based on some passed sign/exponent/fraction
#parameters.

function (::Type{Posit{N,0}}){N}(sign::Bool, exp::Int64, frac::UInt64)
  frac = frac >> 3
  #In both positive and negative cases, there's a straightforward translation of
  #exponent to the requisite shift.
  exp -= sign

  shift = (exp < 0) ? (-exp - 1) : exp
  frac |= (sign $ (exp < 0)) ? 0x2000_0000_0000_0000 : 0xC000_0000_0000_0000

  sfrac = reinterpret(Int64, frac)
  frac = reinterpret(UInt64, sfrac >> shift)

  frac = (sign) ? (frac | 0x8000_0000_0000_0000) : (frac & 0x7FFF_FFFF_FFFF_FFFF)

  __round(reinterpret(Posit{N,0}, frac))
end

function (::Type{Posit{N,ES}}){N,ES}(sign::Bool, exp::Int64, frac::UInt64)

  (exp < -2048) && return zero(Posit{N,ES})

  frac = frac >> (3 + ES)
  #In both positive and negative cases, there's a straightforward translation of
  #exponent to the requisite shift.

  exp -= sign
  reg = exp >> ES

  exp = ((1 << ES) - 1) & exp
  exp = (sign ? ((1 << ES) - 1) - exp : exp)

  shift = (reg < 0) ? (-reg - 1) : reg
  frac |= (sign $ (reg < 0)) ? 0x2000_0000_0000_0000 : 0xC000_0000_0000_0000
  exp_shifted = exp << (61 - ES)
  frac |= exp_shifted

  sfrac = reinterpret(Int64, frac)
  frac = reinterpret(UInt64, sfrac >> shift)

  frac = (sign) ? (frac | 0x8000_0000_0000_0000) : (frac & 0x7FFF_FFFF_FFFF_FFFF)

  __round(reinterpret(Posit{N,ES}, frac))
end

# an iterator that iterates over the quire indices and returns the fixed point
# cell contents.

immutable __p2quire_iter
  sgn::Bool
  exp::Int64
  frc::UInt64
  zero::Bool
end

__p2quire_iter{N,ES}(p::Posit{N,ES}) = __p2quire_iter(posit_components(p)..., p == zero(Posit{N,ES}))

#return the starting state, which is just index 1.
Base.start(pi::__p2quire_iter) = 1
#the quire iterator is finished when the index exceeds the array length.
Base.done(pi::__p2quire_iter, index::Int64) = (index > 64)
Base.length(pi::__p2quire_iter) = 64

#takes the index, and the iterator object, and returns the corresponding cell.
function Base.next(pi::__p2quire_iter, index::Int64)

  pi.zero && return (zero(UInt64), index + 1)

  #return the current item and the state.
  if pi.exp < (64 * (index - 33))

    #           34              33                32              31
    #            1               0                -1              -2
    #   |________________|________________|________________|________________|
    #    127           64 63             0 -1           -64 -65         -128
    #                     1XXXXXXXXXXXXXXX X
    #
    #   63 -> 1           64 -> 2

    (pi.sgn ? -one(UInt64) : zero(UInt64), index + 1)

  elseif pi.exp > (64 * (index - 31) - 1)

    #           34              33                32              31
    #            1               0                -1              -2
    #   |________________|________________|________________|________________|
    #    127           64 63             0 -1           -64 -65         -128
    #                   1 XXXXXXXXXXXXXXXX
    #
    #   -1 -> 64          -2 -> 63

    (zero(UInt64), index + 1)

  elseif pi.exp < (64 * (index - 32))  # top half case.
    #           34              33                32              31
    #            1               0                -1              -2
    #   |________________|________________|________________|________________|
    #    127           64 63             0 -1           -64 -65         -128
    #                     1XXXXXXXXXXXXXXX X
    #

    # first determine the shift.  Use this value to append the front value

    shift = (reinterpret(UInt64, pi.exp) & 0x3F)

    prefix           = (pi.sgn ? -one(UInt64) : one(UInt64)) << shift
    shifted_fraction = pi.frc >> (64 - shift + pi.sgn)

    (prefix | shifted_fraction, index + 1)

  elseif pi.exp == (64 * (index - 32)) #the strange case

    (pi.sgn ? pi.frc >> 1 : pi.frc, index + 1)

  else

    shift = reinterpret(UInt64, pi.exp) & 0x3F - pi.sgn

    (pi.frc << shift, index + 1)
  end
end


function positvals_from(q::Quire)
  #look at the top fixed point to get important info.
  msword = last(q.fixed_point_value)

  #determine the sign.
  sign = (msword & 0x8000_0000_0000_0000) != 0
  exponent = 2047 + sign
  fractionbits = 0
  fraction = zero(UInt64)
  summary = false

  for idx = 64:-1:1
    current_cell = q.fixed_point_value[idx]

    if fractionbits == 0
      #we haven't seen an exponent yet.
      exp_delta = (sign ? leading_ones(current_cell) : leading_zeros(current_cell))
      exponent -= exp_delta
      fractionbits = 64 - exp_delta
      fraction = current_cell << (exp_delta + 1)
    elseif fractionbits == -1
      #special case where we can transfer the entire fraction over.
      fraction = current_cell
      fractionbits = 64
    elseif fractionbits == 64
      #case where we've seen everything
      (current_cell != zero(UInt64)) && (return (sign, exponent, fraction, true))
    else  #we have an incomplete fraction.  This cycle WILL complete it.
      fraction |= current_cell >> (fractionbits - 1)
      current_cell = current_cell & ((one(UInt64) << (fractionbits - 1)) - one(UInt64))
      fractionbits = 64
      (current_cell != zero(UInt64)) && (return (sign, exponent, fraction, true))
    end
  end
  (sign, exponent, fraction, false)
end


function (::Type{Posit{N,ES}}){N,ES}(q::Quire)
  #exceptional value handling:
  isinf(q) && return Posit{N,ES}(Inf)

  (sgn,exp,frc,summ) = positvals_from(q)

  #check for zero
  (exp < -2048) && return zero(Posit{N,ES})

  Posit{N,ES}(sgn,exp,frc)  #for now.  We will have to manage inexacts later.

end

doc"""
  posit_components breaks up a posit into components (sign, exp, frac)

  frac is in 2's complement.  This representation corresponds to: (-1^sign) * 2^exp + (2^exp * (1.frac))
"""
function posit_components{N,ES}(x::Posit{N,ES})
  sign = (@u(x) & @signbit) != 0
  inverted = (@u(x) & @invertbit) == 0

  shift = max(leading_zeros(@u(x) & (~@signbit)),leading_ones(@u(x) | @signbit))
  regime = shift - 2 #(sign ? 2 : 3)
  regime = (sign $ inverted) ? -(regime + 1) : regime

  fraction = @u(x) << (shift + 1)

  #next extract the esize from the remainder of the fraction
  exp = ((-((@signbit) >> ES)) & fraction) >> (64 - ES)

  fraction = fraction << ES

  exponent = (regime + sign) << ES + (sign ? -@s(exp) : @s(exp))

  (sign, exponent, fraction)
end

################################################################################
## QUIRE FUNCTIONS

set!(q::fquire, x::Float64) = (q.q = x; x)

function set!{N,ES}(acc::Quire, x::Posit{N,ES})
  #shortcut evaluation of infinity.
  isinf(x) && return inf!(acc)
  acc.infinity = false

  for (idx, cell) in zip(1:64, __p2quire_iter(x))
    acc.fixed_point_value[idx] = cell
  end
  x
end

add!(q::fquire, x::Float64) = (q.q += x; q.q)
function add!{N,ES}(acc::Quire, x::Posit{N,ES})

  if isinf(x)
    isinf(acc) && throw(NaNError)
    return inf!(acc)
  end

  carry = false
  for (idx, cell) in zip(1:64, __p2quire_iter(x))
    old = acc.fixed_point_value[idx]
    acc.fixed_point_value[idx] += cell + carry
    carry = (acc.fixed_point_value[idx] <= old) & ((cell != zero(UInt64)) | (carry))
  end

  #return the cumulative sum.
  Posit{N,ES}(acc)
end

fdp!(q::fquire, a::Float64, b::Float64) = (q.q = fma(a, b, q.q); q.q)
function fdp!{N,ES}(acc::Quire, a::Posit{N,ES}, b::Posit{N,ES})

  #intercept exceptional cases.
  if isinf(a)
    (reinterpret(UInt64, a) == zero(UInt64)) && throw(NaNError(fdp!, a, b))
    isinf(acc) && throw(NaNError(fdp!, acc, [a, b]))
    inf!(acc)
    return Posit{N,ES}(Inf)
  end

  if isinf(b)
    (reinterpret(UInt64, a) == zero(UInt64)) && throw(NaNError(fdp!, [a, b]))
    isinf(acc) && throw(NaNError(fdp!, acc, [a, b]))
    inf!(acc)
    return Posit{N,ES}(Inf)
  end

  #intercept zero times anything, without changing the quire value.
  (reinterpret(UInt64, a) == zero(UInt64)) && return Posit{N,ES}(acc)
  (reinterpret(UInt64, b) == zero(UInt64)) && return Posit{N,ES}(acc)

  #the fused dot product will be calculated manually here.  For now, we'll only
  #support 32 bit x 32 bit fdp.

  (a_sgn, a_exp, a_frc) = posit_components(a)
  (b_sgn, b_exp, b_frc) = posit_components(b)

  #first, take the a_frc and b_frc and shift them right by 32 bits.
  a_frc_shft = a_frc >> 32
  b_frc_shft = b_frc >> 32

  #next actually do the multiplication.
  old_fraction = fraction = (a_frc_shft * b_frc_shft)#as a 64-bit unsigned integer.

  #the carry can be up to negative 2.
  mulcarry = 1 * (a_sgn ? -2 : 1) * (b_sgn ? -2 : 1)

  #next, add in the a_frc value
  if b_sgn
    #in the case that b is negative, invert and right shift the fraction addend.
    deltacarry = ((a_frc & 0x8000_0000_0000_0000) != 0) ? 1 : 0
    fraction = fraction - (a_frc << 1)
    mulcarry -= (fraction > old_fraction)
    mulcarry -= ((a_frc & 0x8000_0000_0000_0000) != 0)
  else
    fraction = fraction + a_frc
    mulcarry += (fraction < old_fraction)
  end

  old_fraction = fraction

  #then, add the b_frc value
  if a_sgn
    deltacarry = ((b_frc & 0x8000_0000_0000_0000) != 0) ? 1 : 0
    fraction = fraction - (b_frc << 1)
    mulcarry -= (fraction > old_fraction)
    mulcarry -= ((b_frc & 0x8000_0000_0000_0000) != 0)
  else
    fraction = fraction + b_frc
    mulcarry += (fraction < old_fraction)
  end

  #exponents in multiplication are additive.
  exponent = a_exp + b_exp
  #finally, look at the carry and shift the product fraction accordingly.

  sign = a_sgn $ b_sgn

  (fraction, exponent) =
  if     (mulcarry == -4)
    (fraction >> 1, exponent + 1)
  elseif (mulcarry == -3)
    (fraction >> 1 | 0x8000_0000_0000_0000, exponent + 1)
  elseif (mulcarry == -2)
    (fraction, exponent)
  elseif (mulcarry == -1)
    (fraction << 1, exponent - 1)
  elseif (mulcarry == 0)
    (fraction << 1, exponent - 1)

  #one, two and three can be accessible both from the product of two positives and
  #the product of two negatives.
  elseif (mulcarry == 1)
    (fraction, exponent - (2 * a_sgn))
  elseif (mulcarry == 2)
    (fraction >> 1, exponent + (a_sgn ? -1 : 1))
  elseif (mulcarry == 3)
    ((fraction >> 1) | 0x8000_0000_0000_0000 , exponent + (a_sgn ? -1 : 1))

  #four can only be attained by two negatives.
  elseif (mulcarry == 4)
    (fraction >> 2, exponent)
  end

  #set up a quire iterator.
  qi = __p2quire_iter(sign, exponent, fraction, false)

  carry = false
  for (idx, cell) in zip(1:64, qi)
    old = acc.fixed_point_value[idx]
    acc.fixed_point_value[idx] += cell + carry
    carry = (acc.fixed_point_value[idx] <= old) & ((cell != zero(UInt64)) | (carry))
  end

  Posit{N,ES}(acc)
end


################################################################################
## some utility functions.

function find_lsb(q::Quire)
  digits_so_far = -2048
  for idx in 1:64
    lbits = trailing_zeros(q.fixed_point_value[idx])
    digits_so_far += lbits
    (lbits != 64) && break
  end
  digits_so_far
end

function fdp{N,ES}(v1::Vector{Posit{N,ES}}, v2::Vector{Posit{N,ES}}, q = Quire(Posit{N,ES}))
  zero!(q)
  res = zero(Posit{N,ES})
  for (x,y) in zip(v1, v2)
    res = fdp!(q, x, y)
  end
  res
end

function exact_sum{N,ES}(v1::Vector{Posit{N,ES}}, q = Quire(Posit{N,ES}))
  res = zero(Posit{N,ES})
  for x in v1
    res = add!(q, x)
  end
  res
end

function exact_mmult{N,ES}(M::Matrix{Posit{N,ES}}, v::Vector{Posit{N,ES}}, q = Quire(Posit{N,ES}))
  [fdp(M[idx, :], v, q) for idx in 1:size(M,1)]
end

function exact_mmult{N,ES}(M1::Matrix{Posit{N,ES}}, M2::Matrix{Posit{N,ES}}, q = Quire(Posit{N,ES}))
  [fdp(M1[idx, :], M2[:, jdx], q) for idx in 1:size(M1,1), jdx in 1:size(M2,2)]
end

export Quire, set!, add!, fdp!, fdp, exact_sum, exact_mmult
