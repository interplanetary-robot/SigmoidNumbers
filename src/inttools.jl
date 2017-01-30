@generated function promote(n::Unsigned)
  ptype = Dict{Type, Type}(UInt8 => UInt16,
                           UInt16 => UInt32,
                           UInt32 => UInt64,
                           UInt64 => UInt128)[n]
  :( $ptype(n) )
end

@generated function demote(n::Unsigned)
  dtype = Dict{Type, Type}(UInt16 => UInt8,
                           UInt32 => UInt16,
                           UInt64 => UInt32,
                           UInt128 => UInt64)[n]
  dlength = sizeof(dtype) * 8
  :( $dtype(n >> $dlength) )
end

@generated function demoteright(n::Unsigned)
  dtype = Dict{Type, Type}(UInt16 => UInt8,
                           UInt32 => UInt16,
                           UInt64 => UInt32,
                           UInt128 => UInt64)[n]
  dlength = sizeof(dtype) * 8
  dmask = n(zero(dtype) - one(dtype))
  :($dtype(n & $dmask))
end
