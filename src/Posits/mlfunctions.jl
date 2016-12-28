#mlfunctions.jl - runs some special, accelerated ML functions.

macro unitrange_check(y, functionname)
  negative_error_text = "$functionname doesn't take negative values."
  toobig_error_text = "$functionname doesn't take values > 1"
  quote
    @s($y) < 0 && throw(ArgumentError($negative_error_text))
    ((@u($y) & @invertbit) != 0) && throw(ArgumentError($toobig_error_text))
  end
end

doc"""
  oneminus(::Posit)

  calculates the value of 1-y.

  This function is undefined for values > 1 or less than 0.
"""
oneminus(y::Posit) = oneminus_careful(y)
oneminus_sloppy{N}(y::Posit{N}) = reinterpret(Posit{N}, (@invertbit) - @u(y))
function oneminus_careful(y)
  @unitrange_check(y, :oneminus)
  oneminus_sloppy(y)
end

doc"""
  pseudologistic(::Posit)

  calculates the pseudo-logistic sigmoid curve for the Posit data type.
"""
pseudologistic{N}(x::Posit{N}) = pseudologistic_careful(x)
pseudologistic_sloppy{N}(x::Posit{N}) = reinterpret(Posit{N}, (@u(x) $ @signbit) >> 2)
@generated function pseudologistic_careful{N}(x::Posit{N})
  mask = @mask(N)
  quote
    isfinite(x) || throw(ArgumentError("pseudologistic function is undefined for infinity"))
    __round(reinterpret(Posit{N}, (@u(pseudologistic_sloppy(x)) & $mask)))
  end
end

doc"""
  delta_psl(::Posit)

  calculates the value dy/dx using the differential equation dy/dx = y(1 - y)

  This function is undefined for values > 1 or less than zero.
"""
delta_psl{N}(y::Posit{N}) = delta_psl_careful(y)
delta_psl_sloppy(y) = y * oneminus_sloppy(y)
function delta_psl_careful{N}(y::Posit{N})
  @unitrange_check(y, :delta_psl)
  __round(delta_psl_sloppy(y))
end

doc"""
  pseudologcost(::Posit)

  calculates the pseudologcost function for the Posit data type.  The
  halfcost function is -log_x(1-y), here we estimate by simple expansion.

  This function is undefined for values > 1 or less than zero.
"""
pseudologcost{N}(y::Posit{N}) = pseudologcost_careful(y)
pseudologcost_sloppy{N}(y::Posit{N}) = reinterpret(Posit{N}, @u(y) << 1)
function pseudologcost_careful{N}(y::Posit{N})
  @unitrange_check(y, :pseudologcost)
  __round(pseudologcost_sloppy(y))
end

doc"""
  pseudosoftplus(::Posit)

  calculates the pseudosoftplus function for the Posit data type.  The
  pseudosoftplus emulates ln(1 + e^x).

"""
pseudosoftplus{N}(x::Posit{N}) = pseudosoftplus_careful(x)
pseudosoftplus_sloppy{N}(x::Posit{N}) = reinterpret(Posit{N}, (@u(x) $ @signbit) >> 1)
@generated function pseudosoftplus_careful{N}(x::Posit{N})
  mask = @mask(N)
  quote
    __round(reinterpret(Posit{N}, @u(pseudosoftplus_sloppy(x)) & $mask))
  end
end
