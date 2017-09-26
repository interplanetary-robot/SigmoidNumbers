@testset "upper/lower recasting" begin
end

@testset "inner/outer recasting" begin
   import SigmoidNumbers: isulp, glb, lub

   @test SigmoidNumbers.@d_lower(WP(0b0010) → WP(0b0100)) == Sigmoid{4,0,:outward_exact}(0b0010)
   @test SigmoidNumbers.@d_lower(WP(0b0011) → WP(0b0100)) == Sigmoid{4,0,:outward_ulp}(0b0010)
   @test SigmoidNumbers.@d_lower(WP(0b1100) → WP(0b1110)) == Sigmoid{4,0,:inward_exact}(0b1100)
   @test SigmoidNumbers.@d_lower(WP(0b1101) → WP(0b1110)) == Sigmoid{4,0,:inward_ulp}(0b1100)
   @test SigmoidNumbers.@d_lower(WP(0b0000) → WP(0b1100)) == Sigmoid{4,0,:outward_exact}(0b0000)
   @test SigmoidNumbers.@d_lower(WP(0b0000) → WP(0b0000)) == Sigmoid{4,0,:inward_exact}(0b0000)
   @test SigmoidNumbers.@d_lower(WP(0b1000) → WP(0b1100)) == Sigmoid{4,0,:inward_exact}(0b1000)
   @test SigmoidNumbers.@d_lower(WP(0b1000) → WP(0b1000)) == Sigmoid{4,0,:outward_exact}(0b1000)

   @test SigmoidNumbers.@d_upper(WP(0b0010) → WP(0b0100)) == Sigmoid{4,0,:inward_exact}(0b0100)
   @test SigmoidNumbers.@d_upper(WP(0b0010) → WP(0b0011)) == Sigmoid{4,0,:inward_ulp}(0b00100)
   @test SigmoidNumbers.@d_upper(WP(0b1100) → WP(0b1110)) == Sigmoid{4,0,:outward_exact}(0b1110)
   @test SigmoidNumbers.@d_upper(WP(0b1100) → WP(0b1101)) == Sigmoid{4,0,:outward_ulp}(0b1110)
   @test SigmoidNumbers.@d_upper(WP(0b1100) → WP(0b0000)) == Sigmoid{4,0,:outward_exact}(0b0000)
   @test SigmoidNumbers.@d_upper(WP(0b0000) → WP(0b0000)) == Sigmoid{4,0,:inward_exact}(0b0000)
   @test SigmoidNumbers.@d_upper(WP(0b0100) → WP(0b1000)) == Sigmoid{4,0,:inward_exact}(0b1000)
   @test SigmoidNumbers.@d_upper(WP(0b1000) → WP(0b1000)) == Sigmoid{4,0,:outward_exact}(0b1000)

   @test SigmoidNumbers.@d_upper(WP(0b1101) → WP(0b0100)) == Sigmoid{4,0,:inward_exact}(0b0100)
end
