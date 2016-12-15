import Base.bits

bits{N, mode}(x::Sigmoid{N, mode}) = bits(reinterpret(@UInt, x))[1:N]
