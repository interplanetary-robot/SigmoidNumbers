
function substitute_regexp(fn_expr, regexp)
    functioncall = String(fn_expr.args[1].args[1])
    placeholder = :(Base.BLAS.placeholder())
    rmatch = match(regexp, functioncall)
    if rmatch != nothing
        substitute_expr = copy(fn_expr)
        placeholder.args[1].args[2] = is_quire[1] |> Symbol |> QuoteNode
        substitute_expr.args[1].args[1] = placeholder.args[1]
        substitute_expr
    else
        :()
    end
end

macro blas(fn_expr)
    #first, make sure that this thing is actually a function
    (fn_expr.head == :function) || throw(ArgumentError("@blas must be called on a function"))

    substitute_expr = substitute_regexp(fn_expr, USE_QUIRE ? r"(.*)_quire$" : r"(.*)_naive")

    quote
        #always create the base function expression
        $fn_expr
        #sometimes create the substitute expression.
        $substitute_expr
    end
end

PositOrComplex{N,ES} = Union{Complex{Posit{N,ES}}, Posit{N,ES}}
