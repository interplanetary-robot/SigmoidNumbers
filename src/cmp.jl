
isless{N, mode}(lhs::Sigmoid{N, mode}, rhs::Sigmoid{N, mode}) = @s(lhs) < @s(rhs)

Base.:<{N, mode}(lhs::Sigmoid{N, mode}, rhs::Sigmoid{N, mode}) = (@u(rhs) == (@signbit)) | isless(lhs, rhs)
Base.:<={N, mode}(lhs::Sigmoid{N, mode}, rhs::Sigmoid{N, mode}) = (@u(rhs) == (@signbit)) | (@s(lhs) <= @s(rhs))
