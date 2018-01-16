PositOrComplex{N,ES} = Union{Complex{Posit{N,ES}}, Posit{N,ES}}

const __real_quire = Quire(Posit{32,2})
const __imag_quire = Quire(Posit{32,2})

#this is a temporary shim to achieve some BLAS calculations

Base.sqrt{N,ES}(x::Posit{N,ES}) = Posit{N,ES}(Float64(x))

#this function is going to be called a lot.

@doc """

  calculates an exact dot product of real posits without quires, but does NOT do
  bounds checking.  This function should be called, but only when that check has
  been performed.

"""
function naked_dot{N,ES}(x::AbstractArray{Posit{N,ES}}, y::AbstractArray{Posit{N,ES}})
    accumulator = zero(Posit{N,ES})
    zero!(__real_quire)
    for idx = 1:length(x)
        @inbounds accumulator = fdp!(__real_quire, x[idx], y[idx])
    end
    accumulator
end

function naked_dot{N,ES}(x::AbstractArray{Complex{Posit{N,ES}}}, y::AbstractArray{Complex{Posit{N,ES}}})
  zero!(__real_quire)
  zero!(__imag_quire)
  real_accumulator = zero(Posit{N,ES})
  imag_accumulator = zero(Posit{N,ES})
  for idx in 1:length(x)
      #note that for complex values, the first vector is conjugated.
      @inbounds fdp!(__real_quire, real(x[idx]), real(y[idx]))
      @inbounds real_accumulator = fdp!(__real_quire, imag(x[idx]), imag(y[idx]))
      @inbounds fdp!(__imag_quire, real(x[idx]), imag(y[idx]))
      @inbounds imag_accumulator = fdp!(__imag_quire, -imag(x[idx]), real(y[idx]))
  end

  real_accumulator + imag_accumulator * im
end

@doc """

  calculates an scaled naked dot product of real posits without quires, but does NOT do
  bounds checking.  This function should be called, but only when that check has
  been performed.  The scale applies to the second vector.

"""
function naked_dot{T<:Posit}(x::AbstractArray{T}, y::AbstractArray{T}, sc::T, seed_1::T = zero(T), seed_2::T = zero(T))
    zero!(__real_quire)
    accumulator = fdp!(__real_quire, seed_1, seed_2)
    for idx = 1:length(x)
        @inbounds accumulator = fdp!(__real_quire, x[idx], y[idx] * sc)
    end
    accumulator
end

@generated function naked_dot{T<:Posit, C}(
    x::AbstractArray{Complex{T}},
    y::AbstractArray{Complex{T}},
    sc::T,
    seed_1::Complex{T} = zero(Complex{T}),
    seed_2::Complex{T} = zero(Complex{T}),
    ::Type{Val{C}} = Val{:noconj})

  if C == :conj
    main_code = quote
      for idx in 1:length(x)
        #note that for complex values, the first vector is conjugated.
        @inbounds                    fdp!(__real_quire,  real(x[idx]), real(y[idx]) * sc)
        @inbounds real_accumulator = fdp!(__real_quire,  imag(x[idx]), imag(y[idx]) * sc)
        @inbounds                    fdp!(__imag_quire,  real(x[idx]), imag(y[idx]) * sc)
        @inbounds imag_accumulator = fdp!(__imag_quire, -imag(x[idx]), real(y[idx]) * sc)
      end
    end
  elseif C == :noconj
    main_code = quote
      for idx in 1:length(x)
        @inbounds                    fdp!(__real_quire,  real(x[idx]), real(y[idx]) * sc)
        @inbounds real_accumulator = fdp!(__real_quire, -imag(x[idx]), imag(y[idx]) * sc)
        @inbounds                    fdp!(__imag_quire,  real(x[idx]), imag(y[idx]) * sc)
        @inbounds imag_accumulator = fdp!(__imag_quire,  imag(x[idx]), real(y[idx]) * sc)
      end
    end
  end

  quote
    real_accumulator = zero(T)
    imag_accumulator = zero(T)
    zero!(__real_quire)
    zero!(__imag_quire)

    fdp!(__real_quire, real(seed_1), sc)
    fdp!(__imag_quire, imag(seed_1), sc)

    $main_code

    real_accumulator + imag_accumulator * im
  end
end

function naked_dot{T<:Posit}(x::AbstractArray{Complex{T}}, y::AbstractArray{Complex{T}}, sc::Complex{T})
  zero!(__real_quire)
  zero!(__imag_quire)
  real_accumulator = zero(T)
  imag_accumulator = zero(T)
  for idx in 1:length(x)
      @inbounds                    fdp!(__real_quire,  real(x[idx]), real(y[idx]) * real(sc))
      @inbounds                    fdp!(__real_quire,  imag(x[idx]), imag(y[idx]) * real(sc))
      @inbounds                    fdp!(__real_quire,  imag(x[idx]), real(y[idx]) * imag(sc))
      @inbounds real_accumulator = fdp!(__real_quire,  real(x[idx]), imag(y[idx]) * imag(sc))

      @inbounds                    fdp!(__imag_quire,  real(x[idx]), real(y[idx]) * imag(sc))
      @inbounds                    fdp!(__imag_quire,  real(x[idx]), imag(y[idx]) * real(sc))
      @inbounds                    fdp!(__imag_quire,  imag(x[idx]), real(y[idx]) * real(sc))
      @inbounds imag_accumulator = fdp!(__imag_quire,  imag(x[idx]), imag(y[idx]) * imag(sc))
  end

  real_accumulator + imag_accumulator * im
end
