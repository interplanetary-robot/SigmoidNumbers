#warlpiri-properties.jl - uses warlpiri numbers to test valid properties.

@testset "warlpiri-properties" begin
    @test isempty.(wmatrix) == map(x -> (x == (WP0001 → WP0000)) || (x == (WP0000 → WP1111)), wmatrix)

    const warlpiri_allreals =
        [WP0010 → WP0001, WP0011 → WP0010, WP0100 → WP0011, WP0101 → WP0100,
         WP0110 → WP0101, WP0111 → WP0110, WP1000 → WP0111, WP1001 → WP1000,
         WP1010 → WP1001, WP1011 → WP1010, WP1100 → WP1011, WP1101 → WP1100,
         WP1110 → WP1101, WP1111 → WP1110]

    @test SigmoidNumbers.isallreals.(wmatrix) == map((x) -> x in warlpiri_allreals, wmatrix)

    #roundsinf test          ->  0000  0001  0010  0011  0100  0101  0110  0111  1000  1001  1010  1011  1100  1101  1110  1111
    const warlpiri_roundsinf = [false false false false false false false false  true  true  true  true  true  true  true false  # 0000 ->
                                false false false false false false false false  true  true  true  true  true  true  true  true  # 0001 ->
                                 true  true false false false false false false  true  true  true  true  true  true  true  true  # 0010 ->
                                 true  true  true false false false false false  true  true  true  true  true  true  true  true  # 0011 ->
                                 true  true  true  true false false false false  true  true  true  true  true  true  true  true  # 0100 ->
                                 true  true  true  true  true false false false  true  true  true  true  true  true  true  true  # 0101 ->
                                 true  true  true  true  true  true false false  true  true  true  true  true  true  true  true  # 0110 ->
                                 true  true  true  true  true  true  true false  true  true  true  true  true  true  true  true  # 0111 ->
                                 true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  # 1000 ->
                                false false false false false false false false  true false false false false false false false  # 1001 ->
                                false false false false false false false false  true  true false false false false false false  # 1010 ->
                                false false false false false false false false  true  true  true false false false false false  # 1011 ->
                                false false false false false false false false  true  true  true  true false false false false  # 1100 ->
                                false false false false false false false false  true  true  true  true  true false false false  # 1101 ->
                                false false false false false false false false  true  true  true  true  true  true false false  # 1110 ->
                                false false false false false false false false  true  true  true  true  true  true  true false  # 1111 ->
    ]

    @test SigmoidNumbers.roundsinf.(wmatrix) == warlpiri_roundsinf

    #containszero test       ->  0000  0001  0010  0011  0100  0101  0110  0111  1000  1001  1010  1011  1100  1101  1110  1111
    const warlpiri_containszero = [ true  true  true  true  true  true  true  true  true  true  true  true  true  true  true false  # 0000 ->
                                   false false false false false false false false false false false false false false false false  # 0001 ->
                                    true  true false false false false false false false false false false false false false false  # 0010 ->
                                    true  true  true false false false false false false false false false false false false false  # 0011 ->
                                    true  true  true  true false false false false false false false false false false false false  # 0100 ->
                                    true  true  true  true  true false false false false false false false false false false false  # 0101 ->
                                    true  true  true  true  true  true false false false false false false false false false false  # 0110 ->
                                    true  true  true  true  true  true  true false false false false false false false false false  # 0111 ->
                                    true  true  true  true  true  true  true  true false false false false false false false false  # 1000 ->
                                    true  true  true  true  true  true  true  true  true false false false false false false false  # 1001 ->
                                    true  true  true  true  true  true  true  true  true  true false false false false false false  # 1010 ->
                                    true  true  true  true  true  true  true  true  true  true  true false false false false false  # 1011 ->
                                    true  true  true  true  true  true  true  true  true  true  true  true false false false false  # 1100 ->
                                    true  true  true  true  true  true  true  true  true  true  true  true  true false false false  # 1101 ->
                                    true  true  true  true  true  true  true  true  true  true  true  true  true  true false false  # 1110 ->
                                    true  true  true  true  true  true  true  true  true  true  true  true  true  true  true false  # 1111 ->
    ]

    @test SigmoidNumbers.containszero.(wmatrix) == warlpiri_containszero

    #ispositive test          ->  0000  0001  0010  0011  0100  0101  0110  0111  1000  1001  1010  1011  1100  1101  1110  1111
    const warlpiri_ispositive = [false false false false false false false false false false false false false false false false  # 0000 ->
                                 false  true  true  true  true  true  true  true false false false false false false false false  # 0001 ->
                                 false false  true  true  true  true  true  true false false false false false false false false  # 0010 ->
                                 false false false  true  true  true  true  true false false false false false false false false  # 0011 ->
                                 false false false false  true  true  true  true false false false false false false false false  # 0100 ->
                                 false false false false false  true  true  true false false false false false false false false  # 0101 ->
                                 false false false false false false  true  true false false false false false false false false  # 0110 ->
                                 false false false false false false false  true false false false false false false false false  # 0111 ->
                                 false false false false false false false false false false false false false false false false  # 1000 ->
                                 false false false false false false false false false false false false false false false false  # 1001 ->
                                 false false false false false false false false false false false false false false false false  # 1010 ->
                                 false false false false false false false false false false false false false false false false  # 1011 ->
                                 false false false false false false false false false false false false false false false false  # 1100 ->
                                 false false false false false false false false false false false false false false false false  # 1101 ->
                                 false false false false false false false false false false false false false false false false  # 1110 ->
                                 false false false false false false false false false false false false false false false false  # 1111 ->
    ]

    @test SigmoidNumbers.ispositive.(wmatrix) == warlpiri_ispositive

    #isnegative test          ->  0000  0001  0010  0011  0100  0101  0110  0111  1000  1001  1010  1011  1100  1101  1110  1111
    const warlpiri_isnegative = [false false false false false false false false false false false false false false false false  # 0000 ->
                                 false false false false false false false false false false false false false false false false  # 0001 ->
                                 false false false false false false false false false false false false false false false false  # 0010 ->
                                 false false false false false false false false false false false false false false false false  # 0011 ->
                                 false false false false false false false false false false false false false false false false  # 0100 ->
                                 false false false false false false false false false false false false false false false false  # 0101 ->
                                 false false false false false false false false false false false false false false false false  # 0110 ->
                                 false false false false false false false false false false false false false false false false  # 0111 ->
                                 false false false false false false false false false false false false false false false false  # 1000 ->
                                 false false false false false false false false false  true  true  true  true  true  true  true  # 1001 ->
                                 false false false false false false false false false false  true  true  true  true  true  true  # 1010 ->
                                 false false false false false false false false false false false  true  true  true  true  true  # 1011 ->
                                 false false false false false false false false false false false false  true  true  true  true  # 1100 ->
                                 false false false false false false false false false false false false false  true  true  true  # 1101 ->
                                 false false false false false false false false false false false false false false  true  true  # 1110 ->
                                 false false false false false false false false false false false false false false false  true  # 1111 ->
    ]

    @test SigmoidNumbers.isnegative.(wmatrix) == warlpiri_isnegative

    #test equality of all allreals.
    WP_z = zero(WP)
    WP_allreals = [next(a) → a for a in WP if a != WP_z && next(a) != WP_z]
    for a in WP_allreals, b in WP_allreals
        @test a == b
    end

    #test equality of the two null values.
    @test (next(WP_z) → WP_z) == (WP_z → prev(WP_z))
end
