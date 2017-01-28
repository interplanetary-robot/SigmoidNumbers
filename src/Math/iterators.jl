#iterators.jl - creating iterator convenience types for SigmoidNumbers.

import Base: next, start, done, length

increment{N, ES, mode}(::Type{Sigmoid{N, ES, mode}}) = (@signbit) >> (N - 1)

@generated function next{N, ES, mode}(x::Sigmoid{N, ES, mode})
  inc = increment(Sigmoid{N, ES, mode})
  :(reinterpret(Sigmoid{N, ES, mode}, @u(x) + $inc))
end

@generated function prev{N, ES, mode}(x::Sigmoid{N, ES, mode})
  inc = increment(Sigmoid{N, ES, mode})
  :(reinterpret(Sigmoid{N, ES, mode}, @u(x) - $inc))
end

start{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}) = T(Inf)
next{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, state) = (state, next(state))

@generated function done{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}, state)
  last_element = reinterpret(Sigmoid{N, ES, mode}, (@signbit) - increment(Sigmoid{N, ES, mode}))
  :(state == $last_element)
end

length{N, ES, mode}(T::Type{Sigmoid{N, ES, mode}}) = 1 << N

export prev
