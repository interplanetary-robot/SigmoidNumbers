
bitsize = ARGS[2]

for idx = (parse(ARGS[2])-2):-1:2
  data = readdlm(string(ARGS[1], "-", ARGS[2], "-", idx, ".csv"))

  print(sum(data)/1000,",,")
  print(sum(data .== 0.0)/1000,",")
  println(sum(data .<= 5.0)/1000)
end

