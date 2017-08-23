macro UInt()
  Symbol("UInt", __BITS)
end

macro Int()
  Symbol("Int", __BITS)
end

macro u(value)
  esc(:(reinterpret(@UInt,$value)))
end

macro s(value)
  esc(:(reinterpret(@Int,$value)))
end

macro signbit()
  one(@UInt) << (__BITS - 1)
end

macro invertbit()
  one(@UInt) << (__BITS - 2)
end

macro mask(N)
  :(((one(@UInt) << N) - one(@UInt)) << ((sizeof(@UInt) * 8) - N))
end

doc"""
  `SigmoidNumbers.@breakdown(S::Symbol, [:arithmetic | :numeric])`

  takes a small sigmoid number referenced by a symbol and creates in the containing
  scope the following symbols:

  s_S::@Int         -signed int value
  u_S::@UInt        -unsigned, int of the absolute value.
  S_sgn::Bool       -true if negative, false if positive.
  S_reg::Int        -regime value for the sigmoid number.
  S_exp::Int        -signed integer representation of the exponent.
  S_inv::Bool       -true if S_exp is negative, false if positive
  S_frc::@UInt      -left-shifted fraction value, in a UInt whose size matches
                     library resolution.
  S_ubt::Bool       -true if S has a ubit.  Always false for non-ubit-type

  in the "arithmetic" mode, the exponent is set to -1 in the case of [0..1], and the
  fraction is flushed left to have the "leading one" present, aka the "hidden bit"
  in the representation by default.  Default mode is numeric.

  NB:  arithmetic mode is only useful when (ES == 0), and this macro will insert
  an error if that is not the case.

  This does not handle the zero or infinity cases, which should always be dealt with separately.
"""
macro breakdown(args...)


  goodsymbols = [:arithmetic, :numeric]

  #argument list handling.
  if length(args) == 0
    throw(ArgumentError("@breakdown macro requires an argument"))
  elseif length(args) == 1
    numeric = true
  elseif length(args) == 2
    (args[2] in goodsymbols) || throw(ArgumentError("option $(args[2]) unknown to @breakdown macro"))
    numeric = (args[2] == :numeric)
  else
    throw(ArgumentError("too many arguments to @breakdown macro"))
  end
  x = args[1] #reassign the x value to the first symbol.

  #throw an error if we don't have a simple symbol for the @breakdown macro.
  (typeof(x) == Symbol) || throw(ArgumentError("@breakdown macro can only operate on symbols."))

  #a small chart of the things we'll generate.
  s_x   = Symbol("s_", x)
  u_x   = Symbol("u_", x)
  x_sgn = Symbol(x, "_sgn")
  x_inv = Symbol(x, "_inv")
  x_reg = Symbol(x, "_reg")
  x_exp = Symbol(x, "_exp")
  x_frc = Symbol(x, "_frc")
  x_ubt = Symbol(x, "_ubt")

  precode = quote
    #generate the signed integer representation for easy sign checking.
    $s_x = @s($x)
    #evaluate the sign of the value.
    $x_sgn::Bool = ($s_x < 0)

    #convert to an unsigned integer representing the absolute value of the integer
    #representation.
    $u_x = @u($x_sgn ? -$s_x : $s_x)

    #probe the second position to decide if it's less than one or not.
    $x_inv = ($u_x & @invertbit) == 0
  end

  #codegen for the exponent and fraction code.
  if numeric
    esc(quote
      #import the common precode
      $precode

      #in the normal case, calculate the exponent by counting the UNARY portion of
      #the number.  This is leading zeros for less than one, and leading ones for
      #greater than one.  Since greater than one starts at exponent zero, subtract
      #one in that case.

      $x_reg::Int = (($x_inv) ? leading_zeros($u_x) : leading_ones($u_x | @signbit)) - 1 - !$x_inv

      if (mode == :ubit)
        ($x_reg = min($x_reg, N - 3))
        const __UB_mask = ((@signbit) >> (N - 1))
      else
        const __UB_mask = zero(@UInt)
      end

      $x_exp::Int = $x_reg * ($x_inv ? -1 : 1) * (1 << ES)

      if (ES != 0)
        const __ES_mask = (1 << ES) - 1
        #it's OK if this is negative, yo.
        __ES_shift = __BITS - ES - 3 - $x_reg + $x_inv

        $x_exp += @s(((($u_x & ~__UB_mask) >> __ES_shift) & __ES_mask))
      end
      #mask out the ubit, then flush the fraction all the way to the left.  This
      #also means we don't have to do any masking operations for higher order bits.
      $x_ubt = ($u_x & __UB_mask != 0)
      $x_frc = ($u_x & ~__UB_mask) << ($x_reg + ($x_inv ? 2 : 3) + ES)
    end)
  else
    esc(quote
      #insert a check precluding the use of arithmetic mode when ES is not zero.
      (ES != 0) && throw(AssertionError("arithmetic mode used when ES == $ES is not zero."))

      $precode
      #the arithmetic case for the exponent is similar, except we truncate at -1.
      $x_exp::Int = ($x_inv ? 0 : (leading_ones($u_x | @signbit) - 1) - 1)

      #the shift scales linerarly with the "truncated exponent".  We need to graft
      #the "hidden one" in the case that the number is >= 1, aka not "subnormal."
      $x_frc = ($u_x << ($x_exp + 2 - $x_inv)) | (!$x_inv * @signbit)
    end)
  end
end

#for test purposes

function __numeric_breakdown_wrapper{N, ES, mode}(x::Sigmoid{N, ES, mode})
  @breakdown x numeric
  (x_sgn, x_inv, x_exp, x_frc, x_ubt)
end

function __arithmetic_breakdown_wrapper{N, ES, mode}(x::Sigmoid{N, ES, mode})
  @breakdown x arithmetic
  (x_sgn, x_inv, x_exp, x_frc, x_ubt)
end
