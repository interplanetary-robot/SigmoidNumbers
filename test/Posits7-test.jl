M7 = Posits{7}

#and a general purpose function for testing an operation against a matrix
function testop(op, iterable)
  fails = 0
  totalsize = length(iterable)
  for STile1 in iterable, STile2 in iterable
    fval1 = Float64(STile1)
    fval2 = Float64(STile2)

    exp = iterable(op(fval1, fval2))
    fexp = Float64(exp)
    res = op(STile1, STile2)
    fres = Float64(res)

    if (exp != res)
      println("$iterable: $(fval1) $op $(fval2) failed as $(fres); should be $(fexp)")
      fails += 1
    end
  end
  println("$iterable: $op $fails / $(totalsize) = $(100 * fails/totalsize)% failure!")
end

testop(+, M7)
testop(-, M7)
testop(*, M7)
testop(/, M7)
