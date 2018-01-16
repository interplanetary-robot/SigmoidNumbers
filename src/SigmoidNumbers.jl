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
  include("Tools/ubox.jl")

  include("quire.jl")
  include("fdp-matrixsolve.jl")
  include("quire_solve.jl")

  #patching julia's native lu factorization.
  include("LUpatches.jl")

  #including blas functions
  include("BLAS/blas.jl")
  include("BLAS/Level1.jl")
  include("BLAS/Level2-er.jl")
  include("BLAS/Level2-mv.jl")
  include("BLAS/Level2-sv.jl")

end # module
