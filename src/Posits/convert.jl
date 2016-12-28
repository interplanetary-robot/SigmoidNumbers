#Posit have a special conversion mode where you can convert a value to [0,1]

import Base.convert

convert{N}(::Type{Posit{N}}, bval::Bool) = reinterpret(Posit{N}, bval * (@invertbit))
