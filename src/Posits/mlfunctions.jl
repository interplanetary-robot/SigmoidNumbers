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
oneminus_sloppy{P <: Posit}(y::P) = reinterpret(P, (@invertbit) - @u(y))
function oneminus_careful(y)
  @unitrange_check(y, :oneminus)
  oneminus_sloppy(y)
end

doc"""
  pseudologistic(::Posit)

  calculates the pseudo-logistic sigmoid curve for the Posit data type.
"""
pseudologistic(x::Posit) = pseudologistic_careful(x)
pseudologistic_sloppy{P <: Posit}(x::P) = reinterpret(P, (@u(x) $ @signbit) >> 2)
function pseudologistic_careful(x::Posit)
  isfinite(x) || throw(ArgumentError("pseudologistic function is undefined for infinity"))
  __round(pseudologistic_sloppy(x))
end

doc"""
  delta_psl(::Posit)

  calculates the value dy/dx using the differential equation dy/dx = y(1 - y)

  This function is undefined for values > 1 or less than zero.
"""
delta_psl(y::Posit) = delta_psl_careful(y)
delta_psl_sloppy(y) = y * oneminus_sloppy(y)
function delta_psl_careful(y::Posit)
  @unitrange_check(y, :delta_psl)
  __round(delta_psl_sloppy(y))
end

doc"""
  pseudologcost(::Posit)

  calculates the pseudologcost function for the Posit data type.  The
  halfcost function is -log_x(1-y), here we estimate by simple expansion.

  This function is undefined for values > 1 or less than zero.
"""
pseudologcost(y::Posit) = pseudologcost_careful(y)
pseudologcost_sloppy{P <: Posit}(y::P) = reinterpret(P, @u(y) << 1)
function pseudologcost_careful(y::Posit)
  @unitrange_check(y, :pseudologcost)
  __round(pseudologcost_sloppy(y))
end

doc"""
  pseudosoftplus(::Posit)

  calculates the pseudosoftplus function for the Posit data type.  The
  pseudosoftplus emulates ln(1 + e^x).

"""
pseudosoftplus(x::Posit) = pseudosoftplus_careful(x)
pseudosoftplus_sloppy{P <: Posit}(x::P) = reinterpret(P, (@u(x) $ @signbit) >> 1)
@generated function pseudosoftplus_careful{N}(x::Posit{N})
  mask = @mask(N)
  quote
    __round(reinterpret(Posit{N}, @u(pseudosoftplus_sloppy(x)) & $mask))
  end
end


##### ETC

Base.randn{P <: Posit}(::Type{P},args::Integer...) = P.(randn(args...))
