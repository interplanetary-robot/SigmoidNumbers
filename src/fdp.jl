
doc"""
  SigmoidNumbers::Quire

  represents the 'quire' data structure.  This is a scratchpad of unsigned
  integers which represents a mutable fixed point value, useful as an
  accumulator for fused floating point operations.  There is additional data
  that allows you to do a 'shortcut' calculation; this exists to simulate
  hardware implementations that can achieve pipelined/single clock cycle
"""
type Quire
  fixed_point_value::Vector{UInt64}
  #some values for shortcut evaluation.
  #the one_train values keep track of the leading "train" of ones.  These values
  #are not necessarily written in the quire data store.
  one_train_pos::Int64
  one_train_len::Int64
  #keep track of 128 bits behind the train.
  tail_bits_h::UInt64
  tail_bits_l::UInt64
end

#a few properties:
maxpos(::Type{Quire}) = 2047
minpos(::Type{Quire}) = -2048
Base.isinf(q::Quire) = (q.one_train_pos > maxpos(Quire))
iszero(q::Quire) = (q.one_train_pos < minpos(Quire))

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
  Quire(zeros(UInt64, 64), -2049, 0, 0, 0);
end

#zeroes out the fused dot product accumulator.  Just throw out the old array.
function zero!(q::Quire)
  for idx = 1:48
    q.fixed_point_value[idx] = zero(UInt64)
  end

  q.one_train_pos = -2049
  q.one_train_len = 0
  q.tail_bits_h = zero(UInt64)
  q.tail_bits_l = zero(UInt64)
  q
end

doc"""
  inf!(q::Quire) forces the quire to carry an infinite value.
"""
inf!(q::Quire) = (q.one_train_pos = maxpos(Quire) + 1; q)

isnegative(q::Quire) = (q.one_train_pos == 2047)

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


function (::Type{Posit{N,ES}}){N,ES}(q::Quire)
  #exceptional value handling:
  isinf(q) && return inf(Posit{N,ES})
  iszero(q) && return zero(Posit{N,ES})

  println("=================")
  println("q:", q)

  #check if the front one is at the top, in which case it's negative
  if isnegative(q)
    exponent = maximum_exponent(Posit{N,ES}) - q.one_train_len
    exponent > maximum_exponent(Posit{N,ES}) && return -realmax(Posit{N,ES})
    exponent < minimum_exponent(Posit{N,ES}) && return neg_smallest(Posit{N,ES})

    #=
      FUTURE:
      #append a summary bit on the last position, if there are ones further below.

      hasbitsbelow(q, <some number>) && fraction |= one(UInt64)
    =#


    println("hey:", (true, exponent, f.tail_bits_h))

    Posit{N,ES}(true, exponent, f.tail_bits_h)
  else
    exponent = q.one_train_pos

    exponent > maximum_exponent(Posit{N,ES}) && return realmax(Posit{N,ES})
    exponent < minimum_exponent(Posit{N,ES}) && return pos_smallest(Posit{N,ES})

    #note.  fraction values for positive values should ALWAYS start with zero.
    fraction = q.tail_bits_h | 0x8000_0000_0000_0000
    println("f0: ", hex(fraction, 16))
    println("shft: ", q.one_train_len - 2)
    fraction = @u(@s(fraction) >> (q.one_train_len - 2))
    println("f1: ", hex(fraction, 16))
    fraction = fraction >> 1

    #=
      FUTURE:
      #append a summary bit on the last position, if there are ones further below.

      hasbitsbelow(q, <some number>) && fraction |= one(UInt64)
    =#

    println("hey:", (false, exponent, fraction))

    Posit{N,ES}(false, exponent, fraction)
  end
end

doc"""
  posit_components breaks up a posit into components (sign, exp, frac)
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

function set!(acc::Quire, sign::Bool, exponent::Int64, frac_top::UInt64)
  println("=================")
  println((sign, exponent, frac_top))
  zero!(acc)  #zero the quire.
  if sign     #if it's negative
    acc.one_train_pos = 2047
    acc.one_train_len = 2047 - exponent
    acc.tail_bits_h = frac_top
  else        #if it's positive, things get trickier.
    acc.one_train_pos = exponent
    __leading_ones = leading_ones(frac_top)
    acc.one_train_len = __leading_ones + 1
    acc.tail_bits_h = frac_top << __leading_ones  #note that this leaves a zero at the front.
  end
  #return the quire.
  acc
end

set!{N,ES}(acc::Quire, x::Posit{N,ES}) = set!(acc, posit_components(x)...)

function add!(acc::Quire, sign::Bool, exponent::Int64, frac_top::UInt64, frac_bot::UInt64 = 0x0000_0000_0000_0000)
  set!(acc, sign, exponent, frac_top)  #for now.
end

add!{N,ES}(acc::Quire, x::Posit{N,ES}) = add!(acc, posit_components(x)...)

#=
function fdp!{N,ES}(acc::Quire, a::Posit{N,ES}, b::Posit{N,ES})

  #set the convenience values.
  frc_w = widemul(frc_a, frc_b)
  frc_h = UInt64(frc_w >> 64)
  frc_l = UInt64(frc_w & 0xFFFF_FFFF_FFFF_FFFF)

  return Posit{N,ES}(acc)
end
=#

export Quire, set!, add!
