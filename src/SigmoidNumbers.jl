module SigmoidNumbers

  include("SigmoidTypedef.jl")
  include("macros.jl")
  include("inttools.jl")
  include("sigtools.jl")
  include("h-layer.jl")

  include("Math/iterators.jl")
  include("Math/cmp.jl")
  include("Math/constants.jl")
  include("Math/addsub.jl")
  include("Math/muldiv.jl")

  include("convert.jl")

  include("Posits/posits.jl")
  include("Posits/convert.jl")
  include("Posits/mlfunctions.jl")

  include("Valids/valids.jl")

  include("Tools/fft.jl")

  #temporary
  xlsh{T <: Posit}(x::T) = reinterpret(T, (@u(x) $ (@signbit)) >> 2)
  export xlsh

end # module

#temporary

macro widen(x)
  :(reinterpret(Posit{16,0}, $x))
end
