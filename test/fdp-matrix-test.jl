
#set up a matrix that has the form we're looking for.
M = [1.0 2.0 3.0
     2.0 5.0 5.0
     2.0 2.0 6.0]
new_row = zeros(3)
SigmoidNumbers.get_unscaled_replacement_row!(new_row, M, 2, zeros(3), Quire(Float64))
@test new_row == [0, 1, -1]

#do it with a bigger matrix.
M = [1.0 2.0 3.0
     0.0 1.0 -1.0
     2.0 2.0 6.0]
new_row = zeros(3)
SigmoidNumbers.get_unscaled_replacement_row!(new_row, M, 3, zeros(3), Quire(Float64))
@test new_row == [0, 0, -2]

M = [1.0 2.0 3.0
     2.0 5.0 5.0
     2.0 2.0 6.0]
v = ones(3)

SigmoidNumbers.row_echelon!(M, v, Quire(Float64))
@test M == [1.0 2.0 3.0
            0.0 1.0 -1.0
            0.0 0.0 1.0]
@test v == [1.0, -1.0, 1.5]


r = ones(3)
SigmoidNumbers.solve_row_echelon!(r, M, v, Quire(Float64))
@test r == [-4.5, 0.5, 1.5]
