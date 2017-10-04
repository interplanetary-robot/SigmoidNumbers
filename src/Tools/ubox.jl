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



function splitinthree(x::Valid{N,ES}) where {N, ES}
    if (x.upper == next(next(x.lower)))
        tile(x.lower), x.lower |> next |> tile, tile(x.upper)
    elseif (isallreals(x))
        Vnum{N,ES}(Inf) → maxneg(Vnum{N,ES}), Vnum{N,ES} |> zero |> tile, minpos(Vnum{N,ES}) → maxpos(Vnum{N,ES})
    elseif (roundsinf(x))
        if !isfinite(x.lower)
            (Valid{N,ES}(Inf), splitintwo(minneg(Vnum{N,ES}) → x.upper)...)
        elseif !isfinite(x.upper)
            (splitintwo(x.lower → maxpos(Vnum{N,ES}))..., Valid{N,ES}(Inf), )
        else
            x.lower → maxneg(Vnum{N,ES}), Inf |> Vnum{N,ES} |> tile, minneg(Vnum{N,ES}) → x.upper
        end
    else
        middle1 = reinterpret(Vnum{N,ES}, (3 * ((@s x.lower) >> 2) + ((@s x.upper) >> 2))) |> __round
        middle2 = reinterpret(Vnum{N,ES}, (((@s x.lower) >> 2) + 3 * ((@s x.upper) >> 2))) |> __round
        x.lower → middle1, next(middle1) → prev(middle2), middle2 → x.upper
    end
end

"""
    vwidth(x::Valid{N,ES})

    describe the width of the valid number.  This is the number of tiles.
"""
vwidth{N,ES}(x::Valid{N,ES}) = ((@u x.upper) - (@u x.lower)) >> (64 - N) + 1

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
    for b_item in b
        coalesce!(a, b_item)
    end
    #coalesce!(a)
    return a
end
function coalesce!(a::Vector{Array{Valid{N,ES},J}}, b::Array{Valid{N,ES},J}) where J where {N,ES}
    merged = false
    for idx = 1:length(a)
        if merge_contiguous!(a[idx],b)
            merged = true
            break
        end
    end
    merged || push!(a, b)
end

function coalesce_2!(a::Vector{Array{Valid{N,ES},J}}) where J where {N,ES}
    #pop the top two values and attempt to coalesce them.
    if length(a) >= 2
        if merge_contiguous!(a[end-1], a[end])
            pop!(a)
        end
    end
end

function coalesce_top!(a::Vector{Array{Valid{N,ES},J}}) where J where {N,ES}
    while length(a) >= 2
        if merge_contiguous!(a[end-1], a[end])
            pop!(a)
        else
            break
        end
    end
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

function ufilter_bfs(pred::Function, x::Array{Valid{N,ES},J}) where J where {N,ES}
    #consider implementing this as a linked list type for better performance.
    queue = Array{Valid{N,ES},J}[]
    results = Array{Valid{N,ES},J}[]
    unshift!(queue, x)
    iter = 0
    while length(queue) > 0
        #examine the first element in the queue.
        this_box = shift!(queue)
        if pred(this_box)
            if mapreduce(istile, &, true, this_box)
                coalesce!(results, this_box)
            else
                #find the widest index in the array.
                (_, idx) = this_box .|> vwidth |> findmax
                upper_array = copy(this_box)
                lower_array = copy(this_box)

                #split this index in the array into two.
                lower_value, upper_value = this_box[idx] |> splitintwo

                lower_array[idx] = lower_value
                upper_array[idx] = upper_value

                #push both arrays onto the check queue.
                unshift!(queue, lower_array)
                unshift!(queue, upper_array)
            end
        end
    end
    results
end

#a temporary version of this, needs to take into account roundsinf.
function Base.union(a::Valid{N,ES},b::Valid{N,ES}) where {N,ES}
    return min(a.lower, b.lower) → max(a.upper, b.upper)
end

function merge_into!(a::Array{Valid{N,ES},J}, b::Array{Valid{N,ES},J}) where J where {N,ES}
    #just assign when a in a.
    isempty(a[1]) && (a[:] = b[:]; return)
    for idx = 1:length(a)
        a[idx] = union(a[idx], b[idx])
    end
end

function Base.in(a::Valid{N,ES}, b::Valid{N,ES}) where {N,ES}
    return a.lower >= b.lower && a.upper <= b.upper
end

function ufilter_dfs(pred::Function, x::Array{Valid{N,ES},J}) where J where {N,ES}
    #consider implementing this as a linked list type for better performance.
    queue = Array{Valid{N,ES},J}[]
    bbox = [Valid{N,ES}(∅) for idx in 1:length(x)]
    push!(queue, x)
    iter = 0
    while length(queue) > 0
        #examine the first element in the queue.
        this_box = pop!(queue)

        this_box in bbox && continue

        if pred(this_box)
            if mapreduce(istile, &, true, this_box)
                merge_into!(bbox, this_box)
            else
                #find the widest index in the array.
                (_, idx) = this_box .|> vwidth |> findmax

                this_width = this_box[idx] |> vwidth

                if this_width >= 3
                    upper_array = copy(this_box)
                    middle_array = copy(this_box)
                    lower_array = copy(this_box)

                    #split this index in the array into two.
                    lower_value, middle_value, upper_value = this_box[idx] |> splitinthree

                    lower_array[idx] = lower_value
                    middle_array[idx] = middle_value
                    upper_array[idx] = upper_value

                    #push all arrays onto the check queue, but put the middle last.
                    push!(queue, middle_array)
                    push!(queue, lower_array)
                    push!(queue, upper_array)
                else
                    upper_array = copy(this_box)
                    lower_array = copy(this_box)

                    #split this index in the array into two.
                    lower_value, upper_value = this_box[idx] |> splitintwo

                    lower_array[idx] = lower_value
                    upper_array[idx] = upper_value

                    #push both arrays onto the check queue.
                    push!(queue, lower_array)
                    push!(queue, upper_array)
                end
            end
        end
    end
    bbox
end

export ufilter, ufilter_bfs, ufilter_dfs
