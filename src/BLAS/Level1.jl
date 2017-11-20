
@blas function asum_naive{N,ES}(n::Integer, X::DenseArray{PositOrComplex{N,ES}}, incx::Integer, SA::Real)
    if (n<0 || incx < 0)
		return
	end
	if (incx == 1)
		m = n%5
		if (m != 0)
			for i = 1:m
				X[i] = SA*X[i]
			end
			if (n < 5)
				return
			end
		end
		mp1 = m + 1
		for i = mp1:5:n
			X[i] = SA*SX[i]
			X[i+1] = SA*SX[i+1]
			X[i+2] = SA*SX[i+2]
			X[i+3] = SA*SX[i+3]
			X[i+4] = SA*SX[i+4]
		end
	else
		nincx = n*incx
		for i = 1:incx:nincx
			X[i] = SA*X[i]
		end
	end
end

@blas function asum_quire(n::Integer, X::DenseArray{PositOrComplex{N,ES}}, incx::Integer)
    #code here
end
