
isless{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode}) = @s(lhs) < @s(rhs)

Base.:<{N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode}) = (@u(rhs) == (@signbit)) | isless(lhs, rhs)
Base.:<={N, ES, mode}(lhs::Sigmoid{N, ES, mode}, rhs::Sigmoid{N, ES, mode}) = (@u(rhs) == (@signbit)) | (@s(lhs) <= @s(rhs))
