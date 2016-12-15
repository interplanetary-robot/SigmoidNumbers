#iterators.jl - creating iterator convenience types for SigmoidNumbers.

increment{N, mode}(::Type{Sigmoid{N, mode}}) = (@signbit) >> (N - 1)
Base.next{N, mode}(x::Sigmoid{N, mode}) = reinterpret(Sigmoid{N, mode}, @u(x) + increment(Sigmoid{N, mode}))
prev{N, mode}(x::Sigmoid{N, mode}) = reinterpret(Sigmoid{N, mode}, @u(x) - increment(Sigmoid{N, mode}))

Base.start{N, mode}(T::Type{Sigmoid{N, mode}}) = T(Inf)
Base.next{N, mode}(T::Type{Sigmoid{N, mode}}, state) = (state, next(state))
@generated function Base.done{N, mode}(T::Type{Sigmoid{N, mode}}, state)
  last_element = reinterpret(Sigmoid{N, mode}, (@signbit) - increment(Sigmoid{N, mode}))
  :(state == $last_element)
end
Base.length{N, mode}(T::Type{Sigmoid{N, mode}}) = 1 << N
