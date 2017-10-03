#ubox method.

"""
    splitintwo(x::Valid) takes a valid and bifurcates it into a upper and lower
    half, based on their posit representation.
"""
function splitintwo(x::Valid{N,ES}) where {N, ES}
    if (x.upper == next(x.lower))
        tile(x.lower), tile(x.upper)
    elseif (isallreals(x))
        Vnum{N,ES}(Inf) → maxneg(Vnum{N,ES}), zero(Vnum{N,ES}) → maxpos(Vnum{N,ES})
    elseif (roundsinf(x))
        if !isfinite(x.lower)
            Valid{N,ES}(Inf), minneg(Vnum{N,ES}) → x.upper
        elseif !isfinite(x.upper)
            Valid{N,ES}(Inf), x.lower → maxpos(Vnum{N,ES})
        else
            x.lower → Vnum{N,ES}(Inf), minneg(Vnum{N,ES}) → x.upper
        end
    else
        middle = reinterpret(Vnum{N,ES}, (@u x.lower) >> 1 + (@u x.upper) >> 1) |> __round
        x.lower → middle, next(middle) → x.upper
    end
end

"""
    vwidth(x::Valid{N,ES})

    describe the width of the valid number.  This is the number of tiles.
"""
vwidth{N,ES}(x::Valid{N,ES}) = (@u x.upper) - (@u x.lower)

function merge_contiguous!(v1::Array{Valid{N,ES},J}, v2::Array{Valid{N,ES},J}) where J where {N,ES}
    dim = 0
    for idx = 1:length(v1)
        dim = idx
        (v1[idx] != v2[idx]) && break
    end
    (dim == 0) && return false
    (next(v1[dim].upper) == v2[dim].lower) || (next(v2[dim].upper) == v1[dim].lower) || return false
    for idx = (dim + 1):length(v1)
        v1[idx] != v2[idx] && return false
    end

    if next(v1[dim].upper) == v2[dim].lower
        v1[dim] = v1[dim].lower → v2[dim].upper
    else
        v1[dim] = v2[dim].lower → v1[dim].upper
    end
    true
end

function coalesce!(a::Vector{Array{Valid{N,ES},J}}, b::Vector{Array{Valid{N,ES},J}}) where J where {N,ES}
    for new_item in b
        #check to see if you can merge it into anything in a.
        merged = false
        for idx = 1:length(a)
            if merge_contiguous!(a[idx],new_item)
                merged = true
                break
            end
        end
        merged || push!(a, new_item)
    end
    coalesce!(a)
end

function coalesce!(a::Vector{Array{Valid{N,ES},J}}) where J where {N,ES}
    result = Array{Valid{N,ES},J}[]
    for a_item in a
        merged = false
        for idx = 1:length(result)
            if merge_contiguous!(result[idx], a_item)
                merged = true
                break
            end
        end
        merged || push!(result, a_item)
    end
    result
end

"""
    ufilter(predicate, dataset::Vector{Any})
"""
function ufilter(pred::Function, x::Valid{N,ES}, ::Type{Val{verbose}} = Val{false}) where {N, ES, verbose}
    if pred(x)
        verbose && println("interval $x checks out.")
        if istile(x)
            return Valid{N,ES}[x]
        else
            (upper, lower) = splitintwo(x)
            vcat(ufilter(pred, lower), ufilter(pred, upper))
        end
    else
        return Valid{N,ES}[]
    end
end
function ufilter(pred::Function, x::Array{Valid{N,ES},J}) where J where {N, ES}
    if pred(x)
        #check to see if we're all tiles.
        mapreduce(istile, &, true, x) && return Array{Valid{N,ES},J}[x]
        #find the thing with the biggest index.
        (_, idx) = x .|> vwidth |> findmax
        upper_array = copy(x)
        lower_array = copy(x)

        lower_value, upper_value = x[idx] |> splitintwo

        lower_array[idx] = lower_value
        upper_array[idx] = upper_value

        coalesce!(ufilter(pred, lower_array), ufilter(pred, upper_array))
    else
        return Array{Valid{N,ES},J}[]
    end
end

function boundingbox(aofv::Vector{Array{Valid{N,ES},J}}) where J where {N,ES}
    bound = first(aofv)
    if length(aofv) > 1
        for idx = 2:length(aofv)
            current_item = aofv[idx]
            for jdx = 1:length(current_item)
                if current_item[jdx].lower < bound[jdx].lower
                    bound[jdx] = current_item[jdx].lower → bound[jdx].upper
                end
                if current_item[jdx].upper > bound[jdx].upper
                    bound[jdx] = bound[jdx].lower → current_item[jdx].upper
                end
            end
       end
    end
    bound
end

export ufilter
export boundingbox
