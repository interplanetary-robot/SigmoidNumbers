import Base: *

*{N, ES, mode}(lhs::Bool, rhs::Sigmoid{N, ES, mode}) = reinterpret(Sigmoid{N, ES, mode}, @s(rhs) * lhs)
*{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Bool) = reinterpret(Sigmoid{N, ES, mode}, @s(lhs) * rhs)

#introduce a "cross" mode which requires a reconversion in order to proceed.
const multiplication_types = Dict((:guess, :guess) => :guess,
                                  (:exact, :exact) => :exact,
                                  (:exact, :lower) => :lower,
                                  (:exact, :upper) => :upper,
                                  (:lower, :exact) => :lower,
                                  (:upper, :exact) => :upper,
                                  (:lower, :lower) => :lower,
                                  (:upper, :upper) => :upper,
                                  (:lower, :upper) => :cross,
                                  (:upper, :lower) => :cross,
                                  (:inward_exact,  :inward_exact)  => :inward_exact,
                                  (:inward_ulp,    :inward_exact)  => :inward_ulp,
                                  (:inward_exact,  :inward_ulp)    => :inward_ulp,
                                  (:inward_ulp,    :inward_ulp)    => :inward_ulp,
                                  (:outward_exact, :outward_exact) => :outward_exact,
                                  (:outward_ulp,   :outward_exact) => :outward_ulp,
                                  (:outward_exact, :outward_ulp)   => :outward_ulp,
                                  (:outward_ulp,   :outward_ulp)   => :outward_ulp)

const nanerror_code = :(throw(NaNError(*, Any[lhs, rhs])))
const exactinf_code = :(Sigmoid{N,ES,:exact}(Inf))
const modezero_code = :(zero(Stype))
const exactzero_code = :(zero(Sigmoid{N,ES,:exact}))
const guessinf_code = :(Sigmoid{N,ES,:guess}(Inf))
const modeinf_code = :(Stype(Inf))
const temporary_problem = :(throw(ErrorException("this scenario is uncertain and needs to be resolved: $lhs * $rhs")))


const multiplication_inf_zero = Dict((:guess, :guess) => nanerror_code,
                                     (:exact, :exact) => nanerror_code,
                                     (:exact, :lower) => exactinf_code,
                                     (:exact, :upper) => exactinf_code,
                                     (:lower, :exact) => exactzero_code,
                                     (:upper, :exact) => exactzero_code,
                                     (:lower, :lower) => :(Sigmoid{N,ES,:lower}(Inf)),
                                     (:upper, :upper) => :(zero(Sigmoid{N,ES,:upper})),
                                     (:upper, :lower) => temporary_problem,
                                     (:lower, :upper) => temporary_problem,
                                     (:inward_exact,  :inward_exact)  => nanerror_code,
                                     (:inward_ulp,    :inward_exact)  => :(zero(Sigmoid{N,ES,:inward_exact})),
                                     (:inward_exact,  :inward_ulp)    => :(Sigmoid{N,ES,:inward_exact}(Inf)),
                                     (:inward_ulp,    :inward_ulp)    => :(zero(Sigmoid{N,ES,:inward_ulp})),
                                     (:outward_exact, :outward_exact) => nanerror_code,
                                     (:outward_ulp,   :outward_exact) => :(zero(Sigmoid{N,ES,:outward_exact})),
                                     (:outward_exact, :outward_ulp)   => :(Sigmoid{N,ES,:outward_exact}(Inf)),
                                     (:outward_ulp,   :outward_ulp)   => :(Sigmoid{N,ES,:outward_ulp}(Inf)))

const multiplication_left_inf = Dict((:guess, :guess) => guessinf_code,
                                     (:exact, :exact) => exactinf_code,
                                     (:exact, :lower) => exactinf_code,
                                     (:exact, :upper) => exactinf_code,
                                     (:lower, :exact) => modeinf_code,
                                     (:upper, :exact) => modeinf_code,
                                     (:lower, :lower) => modeinf_code,
                                     (:upper, :upper) => modeinf_code,
                                     (:upper, :lower) => :(Sigmoid{N,ES,:lower}(Inf)),
                                     (:lower, :upper) => :(Sigmoid{N,ES,:lower}(Inf)),
                                     (:inward_exact,  :inward_exact)  => :(Sigmoid{N,ES,:inward_exact}(Inf)),
                                     (:inward_ulp,    :inward_exact)  => :(Sigmoid{N,ES,:inward_ulp}(Inf)),
                                     (:inward_exact,  :inward_ulp)    => :(Sigmoid{N,ES,:inward_exact}(Inf)),
                                     (:inward_ulp,    :inward_ulp)    => :(Sigmoid{N,ES,:inward_ulp}(Inf)),
                                     (:outward_exact, :outward_exact) => :(Sigmoid{N,ES,:outward_exact}(Inf)),
                                     (:outward_ulp,   :outward_exact) => :(Sigmoid{N,ES,:outward_ulp}(Inf)),
                                     (:outward_exact, :outward_ulp)   => :(Sigmoid{N,ES,:outward_exact}(Inf)),
                                     (:outward_ulp,   :outward_ulp)   => :(Sigmoid{N,ES,:outward_ulp}(Inf)))

const multiplication_left_zero = Dict((:guess, :guess) => modezero_code,
                                      (:exact, :exact) => exactzero_code,
                                      (:exact, :lower) => exactzero_code,
                                      (:exact, :upper) => exactzero_code,
                                      (:lower, :exact) => modezero_code,
                                      (:upper, :exact) => modezero_code,
                                      (:lower, :lower) => modezero_code,
                                      (:upper, :upper) => modezero_code,
                                      (:upper, :lower) => :(zero(Sigmoid{N,ES,:upper})),
                                      (:lower, :upper) => :(zero(Sigmoid{N,ES,:upper})),
                                      (:inward_exact,  :inward_exact)  => :(zero(Sigmoid{N,ES,:inward_exact})),
                                      (:inward_ulp,    :inward_exact)  => :(zero(Sigmoid{N,ES,:inward_ulp})),
                                      (:inward_exact,  :inward_ulp)    => :(zero(Sigmoid{N,ES,:inward_exact})),
                                      (:inward_ulp,    :inward_ulp)    => :(zero(Sigmoid{N,ES,:inward_ulp})),
                                      (:outward_exact, :outward_exact) => :(zero(Sigmoid{N,ES,:outward_exact})),
                                      (:outward_ulp,   :outward_exact) => :(zero(Sigmoid{N,ES,:outward_ulp})),
                                      (:outward_exact, :outward_ulp)   => :(zero(Sigmoid{N,ES,:outward_exact})),
                                      (:outward_ulp,   :outward_ulp)   => :(zero(Sigmoid{N,ES,:outward_ulp})))

@generated function *{N, ES, lhs_mode, rhs_mode}(lhs::Sigmoid{N, ES, lhs_mode}, rhs::Sigmoid{N, ES, rhs_mode})

    #dealing with modes for multiplication
    haskey(multiplication_types, (lhs_mode, rhs_mode)) || return :(zero(Sigmoid{N,ES, lhs_mode}))
    #throw(ArgumentError("incompatible types passed to multiplication function! ($lhs_mode, $rhs_mode)"))
    mode = multiplication_types[(lhs_mode, rhs_mode)]
    infzero_code = multiplication_inf_zero[(lhs_mode,rhs_mode)]
    zeroinf_code = multiplication_inf_zero[(rhs_mode,lhs_mode)]
    leftinf_code = multiplication_left_inf[(lhs_mode,rhs_mode)]
    rightinf_code = multiplication_left_inf[(rhs_mode,lhs_mode)]
    leftzero_code = multiplication_left_zero[(lhs_mode,rhs_mode)]
    rightzero_code = multiplication_left_zero[(rhs_mode,lhs_mode)]

    S = Sigmoid{N,ES,mode}

    quote
        Stype = $S
        #multiplying infinities is infinite.
        if !isfinite(lhs)
            (reinterpret((@UInt), rhs) == zero(@UInt)) && return $infzero_code
            return $leftinf_code
        end
        if !isfinite(rhs)
            (reinterpret((@UInt), lhs) == zero(@UInt)) && return $zeroinf_code
            return $rightinf_code
        end
        #mulitplying zeros is zero
        (reinterpret((@UInt), lhs) == zero(@UInt)) && return $leftzero_code
        (reinterpret((@UInt), rhs) == zero(@UInt)) && return $rightzero_code
        return mul_algorithm(lhs, rhs)
    end
end


@generated function mul_algorithm{N, ES, lhs_mode, rhs_mode}(lhs::Sigmoid{N, ES, lhs_mode}, rhs::Sigmoid{N, ES, rhs_mode})

    #dealing with modes for multiplication
    haskey(multiplication_types, (lhs_mode, rhs_mode)) || throw(ArgumentError("incompatible types passed to multiplication function!"))
    mode = multiplication_types[(lhs_mode, rhs_mode)]

    S = Sigmoid{N,ES,mode}
    quotemode = QuoteNode(mode)

    quote
        #generate the lhs and rhs subcomponents.
        mode = $quotemode
        @breakdown lhs
        @breakdown rhs
        #sign is the xor of both signs.
        mul_sgn = lhs_sgn ⊻ rhs_sgn
        #the multiplicative exponent is the sum of the two exponents.
        mul_exp = lhs_exp + rhs_exp
        lhs_frc = (lhs_frc >> 1) | (@signbit)
        rhs_frc = (rhs_frc >> 1) | (@signbit)
        #then calculate the fraction.
        mul_frc = demote(promote(lhs_frc) * promote(rhs_frc))
        shift = leading_zeros(mul_frc)
        mul_frc <<= shift + 1
        mul_exp -= (shift - 1)
        __round(build_numeric($S, mul_sgn, mul_exp, mul_frc))
    end
end
#
#  Multiplication with ES 0 can use arithmetic mode.
#
#=
function mul_algorithm{N, mode}(lhs::Sigmoid{N, 0, mode}, rhs::Sigmoid{N, 0, mode})
  ES = 0
  #generate the lhs and rhs subcomponents.
  @breakdown lhs arithmetic
  @breakdown rhs arithmetic

  #sign is the xor of both signs.
  mul_sgn = lhs_sgn ⊻ rhs_sgn

  #the multiplicative exponent is the product of the two exponents.
  mul_exp = lhs_exp + rhs_exp

  #then calculate the fraction.
  mul_frc = demote(promote(lhs_frc) * promote(rhs_frc))

  shift = min(leading_zeros(mul_frc) - 1, mul_exp)
  mul_frc <<= shift + 1
  mul_exp -= shift

  __round(build_arithmetic(Sigmoid{N, 0, mode}, mul_sgn, mul_exp, mul_frc))
end
=#

@generated function Base.:/{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode})
  #calculate the number of rounds we should apply the goldschmidt method.
  rounds = Int(ceil(log(2,N))) + 1
  top_bit = promote(one(@UInt) << (__BITS - 1))
  bot_bit = (one(@UInt) << (__BITS - N - 1))

  quote
    #dividing infinities or by zero is infinite.
    if !isfinite(lhs)
      isfinite(rhs) || throw(NaNError(/,[lhs, rhs]))
      return reinterpret(Sigmoid{N, ES, mode}, @signbit)
    end
    if rhs == zero(Sigmoid{N, ES, mode})
      (lhs == zero(Sigmoid{N, ES, mode})) && throw(NaNError(/, [lhs, rhs]))
      return reinterpret(Sigmoid{N, ES, mode}, @signbit)
    end

    #dividing zeros or by infinity is zero
    isfinite(rhs) || return zero(Sigmoid{N, ES, mode})
    lhs == zero(Sigmoid{N, ES, mode}) && return zero(Sigmoid{N, ES, mode})

    const cq_mask = promote(-one(@UInt))

    #generate the lhs and rhs subcomponents.  Unlike multiplication, however,
    #we want there to 'always be a hidden bit', so we should use the "numeric" method.
    @breakdown lhs numeric
    @breakdown rhs numeric

    #println("lhs_exp: $lhs_exp lhs_frc: ", bits(lhs_frc)[1:N])
    #println("rhs_exp: $rhs_exp rhs_frc: ", bits(rhs_frc)[1:N])

    #sign is the xor of both signs.
    div_sgn = lhs_sgn ⊻ rhs_sgn

    #do something different if rhs_frc is zero (aka power of two)
    if rhs_frc == 0
      div_exp = lhs_exp - rhs_exp
      return __round(build_numeric(Sigmoid{N, ES, mode}, div_sgn, div_exp, lhs_frc))
    end

    #the multiplicative exponent is the product of the two exponents.
    div_exp = lhs_exp - rhs_exp - 1

    #calculate the number of zeros in the solution.
    lhs_zeros = trailing_zeros(lhs_frc) - (__BITS - N)
    rhs_zeros = trailing_zeros(rhs_frc) - (__BITS - N)

    cumulative_quotient = promote(lhs_frc)
    cumulative_zpower   = promote(-rhs_frc) >> 1
    power_gain = 0

    #then calculate the fraction, using binomial goldschmidt.
    # binomial goldschmidt algorithm:  x ∈ [1, 2), y ∈ [0.5, 1)
    #   define z ≡ 1 - y ⇒ y == 1 - z.
    #   Note (1 - z)(1 + z)(1 + z^2)(1 + z^4) == (1 - z^2n) → 1
    for rd = 1:($rounds - 1)
      #update the quotient
      cumulative_quotient += ((cumulative_quotient * cumulative_zpower) >> __BITS) + cumulative_zpower
      cumulative_zpower = (cumulative_zpower ^ 2) >> __BITS
      shift = __BITS - leading_zeros(cumulative_quotient)
      if (shift > 0)
        cumulative_quotient &= cq_mask
        cumulative_quotient >>= 1
        power_gain += 1
        (shift == 2) && (cumulative_quotient |= $top_bit)
      end
    end
    #update the cumulative quotient one last time.
    cumulative_quotient += ((cumulative_quotient * cumulative_zpower) >> __BITS) + cumulative_zpower
    shift = __BITS - leading_zeros(cumulative_quotient)
    if (shift > 0)
      cumulative_quotient &= cq_mask
      cumulative_quotient >>= 1
      power_gain += 1
      (shift == 2) && (cumulative_quotient |= $top_bit)
    end

    div_frc = demoteright(cumulative_quotient)


    result_ones = trailing_ones(div_frc >> (__BITS - N))

    #println("trailing ones analysis")
    #println("chk:", bits(div_frc)[1:N], " res_ones:  ", result_ones)
    #println("rhs:", bits(rhs_frc)[1:N], " rhs_zeros: ", rhs_zeros)
    #println("lhs:", bits(lhs_frc)[1:N], " lhs_zeros: ", lhs_zeros)
    #println("pow:", power_gain)

    #println("res_zeros:", result_ones + rhs_zeros)
    #println("lhs_zeros:", lhs_zeros + N)

    if (lhs_zeros + N + (result_ones != N) == result_ones + rhs_zeros)
      #increment the lowest bit
      div_frc += $bot_bit
      #mask out all the other ones that were trailing.
      div_frc &= -$bot_bit

      #bump it if we triggered a carry.
      power_gain += (div_frc == 0)
    end

    #println("div_exp: $(div_exp + power_gain) div_frc: ", bits(div_frc))

    __round(build_numeric(Sigmoid{N, ES, mode}, div_sgn, div_exp + power_gain, div_frc))
  end
end

Base.inv{N,ES,mode}(x::Sigmoid{N,ES,mode}) = one(Sigmoid{N,ES,mode}) / x
Base.inv{N,ES}(x::Sigmoid{N,ES,:lower}) = one(Sigmoid{N,ES,:upper}) / reinterpret(Sigmoid{N,ES,:upper}, x)
Base.inv{N,ES}(x::Sigmoid{N,ES,:upper}) = one(Sigmoid{N,ES,:lower}) / reinterpret(Sigmoid{N,ES,:lower}, x)
