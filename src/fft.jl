#naive fast fourier transform for posits.

const TWIDDLE_FACTORS = Dict{Tuple{Type, Integer},Vector}()

typealias CFFT_Type Union{Sigmoid, Float32, Float16}

#actual meat of the fast fourier transform
@generated function __fft{T<:CFFT_Type, l, i, n}(v::AbstractVector{Complex{T}}, ::Type{Val{l}}, ::Type{Val{i}}, ::Type{Val{n}})
  # l - length. (Int.  Must be power of 2)
  # i - is it inverse ? (Bool)
  # n - continuous normalization ? (Bool)

  #don't touch a length 1 fft
  (l == 1) && return :(v)

  #test to see if we need to generate twiddle factors.
  twiddle_tuple = (T, l)

  if !haskey(TWIDDLE_FACTORS,twiddle_tuple)
    if l == 2
      TWIDDLE_FACTORS[twiddle_tuple] = [Complex{T}(1)]
    else
      TWIDDLE_FACTORS[twiddle_tuple] = [Complex{T}(
        (idx == (l÷4 + 1)) ? (-im) : (exp(-2π * im * (idx - 1)/l))) for idx = 1:l÷2]
    end
  end

  twiddle = TWIDDLE_FACTORS[twiddle_tuple]

  twiddle_term = i ? :(conj($twiddle[idx])) : :($twiddle[idx])

  norm_term = (n && iseven(Int64(log2(l)))) ? :(v ./= 2) : :()

  ##consider doing __fft at the length = 8 stage manually.
  quote
    w = copy(v)
    v[1:l÷2]       = __fft(w[1:2:end], Val{l÷2}, Val{i}, Val{n})
    v[(l÷2+1):end] = __fft(w[2:2:end], Val{l÷2}, Val{i}, Val{n})

    for idx = 1:(l ÷ 2)
      t = v[idx]
      v[idx]       = t + $twiddle_term * v[idx + l÷2]
      v[idx + l÷2] = t - $twiddle_term * v[idx + l÷2]
    end

    $norm_term

    return v
  end
end

function custom_fft{T<:CFFT_Type}(v::Union{Vector{Complex{T}}, Vector{T}};
    normalize = :oninverse,
    inverse = false)
  #first check that the length of the vector is a power of 2
  l = length(v)
  ispow2(l) || throw(ArgumentError("non-powers of 2 not currently supported"))

  #turn v into complex vector, if necessary.
  if (typeof(v) == Vector{T})
    v = Complex{T}.(v)
  end

  if normalize == :continuous
    iseven(Int64(log2(l))) || throw(ArgumentError("continuous normalization requires even power of 2"))
    v = __fft(v, Val{l}, Val{inverse}, Val{true})
  else
    v = __fft(v, Val{l}, Val{inverse}, Val{false})
  end


  if normalize == :oninverse
    (inverse) && (v ./= l)
  elseif normalize == :always
    v ./= T(sqrt(l))
  end

  return v
end

custom_ifft(v; normalize = :oninverse) = custom_fft(v, normalize = normalize, inverse = true)

export custom_fft, custom_ifft;
