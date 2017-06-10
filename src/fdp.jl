
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
  train1_pos::Int64
  train1_len::Int64
  #keep track of 128 bits behind the train.
  int1_bits_h::UInt64
  int1_bits_l::UInt64

  #the next generation of quire store will implement the following extra data,
  #which will enable calculations to be cached without resorting to the
  #fixed point matrix....  For now, they will not be used.

  #keep track of the next run of ones behind the train.
  train2_len::Int64
  #next keep track of the 128 bits beyond the second train.
  int2_bits_h::UInt64
  int2_bits_l::UInt64
end

#a few properties:
maxpos(::Type{Quire}) = 2047
minpos(::Type{Quire}) = -2048
Base.isinf(q::Quire) = (q.train1_pos > maxpos(Quire))
iszero(q::Quire) = (q.train1_pos < minpos(Quire))

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
  Quire(zeros(UInt64, 64), -2049, 0, 0, 0, 0, 0, 0);
end

#zeroes out the fused dot product accumulator.  Just throw out the old array.
function zero!(q::Quire)
  for idx = 1:48
    q.fixed_point_value[idx] = zero(UInt64)
  end

  q.train1_pos = -2049
  q.train1_len = 0
  q.int1_bits_h = zero(UInt64)
  q.int1_bits_l = zero(UInt64)
  q.train2_len = 0
  q.int2_bits_h = zero(UInt64)
  q.int2_bits_l = zero(UInt64)
  q
end

doc"""
  inf!(q::Quire) forces the quire to carry an infinite value.
"""
inf!(q::Quire) = (q.train1_pos = maxpos(Quire) + 1; q)

isnegative(q::Quire) = (q.train1_pos >= 2047)

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
  isinf(q) && return Posit{N,ES}(Inf)
  iszero(q) && return zero(Posit{N,ES})

  #check if the front one is at the top, in which case it's negative
  if isnegative(q)
    exponent = 2047 - q.train1_len

    exponent > maximum_exponent(Posit{N,ES}) && return -realmax(Posit{N,ES})
    exponent < minimum_exponent(Posit{N,ES}) && return neg_smallest(Posit{N,ES})

    #=
      FUTURE:
      #append a summary bit on the last position, if there are ones further below.

      hasbitsbelow(q, <some number>) && fraction |= one(UInt64)
    =#

    Posit{N,ES}(true, exponent, q.int1_bits_h)
  else
    exponent = q.train1_pos

    exponent > maximum_exponent(Posit{N,ES}) && return realmax(Posit{N,ES})
    exponent < minimum_exponent(Posit{N,ES}) && return pos_smallest(Posit{N,ES})

    #note.  int1_bits for positive values should ALWAYS start with zero
    fraction_prefix = -(0x8000_0000_0000_0000 >> (q.train1_len - 2))
    #then, take the actual fraction and shift it.
    fraction = (q.int1_bits_h >> (q.train1_len - 1)) | fraction_prefix

    #=
      FUTURE:
      #append a summary bit on the last position, if there are ones further below.

      hasbitsbelow(q, <some number>) && fraction |= one(UInt64)
    =#

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
  zero!(acc)  #zero the quire.

  ##############################################################################
  ## part one:  update the quire cache

  if sign     #if it's negative
    acc.train1_pos = 2047
    acc.train1_len = 2047 - exponent
    acc.int1_bits_h = frac_top
  else        #if it's positive, things get trickier.
    acc.train1_pos = exponent
    __leading_ones = leading_ones(frac_top)
    acc.train1_len = __leading_ones + 1
    acc.int1_bits_h = frac_top << __leading_ones  #note that this leaves a zero at the front.
  end

  ##############################################################################
  ## part two:  update the quire scratchpad.

  #first, decide how to break up the fraction into the relevant cells.  Note
  #that the arrangement here is going to index the MSB cell as 32 and the LSB
  #cell as 1.

  # a few examples:
  # exponent 0:
  # value: 1.xxxx...xxxx
  # top_cell_index = 16
  # shift: 0

  # exponent 1:
  # value: 1x.xxxx....xxx0
  # top_cell_index = 17
  # shift: >> 63

  # exponent -1:
  # value: 0.0xxx...xxxx|x
  # top_cell_index = 16
  # shift: >> 1

  #calculate the shifts and the indices.
  println("pos: ", acc.train1_pos)
  println("len: ", acc.train1_len)

  record_position = acc.train1_pos - acc.train1_len
  index = (record_position - 1) >> 6 + 33
  shift = (record_position + 1) & 63

  println("frac_top: ", hex(frac_top,16))
  println("shift: $shift")
  println("index: $index")

  top_cell_content = frac_top >> (64 - shift)
  bot_cell_content = frac_top << shift

  #actually update the accumulator.  Note we don't have to check index because
  # we can't pass it the lowest value, not for any of the things we're multiplying.
  acc.fixed_point_value[index - 1] = bot_cell_content
  acc.fixed_point_value[index] = top_cell_content

  #return the quire.
  acc
end

function set!{N,ES}(acc::Quire, x::Posit{N,ES})
  isinf(x) && (inf!(acc); return acc)
  set!(acc, posit_components(x)...)
end
#=
function add!(acc::Quire, sign::Bool, exponent::Int64, frac_top::UInt64, frac_bot::UInt64 = 0x0000_0000_0000_0000)
  if sign
    if is_negative(acc)
    else
  else  #when adding positive numbers, everything is easy.
    if exponent > ()
  end
end

add!{N,ES}(acc::Quire, x::Posit{N,ES}) = add!(acc, posit_components(x)...)
=#
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
