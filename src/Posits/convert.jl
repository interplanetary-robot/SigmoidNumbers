#posits have a special conversion mode where you can convert a value to [0,1]

import Base.convert

convert{N}(::Type{Posits{N}}, bval::Bool) = reinterpret(Posits{N}, bval * (@invertbit))
