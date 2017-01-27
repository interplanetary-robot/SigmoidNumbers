#sigtools.jl - functions that help with working with the sigmoid numbers.

@generated function clz{N, ES, mode}(x::SigmoidSmall{N, ES, mode})
  if (mode == :ubit)
    :(min(leading_zeros(@u(x) & ~sign_mask), N - 1))
  else
    :(leading_zeros(@u(x) & ~sign_mask))
  end
end

@generated function clo{N, ES, mode}(x::SigmoidSmall{N, ES, mode})
  if (mode == :ubit)
    :(min(leading_ones(@u(x) | sign_mask), N - 1))
  else
    :(leading_ones(@u(x) | sign_mask))
  end
end

@generated function regimebits{N, ES, mode}(x::Sigmoid{N, ES, mode})
  if mode == :ubit
    quote
      lz = clz(x)
      lo = clo(x)
      min(max(lz, lo), N - 2)
    end
  else
    quote
      lz = clz(x)
      lo = clo(x)
      min(max(lz, lo), N - 1)
    end
  end
end
