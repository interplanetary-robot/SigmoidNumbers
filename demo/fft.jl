using SigmoidNumbers

if length(ARGS) < 2
  print("""
  USE:
  julia fft.jl [vector_length] [posit_precision] [posit_es] [distribution = {-1:0:1}]

  executes a fast fourier transform/inverse transform of a random vector and
  measures the deviation from the original in standard floats or posits.

  julia fft.jl 1024 32
  julia fft.jl 256  16 randn
  """)

  exit()
end

vector_size = parse(ARGS[1])
posit_precision = parse(ARGS[2])
posit_es = parse(ARGS[3])

F = posit_precision <= 16 ? Float16 : Float32
P = Posit{posit_precision, posit_es}

if length(ARGS) < 4
  randomizer() = rand(-1:1, vector_size)
elseif ARGS[4] == "randn"
  randomizer() = randn(vector_size)
elseif ARGS[4] == "rand"
  randomizer() = rand(vector_size)
end


function ffttest()

  sv = randomizer()

  v = F.(sv)
  t = ifft(fft(v))
  d = sum(abs.(Complex{Float64}.(t .- v)))
  println("$F deviation: ", d)

  vp = P.(sv)
  tp = ifft(fft(vp))
  dp = sum(abs.(Complex{Float64}.(tp .- vp)))
  println("$P deviation: ", dp)

  tp = ifft(fft(vp, normalize=:always), normalize=:always)
  dp = sum(abs.(Complex{Float64}.(tp .- vp)))
  println("$P deviation: ", dp)

  tp = ifft(fft(vp, normalize=:continuous), normalize=:continuous)
  dp = sum(abs.(Complex{Float64}.(tp .- vp)))
  println("$P deviation: ", dp)

end

ffttest()
