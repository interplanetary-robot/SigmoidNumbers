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
  oneminus(::MLSigmoid)

  calculates the value of 1-y.

  This function is undefined for values > 1 or less than 0.
"""
oneminus(y::MLSigmoid) = oneminus_careful(y)
oneminus_sloppy(y) = reinterpret(MLSigmoid{N}, (@invertbit) - @u(y))
function oneminus_careful(y)
  @unitrange_check(y, :oneminus)
  oneminus_sloppy(y)
end

doc"""
  pseudologistic(::MLSigmoid)

  calculates the pseudo-logistic sigmoid curve for the MLSigmoid data type.
"""
pseudologistic{N}(x::MLSigmoid{N}) = pseudologistic_careful(x)
pseudologistic_sloppy{N}(x::MLSigmoid{N}) = reinterpret(MLSigmoid{N}, (@u(x) $ @signbit) >> 2)
@generated function pseudologistic_careful{N}(x::MLSigmoid{N})
  mask = @mask(N)
  quote
    isfinite(x) || throw(ArgumentError("pseudologistic function is undefined for infinity"))
    reinterpret(MLSigmoid{N}, (@u(pseudologistic_sloppy(x)) & $mask))
  end
end

doc"""
  delta_psl(::MLSigmoid)

  calculates the value dy/dx using the differential equation dy/dx = y(1 - y)

  This function is undefined for values > 1 or less than zero.
"""
delta_psl{N}(y::MLSigmoid{N}) = delta_psl_careful(y)
delta_psl_sloppy(y) = y * oneminus_sloppy(y)
function delta_psl_careful{N}(y::MLSigmoid{N})
  @unitrange_check(y, :delta_psl)
end

doc"""
  pseudohalfcost(::MLSigmoid)

  calculates the pseudohalfcost function for the MLSigmoid data type.  The
  halfcost function is -log_x(1-y), here we estimate by simple expansion.

  This function is undefined for values > 1 or less than zero.
"""
pseudohalfcost{N}(y::MLSigmoid{N}) = pseudohalfcost_careful(y)
pseudohalfcost_sloppy{N}(y::MLSigmoid{N}) = reinterpret(MLSigmoid{N}, @u(y) << 1)
function pseudohalfcost_careful{N}(y::MLSigmoid{N})
  @unitrange_check(y, :pseudohalfcost)
  pseudohalfcost_sloppy(y)
end

doc"""
  pseudosoftplus(::MLSigmoid)

  calculates the pseudosoftplus function for the MLSigmoid data type.  The
  pseudosoftplus emulates ln(1 + e^x).

"""
pseudosoftplus{N}(x::MLSigmoid{N}) = pseudosoftmax_careful(x)
pseudosoftplus_sloppy{N}(x::MLSigmoid{N}) = reinterpret(MLSigmoid{N}, (@u(x) $ @signbit) >> 1)
function pseudosoftplus_careful{N}(x::MLSigmoid{N})
  mask = @mask(N)
  quote
    reinterpret(MLSigmoid{N}, pseudosoftplus_sloppy(x) & $mask)
  end
end
