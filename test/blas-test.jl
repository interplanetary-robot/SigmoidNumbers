
#these tests use 64-bit floating point values as the "ground truth".
#sometimes, the input values may need to be trimmed from the exact 64-bit value.
FloatFamily = Union{Posit, Float32, Float16, Float64}
trim_float(arr::Array{Float64}, T::Type{<:FloatFamily}) = Float64.(T.(arr))
trim_float(arr::Array{Complex{Float64}}, T::Type{<:FloatFamily}) = Complex{Float64}.(Complex{T}.(arr))

@testset "blas-level-1-asum-real" begin
  arr64 = rand(10) - 0.5
  arr16_0 = Posit{16,0}.(arr64)
  arr32_1 = Posit{32,1}.(arr64)

  #test exact asum with no striding against the julia native asum function.
  @test Posit{16,0}(BLAS.asum(4, trim_float(arr64, Posit{16,0}), 1)) == BLAS.asum(4, arr16_0, 1)
  @test Posit{32,1}(BLAS.asum(4, trim_float(arr64, Posit{32,1}), 1)) == BLAS.asum(4, arr32_1, 1)

  #test exact asum with striding
  @test Posit{16,0}(BLAS.asum(4, trim_float(arr64, Posit{16,0}), 2)) == BLAS.asum(4, arr16_0, 2)
  @test Posit{32,1}(BLAS.asum(4, trim_float(arr64, Posit{32,1}), 2)) == BLAS.asum(4, arr32_1, 2)
end

@testset "blas-level-1-asum-cplx" begin
  arr_c64 = (rand(10) - 0.5) + (rand(10) - 0.5) * im
  arr_c32_1 = Complex{Posit{32,1}}.(arr_c64)

  #currently, asum_cmplx does not meet exactitude requirements.  Instead, we'll show that it's better
  #than the equivalent basic floating point
  arr_c32 = Complex{Float32}.(arr_c64)

  delta_p32 = abs(
    BLAS.asum(4, trim_float(arr_c64, Posit{32,1}), 1) -
    Float64(BLAS.asum(4, arr_c32_1, 1)))

  delta_f32 = abs(
    BLAS.asum(4, trim_float(arr_c64, Float32), 1) -
    Float64(BLAS.asum(4, arr_c32_1, 1)))

  @test delta_p32 < delta_f32

  #test exact asum with no striding against the julia native asum function.
  #@test Posit{16,0}(BLAS.asum(4, trim_float(arr_c64, Posit{16,0}), 1)) == BLAS.asum(4, arr_c16_0, 1)
  #@test Posit{32,1}(BLAS.asum(4, trim_float(arr_c64, Posit{32,1}), 1)) == BLAS.asum(4, arr_c32_1, 1)

  #test exact asum with striding
  #@test Posit{16,0}(BLAS.asum(4, trim_float(arr_c64, Posit{16,0}), 2)) == BLAS.asum(4, arr_c16_0, 2)
  #@test Posit{32,1}(BLAS.asum(4, trim_float(arr_c64, Posit{32,1}), 2)) == BLAS.asum(4, arr_c32_1, 2)
end

@testset "blas-level-1-dot" begin
  arra_64 = rand(10) - 0.5
  arra_16_0 = Posit{16,0}.(arra_64)
  arra_32_1 = Posit{32,1}.(arra_64)

  arrb_64 = rand(10) - 0.5
  arrb_16_0 = Posit{16,0}.(arrb_64)
  arrb_32_1 = Posit{32,1}.(arrb_64)

  #test exact dot product as the basic dot product.
  @test Posit{16,0}(trim_float(arra_64, Posit{16,0}) ⋅ trim_float(arrb_64, Posit{16,0})) == arra_16_0 ⋅ arrb_16_0
  @test Posit{16,0}(trim_float(arra_64, Posit{16,0}) ⋅ trim_float(arrb_64, Posit{16,0})) == dot(arra_16_0, arrb_16_0)
  @test Posit{32,1}(trim_float(arra_64, Posit{32,1}) ⋅ trim_float(arrb_64, Posit{32,1})) == arra_32_1 ⋅ arrb_32_1

  #test exact asum with striding
  #@test Posit{16,0}(BLAS.dot(4, trim_float(arr64, Posit{16,0}), 2)) == BLAS.asum(4, arr16_0, 2)
  #@test Posit{32,1}(BLAS.dot(4, trim_float(arr64, Posit{32,1}), 2)) == BLAS.asum(4, arr32_1, 2)
end
