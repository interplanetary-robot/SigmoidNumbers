
#make sure our representations are accurate.
@testset "h-layer spot check" begin
    @test describe(WP0000, identity) == "Vnum{4,0}(0.0 ex)"
    @test describe(WP0001, identity) == "Vnum{4,0}(0.0 op → 0.5 op)"
    @test describe(WP0010, identity) == "Vnum{4,0}(0.5 ex)"
    @test describe(WP0011, identity) == "Vnum{4,0}(0.5 op → 1.0 op)"
    @test describe(WP0100, identity) == "Vnum{4,0}(1.0 ex)"
    @test describe(WP0101, identity) == "Vnum{4,0}(1.0 op → 2.0 op)"
    @test describe(WP0110, identity) == "Vnum{4,0}(2.0 ex)"
    @test describe(WP0111, identity) == "Vnum{4,0}(2.0 op → Inf op)"
    @test describe(WP1000, identity) == "Vnum{4,0}(Inf ex)"
    @test describe(WP1001, identity) == "Vnum{4,0}(Inf op → -2.0 op)"
    @test describe(WP1010, identity) == "Vnum{4,0}(-2.0 ex)"
    @test describe(WP1011, identity) == "Vnum{4,0}(-2.0 op → -1.0 op)"
    @test describe(WP1100, identity) == "Vnum{4,0}(-1.0 ex)"
    @test describe(WP1101, identity) == "Vnum{4,0}(-1.0 op → -0.5 op)"
    @test describe(WP1110, identity) == "Vnum{4,0}(-0.5 ex)"
    @test describe(WP1111, identity) == "Vnum{4,0}(-0.5 op → 0.0 op)"

    @test describe(WP0000 → WP0000, identity) == "Valid{4,0}(0.0 ex)"
    @test describe(WP0000 → WP0001, identity) == "Valid{4,0}(0.0 ex → 0.5 op)"
    @test describe(WP0000 → WP0010, identity) == "Valid{4,0}(0.0 ex → 0.5 ex)"
    @test describe(WP0000 → WP0011, identity) == "Valid{4,0}(0.0 ex → 1.0 op)"
    @test describe(WP0000 → WP0100, identity) == "Valid{4,0}(0.0 ex → 1.0 ex)"
    @test describe(WP0000 → WP0101, identity) == "Valid{4,0}(0.0 ex → 2.0 op)"
    @test describe(WP0000 → WP0110, identity) == "Valid{4,0}(0.0 ex → 2.0 ex)"
    @test describe(WP0000 → WP0111, identity) == "Valid{4,0}(ℝ(+))"
    @test describe(WP0000 → WP1000, identity) == "Valid{4,0}(0.0 ex → Inf ex)"

    @test describe(WP0001 → WP0001, identity) == "Valid{4,0}(0.0 op → 0.5 op)"
    @test describe(WP0001 → WP0010, identity) == "Valid{4,0}(0.0 op → 0.5 ex)"
    @test describe(WP0001 → WP0011, identity) == "Valid{4,0}(0.0 op → 1.0 op)"
    @test describe(WP0001 → WP0100, identity) == "Valid{4,0}(0.0 op → 1.0 ex)"
    @test describe(WP0001 → WP0101, identity) == "Valid{4,0}(0.0 op → 2.0 op)"
    @test describe(WP0001 → WP0110, identity) == "Valid{4,0}(0.0 op → 2.0 ex)"
    @test describe(WP0001 → WP0111, identity) == "Valid{4,0}(ℝ(+*))"
    @test describe(WP0001 → WP1000, identity) == "Valid{4,0}(0.0 op → Inf ex)"
end

#special symbols
@testset "h-layer special check" begin
    @test describe(WP1001 → WP0000, identity) == "Valid{4,0}(ℝ(-))"
    @test describe(WP1001 → WP1111, identity) == "Valid{4,0}(ℝ(-*))"
    @test describe(WP0000 → WP0111, identity) == "Valid{4,0}(ℝ(+))"
    @test describe(WP0001 → WP0111, identity) == "Valid{4,0}(ℝ(+*))"
    @test describe(WP1001 → WP0111, identity) == "Valid{4,0}(ℝ)"
    @test describe(WP1000 → WP0111, identity) == "Valid{4,0}(ℝp)"
    @test describe(WP0000 → WP1111, identity) == "Valid{4,0}(∅)"
    @test describe(WP0001 → WP0000, identity) == "Valid{4,0}(∅)"
end
