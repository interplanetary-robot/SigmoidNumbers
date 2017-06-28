### solving a large system of linear equations demo.

using SigmoidNumbers

P32 = Posit{32,2}

#demonstrating what quires are.

q = Quire(P32)

add!(q, P32(1e20))

add!(q, P32(1e-20))

add!(q, P32(-1e20))

Float64(ans)

#demonstrating the power of quires.

A = random_exact_matrix(P32, 100)

y = exact_rowsum(A)

println((sum(Float64.(A),2)[1], Float64(y[1])))

println((Float64(sum(A,2)[1]), Float64(y[1])))

x = A \ y

sum(abs.(Float64.(x) - 1.0)) / 100.0

x = Float32.(A) \ Float32.(y)

sum(abs.(Float64.(x) - 1.0)) / 100.0


A[:, idx] = A[:, idx] * P32(2.0);

x1 = solve(A, y)

x2 = refine(x1, A, y)

#demonstrate that this is impossible with Float64

A = Float64.(A)
y = Float64.(y)

x1 = A \ y

x1[1]

x2 = x1 + A \ (y - A * x1)
