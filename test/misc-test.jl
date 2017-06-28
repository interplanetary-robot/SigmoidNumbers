@test 1   |> Posit{8,0}  |> SigmoidNumbers.find_lsb ==  0
@test 1   |> Posit{32,2} |> SigmoidNumbers.find_lsb ==  0
@test 5   |> Posit{8,0}  |> SigmoidNumbers.find_lsb ==  0
@test 9   |> Posit{32,2} |> SigmoidNumbers.find_lsb ==  0
@test 0.5 |> Posit{8,0}  |> SigmoidNumbers.find_lsb == -1
@test 0.5 |> Posit{32,2} |> SigmoidNumbers.find_lsb == -1
@test 1.5 |> Posit{8,0}  |> SigmoidNumbers.find_lsb == -1
@test 1.5 |> Posit{32,2} |> SigmoidNumbers.find_lsb == -1

@test -1   |> Posit{8,0}  |> SigmoidNumbers.find_lsb ==  0
@test -1   |> Posit{32,2} |> SigmoidNumbers.find_lsb ==  0
@test -5   |> Posit{8,0}  |> SigmoidNumbers.find_lsb ==  0
@test -9   |> Posit{32,2} |> SigmoidNumbers.find_lsb ==  0
@test -0.5 |> Posit{8,0}  |> SigmoidNumbers.find_lsb == -1
@test -0.5 |> Posit{32,2} |> SigmoidNumbers.find_lsb == -1
@test -1.5 |> Posit{8,0}  |> SigmoidNumbers.find_lsb == -1
@test -1.5 |> Posit{32,2} |> SigmoidNumbers.find_lsb == -1

function find_lsb_q{N,ES}(x::Posit{N,ES})
  q = Quire(Posit{N,ES})
  set!(q, x)
  SigmoidNumbers.find_lsb(q)
end

@test 1   |> Posit{8,0}  |> find_lsb_q ==  0
@test 1   |> Posit{32,2} |> find_lsb_q ==  0
@test 5   |> Posit{8,0}  |> find_lsb_q ==  0
@test 9   |> Posit{32,2} |> find_lsb_q ==  0
@test 0.5 |> Posit{8,0}  |> find_lsb_q == -1
@test 0.5 |> Posit{32,2} |> find_lsb_q == -1
@test 1.5 |> Posit{8,0}  |> find_lsb_q == -1
@test 1.5 |> Posit{32,2} |> find_lsb_q == -1

@test -1   |> Posit{8,0}  |> find_lsb_q ==  0
@test -1   |> Posit{32,2} |> find_lsb_q ==  0
@test -5   |> Posit{8,0}  |> find_lsb_q ==  0
@test -9   |> Posit{32,2} |> find_lsb_q ==  0
@test -0.5 |> Posit{8,0}  |> find_lsb_q == -1
@test -0.5 |> Posit{32,2} |> find_lsb_q == -1
@test -1.5 |> Posit{8,0}  |> find_lsb_q == -1
@test -1.5 |> Posit{32,2} |> find_lsb_q == -1
