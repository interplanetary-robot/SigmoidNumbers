macro UInt()
  Symbol("UInt", __BITS)
end

macro Int()
  Symbol("Int", __BITS)
end

macro u(value)
  :(reinterpret(@UInt,$value))
end

macro s(value)
  :(reinterpret(@Int,$value))
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
  `SigmoidNumbers.@breakdown(s::Symbol, [:arithmetic | :numeric])`

  takes a sigmoid number referenced by a symbol and creates in the containing
  scope the following symbols:

  s_s::@Int         -signed int value
  u_s::@UInt        -unsigned, int of the absolute value.
  s_sgn::Bool       -true if negative, false if positive.
  s_exp::Int        -signed integer representation of the exponent.
  s_inv::Bool       -true if s_exp is negative, false if positive
  s_frc::@UInt      -left-shifted fraction value, in a UInt whose size matches
                     library resolution.

  in the "arithmetic" case, the exponent is set to -1 in the case of [0..1], and the
  fraction is flushed left to have the "leading one" present, aka the "hidden bit"
  in the representation by default.  Default case is numerical.

  This does not handle the zero or infinity cases, which should be dealt with separately.
"""
macro breakdown(x...)
  goodsymbols = [:arithmetic, :numeric]

  #argument list handling.
  if length(x) == 0
    throw(ArgumentError("@breakdown macro requires an argument"))
  elseif length(x) == 1
    numeric = true
  elseif length(x) == 2
    (x[2] in goodsymbols) || throw(ArgumentError("option $(x[2]) unknown to @breakdown macro"))
    numeric = (x[2] == :numeric)
  else
    throw(ArgumentError("too many arguments to @breakdown macro"))
  end
  x = x[1] #reassign the x value to the first symbol.

  #throw an error if we don't have a simple symbol for the @breakdown macro.
  (typeof(x) == Symbol) || throw(ArgumentError("@breakdown macro can only operate on symbols."))

  #a small chart of the things we'll generate.
  s_x   = Symbol("s_", x)
  u_x   = Symbol("u_", x)
  x_sgn = Symbol(x, "_sgn")
  x_inv = Symbol(x, "_inv")
  x_exp = Symbol(x, "_exp")
  x_frc = Symbol(x, "_frc")

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
      $x_exp::Int = ($x_inv ? leading_zeros($u_x & (~@signbit)) : (leading_ones($u_x | @signbit) - 1)) - 1

      #flush the fraction all the way to the left.  This also means we don't have to
      #do any masking operations for higher order bits.
      $x_frc = $u_x << ($x_exp + ($x_inv ? 2 : 3))
    end)
  else
    esc(quote
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

function __numeric_breakdown_wrapper(x)
  @breakdown x numeric
  (x_sgn, x_inv, x_exp, x_frc)
end

function __arithmetic_breakdown_wrapper(x)
  @breakdown x arithmetic
  (x_sgn, x_inv, x_exp, x_frc)
end
