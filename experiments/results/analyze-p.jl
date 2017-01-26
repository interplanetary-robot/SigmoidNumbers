
for idx = (12):-1:6
  data = readdlm(string("posit2-", idx, ".csv"))

  print(sum(data)/1000,",,")
  print(sum(data .== 0.0)/1000,",")
  println(sum(data .<= 5.0)/1000)
end

