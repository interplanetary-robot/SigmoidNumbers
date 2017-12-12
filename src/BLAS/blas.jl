PositOrComplex{N,ES} = Union{Complex{Posit{N,ES}}, Posit{N,ES}}

const __real_quire = Quire(Posit{32,2})
const __imag_quire = Quire(Posit{32,2})

#this is a temporary shim to achieve some BLAS calculations

Base.sqrt{N,ES}(x::Posit{N,ES}) = Posit{N,ES}(Float64(x))
