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
  oneminus(::Posits)

  calculates the value of 1-y.

  This function is undefined for values > 1 or less than 0.
"""
oneminus(y::Posits) = oneminus_careful(y)
oneminus_sloppy(y) = reinterpret(Posits{N}, (@invertbit) - @u(y))
function oneminus_careful(y)
  @unitrange_check(y, :oneminus)
  oneminus_sloppy(y)
end

doc"""
  pseudologistic(::Posits)

  calculates the pseudo-logistic sigmoid curve for the Posits data type.
"""
pseudologistic{N}(x::Posits{N}) = pseudologistic_careful(x)
pseudologistic_sloppy{N}(x::Posits{N}) = reinterpret(Posits{N}, (@u(x) $ @signbit) >> 2)
@generated function pseudologistic_careful{N}(x::Posits{N})
  mask = @mask(N)
  quote
    isfinite(x) || throw(ArgumentError("pseudologistic function is undefined for infinity"))
    reinterpret(Posits{N}, (@u(pseudologistic_sloppy(x)) & $mask))
  end
end

doc"""
  delta_psl(::Posits)

  calculates the value dy/dx using the differential equation dy/dx = y(1 - y)

  This function is undefined for values > 1 or less than zero.
"""
delta_psl{N}(y::Posits{N}) = delta_psl_careful(y)
delta_psl_sloppy(y) = y * oneminus_sloppy(y)
function delta_psl_careful{N}(y::Posits{N})
  @unitrange_check(y, :delta_psl)
end

doc"""
  pseudohalfcost(::Posits)

  calculates the pseudohalfcost function for the Posits data type.  The
  halfcost function is -log_x(1-y), here we estimate by simple expansion.

  This function is undefined for values > 1 or less than zero.
"""
pseudohalfcost{N}(y::Posits{N}) = pseudohalfcost_careful(y)
pseudohalfcost_sloppy{N}(y::Posits{N}) = reinterpret(Posits{N}, @u(y) << 1)
function pseudohalfcost_careful{N}(y::Posits{N})
  @unitrange_check(y, :pseudohalfcost)
  pseudohalfcost_sloppy(y)
end

doc"""
  pseudosoftplus(::Posits)

  calculates the pseudosoftplus function for the Posits data type.  The
  pseudosoftplus emulates ln(1 + e^x).

"""
pseudosoftplus{N}(x::Posits{N}) = pseudosoftplus_careful(x)
pseudosoftplus_sloppy{N}(x::Posits{N}) = reinterpret(Posits{N}, (@u(x) $ @signbit) >> 1)
@generated function pseudosoftplus_careful{N}(x::Posits{N})
  mask = @mask(N)
  quote
    reinterpret(Posits{N}, @u(pseudosoftplus_sloppy(x)) & $mask)
  end
end
