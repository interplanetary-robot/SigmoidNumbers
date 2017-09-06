#sigmoid typedef - type definition for sigmoid-valued numbers.
#environment bits parameter.

#for now, put this here
__sigmoid_settings = Dict{Symbol, Any}()
getsetting(k) = haskey(__sigmoid_settings, k) ? __sigmoid_settings[k] : nothing

if (Int == Int32) || getsetting(:basebits) == 32
  const __BITS = 32
elseif getsetting(:basebits) == 16
  const __BITS = 16
elseif getsetting(:basebits) == 8
  const __BITS = 8
else #default to a 64-bit environment.
  const __BITS = 64
end


primitive type Sigmoid{N,ES,mode} <: AbstractFloat __BITS end

#these are deliberately made incompatible with the standard rounding modes types
#found in the julia std library.

const roundingmodes = [:guess,
  :ubit,
  :roundup,
  :rounddn,
  :roundin,
  :roundout]

#set some type aliases.
Posit{N, ES} = Sigmoid{N, ES, :guess}
Vnum{N, ES} = Sigmoid{N, ES, :ubit}

#there's a couple of dummy types that we'll use for syntatical sugar purposes.
Exact{N,ES} = Sigmoid{N, ES, :exact}
ULP{N,ES} = Sigmoid{N, ES, :ULP}
#trampoline their constructor against the Vnum constructor.
(::Type{Exact{N,ES}}){N,ES}(n::Unsigned)::Vnum{N,ES} = iseven(n) ? Vnum{N,ES}(n) : throw(ArgumentError("Exact numbers must have an even int representation!"))
(::Type{ULP{N,ES}}){N,ES}(n::Unsigned)::Vnum{N,ES}   = isodd(n) ? Vnum{N,ES}(n) : throw(ArgumentError("ULP numbers must have an odd int representation!"))

struct Valid{N, ES} <: AbstractFloat
  lower::Vnum{N, ES}
  upper::Vnum{N, ES}
end

#create a right arrow function representation for the construction of valids.
→{N,ES}(lower::Vnum{N,ES}, upper::Vnum{N,ES}) = Valid{N,ES}(lower, upper)

export Sigmoid, Posit, Vnum, Valid, Exact, ULP, →

#sigmoid numbers don't natively have NaN, so NaNs should all be noisy.
struct NaNError <: Exception
  operand::Function
  parameters::Array{Any,1}
end
