M7 = MLSigmoid{7}

for STile1 in M7, STile2 in M7
  fval1 = STile1
  fval2 = STile2
  @test M7(fval1 + fval2) == STile1 + STile2
end
