
@testset "warlpiri-division" begin

  #comprehensive negative distribution testset
  for a in WP, b in WP, c in WP, d in WP
      #println("testing $a → $b, $c → $d")
      @test -((a → b) / (c → d)) == ((-(a → b)) / (c → d))
      @test -((a → b) / (c → d)) == ((a → b) / (-(c → d)))
      @test ((a → b) / (c → d)) == ((-(a → b)) / (-(c → d)))
  end

  const warlpiri_div_matrix = [
   #W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W2_2 W2_3 W2_4 W2_5 W2_6 W2_7 W2_8   W3_3 W3_4 W3_5 W3_6 W3_7 W3_8   W4_4 W4_5 W4_6 W4_7 W4_8   W5_5 W5_6 W5_7 W5_8   W6_6 W6_7 W6_8   W7_7 W7_8   W8_8
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0   W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0   W0_0 W0_0 W0_0 W0_0 W0_0 W0_0   W0_0 W0_0 W0_0 W0_0 W0_0   W0_0 W0_0 W0_0 W0_0   W0_0 W0_0 W0_0   W0_0 W0_0   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_3 W0_3 W0_3 W0_3 W0_3 W0_3 W0_3   W0_3 W0_3 W0_3 W0_3 W0_3 W0_3   W0_1 W0_1 W0_1 W0_1 W0_1   W0_1 W0_1 W0_1 W0_1   W0_1 W0_1 W0_1   W0_1 W0_1   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_4 W0_4 W0_4 W0_4 W0_4 W0_4 W0_4   W0_3 W0_3 W0_3 W0_3 W0_3 W0_3   W0_2 W0_2 W0_2 W0_2 W0_2   W0_1 W0_1 W0_1 W0_1   W0_1 W0_1 W0_1   W0_1 W0_1   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_5 W0_5 W0_5 W0_5 W0_5 W0_5 W0_5   W0_5 W0_5 W0_5 W0_5 W0_5 W0_5   W0_3 W0_3 W0_3 W0_3 W0_3   W0_3 W0_3 W0_3 W0_3   W0_1 W0_1 W0_1   W0_1 W0_1   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_6 W0_6 W0_6 W0_6 W0_6 W0_6 W0_6   W0_5 W0_5 W0_5 W0_5 W0_5 W0_5   W0_4 W0_4 W0_4 W0_4 W0_4   W0_3 W0_3 W0_3 W0_3   W0_2 W0_2 W0_2   W0_1 W0_1   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_5 W0_5 W0_5 W0_5 W0_5   W0_5 W0_5 W0_5 W0_5   W0_3 W0_3 W0_3   W0_3 W0_3   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_6 W0_6 W0_6 W0_6 W0_6   W0_5 W0_5 W0_5 W0_5   W0_4 W0_4 W0_4   W0_3 W0_3   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7 W0_7   W0_7 W0_7 W0_7   W0_7 W0_7   W0_0 # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 WALL   W0_8 W0_8 WALL   W0_8 WALL   WALL # * W0_0

    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_3 W1_3 W1_3 W1_3 W1_3 W1_3 W0_3   W1_3 W1_3 W1_3 W1_3 W1_3 W0_3   W1_1 W1_1 W1_1 W1_1 W0_1   W1_1 W1_1 W1_1 W0_1   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # 8 W1_1
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_4 W1_4 W1_4 W1_4 W1_4 W1_4 W0_4   W1_3 W1_3 W1_3 W1_3 W1_3 W0_3   W1_2 W1_2 W1_2 W1_2 W0_2   W1_1 W1_1 W1_1 W0_1   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # 8 W1_2
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_5 W1_5 W1_5 W1_5 W1_5 W1_5 W0_5   W1_5 W1_5 W1_5 W1_5 W1_5 W0_5   W1_3 W1_3 W1_3 W1_3 W0_3   W1_3 W1_3 W1_3 W0_3   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # 8 W1_3
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_6 W1_6 W1_6 W1_6 W1_6 W1_6 W0_6   W1_5 W1_5 W1_5 W1_5 W1_5 W0_5   W1_4 W1_4 W1_4 W1_4 W0_4   W1_3 W1_3 W1_3 W0_3   W1_2 W1_2 W0_2   W1_1 W0_1   W0_0 # 8 W1_4
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_5 W1_5 W1_5 W1_5 W0_5   W1_5 W1_5 W1_5 W0_5   W1_3 W1_3 W0_3   W1_3 W0_3   W0_0 # 8 W1_5
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_6 W1_6 W1_6 W1_6 W0_6   W1_5 W1_5 W1_5 W0_5   W1_4 W1_4 W0_4   W1_3 W0_3   W0_0 # 8 W1_6
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W0_7   W1_7 W0_7   W0_0 # 8 W1_7
    W8_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 WALL   W1_8 W1_8 WALL   W1_8 WALL   WALL # 8 W1_8

    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_4 W3_4 W2_4 W1_4 W1_4 W1_4 W0_4   W3_3 W2_3 W1_3 W1_3 W1_3 W0_3   W2_2 W1_2 W1_2 W1_2 W0_2   W1_1 W1_1 W1_1 W0_1   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # * W2_2
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_5 W3_5 W2_5 W1_5 W1_5 W1_5 W0_5   W3_5 W2_5 W1_5 W1_5 W1_5 W0_5   W2_3 W1_3 W1_3 W1_3 W0_3   W1_3 W1_3 W1_3 W0_3   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # * W2_3
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_6 W3_6 W2_6 W1_6 W1_6 W1_6 W0_6   W3_5 W2_5 W1_5 W1_5 W1_5 W0_5   W2_4 W1_4 W1_4 W1_4 W0_4   W1_3 W1_3 W1_3 W0_3   W1_2 W1_2 W0_2   W1_1 W0_1   W0_0 # * W2_4
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W2_5 W1_5 W1_5 W1_5 W0_5   W1_5 W1_5 W1_5 W0_5   W1_3 W1_3 W0_3   W1_3 W0_3   W0_0 # * W2_5
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W2_6 W1_6 W1_6 W1_6 W0_6   W1_5 W1_5 W1_5 W0_5   W1_4 W1_4 W0_4   W1_3 W0_3   W0_0 # * W2_6
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 W0_8   W5_7 W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W4_7 W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W3_7 W2_7 W1_7 W1_7 W1_7 W0_7   W2_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W2_7
    W8_8 W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 WALL   W5_8 W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 WALL   W4_8 W3_8 W2_8 W1_8 W1_8 W1_8 WALL   W3_8 W2_8 W1_8 W1_8 W1_8 WALL   W2_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 WALL   W1_8 W1_8 WALL   W1_8 WALL   WALL # * W2_8

    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 W0_8   W5_7 W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W5_5 W3_5 W3_5 W1_5 W1_5 W1_5 W0_5   W3_5 W3_5 W1_5 W1_5 W1_5 W0_5   W3_3 W1_3 W1_3 W1_3 W0_3   W1_3 W1_3 W1_3 W0_3   W1_1 W1_1 W0_1   W1_1 W0_1   W0_0 # * W3_3
    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 W0_8   W5_7 W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W5_6 W3_6 W3_6 W1_6 W1_6 W1_6 W0_6   W3_5 W3_5 W1_5 W1_5 W1_5 W0_5   W3_4 W1_4 W1_4 W1_4 W0_4   W1_3 W1_3 W1_3 W0_3   W1_2 W1_2 W0_2   W1_1 W0_1   W0_0 # * W3_4
    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 W0_8   W5_7 W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_5 W1_5 W1_5 W1_5 W0_5   W1_5 W1_5 W1_5 W0_5   W1_3 W1_3 W0_3   W1_3 W0_3   W0_0 # * W3_5
    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 W0_8   W5_7 W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_6 W1_6 W1_6 W1_6 W0_6   W1_5 W1_5 W1_5 W0_5   W1_4 W1_4 W0_4   W1_3 W0_3   W0_0 # * W3_6
    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 W0_8   W5_7 W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W5_7 W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_7 W3_7 W1_7 W1_7 W1_7 W0_7   W3_7 W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W1_7 W0_7   W1_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W3_7
    W8_8 W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 WALL   W5_8 W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 WALL   W5_8 W3_8 W3_8 W1_8 W1_8 W1_8 WALL   W3_8 W3_8 W1_8 W1_8 W1_8 WALL   W3_8 W1_8 W1_8 W1_8 WALL   W1_8 W1_8 W1_8 WALL   W1_8 W1_8 WALL   W1_8 WALL   WALL # * W3_8

    W8_8 W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 W0_8   W7_7 W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W6_6 W5_6 W4_6 W3_6 W2_6 W1_6 W0_6   W5_5 W4_5 W3_5 W2_5 W1_5 W0_5   W4_4 W3_4 W2_4 W1_4 W0_4   W3_3 W2_3 W1_3 W0_3   W2_2 W1_2 W0_2   W1_1 W0_1   W0_0 # * W4_4
    W8_8 W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 W0_8   W7_7 W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W4_5 W3_5 W2_5 W1_5 W0_5   W3_5 W2_5 W1_5 W0_5   W2_3 W1_3 W0_3   W1_3 W0_3   W0_0 # * W4_5
    W8_8 W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 W0_8   W7_7 W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W4_6 W3_6 W2_6 W1_6 W0_6   W3_5 W2_5 W1_5 W0_5   W2_4 W1_4 W0_4   W1_3 W0_3   W0_0 # * W4_6
    W8_8 W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 W0_8   W7_7 W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W6_7 W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W5_7 W4_7 W3_7 W2_7 W1_7 W0_7   W4_7 W3_7 W2_7 W1_7 W0_7   W3_7 W2_7 W1_7 W0_7   W2_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W4_7
    W8_8 W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 WALL   W7_8 W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 WALL   W6_8 W5_8 W4_8 W3_8 W2_8 W1_8 WALL   W5_8 W4_8 W3_8 W2_8 W1_8 WALL   W4_8 W3_8 W2_8 W1_8 WALL   W3_8 W2_8 W1_8 WALL   W2_8 W1_8 WALL   W1_8 WALL   WALL # * W4_8

    W8_8 W7_8 W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 W0_8   W7_7 W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_5 W3_5 W3_5 W1_5 W0_5   W3_5 W3_5 W1_5 W0_5   W3_3 W1_3 W0_3   W1_3 W0_3   W0_0 # * W5_5
    W8_8 W7_8 W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 W0_8   W7_7 W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_6 W3_6 W3_6 W1_6 W0_6   W3_5 W3_5 W1_5 W0_5   W3_4 W1_4 W0_4   W1_3 W0_3   W0_0 # * W5_6
    W8_8 W7_8 W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 W0_8   W7_7 W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W7_7 W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_7 W5_7 W3_7 W3_7 W1_7 W0_7   W5_7 W3_7 W3_7 W1_7 W0_7   W3_7 W3_7 W1_7 W0_7   W3_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W5_7
    W8_8 W7_8 W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 WALL   W7_8 W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 WALL   W7_8 W5_8 W5_8 W3_8 W3_8 W1_8 WALL   W5_8 W5_8 W3_8 W3_8 W1_8 WALL   W5_8 W3_8 W3_8 W1_8 WALL   W3_8 W3_8 W1_8 WALL   W3_8 W1_8 WALL   W1_8 WALL   WALL # * W5_8

    W8_8 W7_8 W7_8 W7_8 W6_8 W5_8 W4_8 W1_8 W0_8   W7_7 W7_7 W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W7_7 W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W6_6 W5_6 W4_6 W1_6 W0_6   W5_5 W4_5 W1_5 W0_5   W4_4 W1_4 W0_4   W1_3 W0_3   W0_0 # * W6_6
    W8_8 W7_8 W7_8 W7_8 W6_8 W5_8 W4_8 W1_8 W0_8   W7_7 W7_7 W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W7_7 W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W7_7 W6_7 W5_7 W4_7 W1_7 W0_7   W6_7 W5_7 W4_7 W1_7 W0_7   W5_7 W4_7 W1_7 W0_7   W4_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W6_7
    W8_8 W7_8 W7_8 W7_8 W6_8 W5_8 W4_8 W1_8 WALL   W7_8 W7_8 W7_8 W6_8 W5_8 W4_8 W1_8 WALL   W7_8 W7_8 W6_8 W5_8 W4_8 W1_8 WALL   W7_8 W6_8 W5_8 W4_8 W1_8 WALL   W6_8 W5_8 W4_8 W1_8 WALL   W5_8 W4_8 W1_8 WALL   W4_8 W1_8 WALL   W1_8 WALL   WALL # * W6_8

    W8_8 W7_8 W7_8 W7_8 W7_8 W5_8 W5_8 W1_8 W0_8   W7_7 W7_7 W7_7 W7_7 W5_7 W5_7 W1_7 W0_7   W7_7 W7_7 W7_7 W5_7 W5_7 W1_7 W0_7   W7_7 W7_7 W5_7 W5_7 W1_7 W0_7   W7_7 W5_7 W5_7 W1_7 W0_7   W5_7 W5_7 W1_7 W0_7   W5_7 W1_7 W0_7   W1_7 W0_7   W0_0 # * W7_7
    W8_8 W7_8 W7_8 W7_8 W7_8 W5_8 W5_8 W1_8 WALL   W7_8 W7_8 W7_8 W7_8 W5_8 W5_8 W1_8 WALL   W7_8 W7_8 W7_8 W5_8 W5_8 W1_8 WALL   W7_8 W7_8 W5_8 W5_8 W1_8 WALL   W7_8 W5_8 W5_8 W1_8 WALL   W5_8 W5_8 W1_8 WALL   W5_8 W1_8 WALL   W1_8 WALL   WALL # * W7_8

    W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 WALL   W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 WALL   W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 WALL   W8_8 W8_8 W8_8 W8_8 W8_8 WALL   W8_8 W8_8 W8_8 W8_8 WALL   W8_8 W8_8 W8_8 WALL   W8_8 W8_8 WALL   W8_8 WALL   WALL # * W8_8
    ]

    warlpiri_div_test_matrix = [a / b for a in pos_warlpiri, b in pos_warlpiri]
    warlpiri_label_matrix = [(a, b) for a in pos_warlpiri, b in pos_warlpiri]

    for (expected, evaluated, l) in zip(warlpiri_div_matrix, warlpiri_div_test_matrix, warlpiri_label_matrix)
        #println(l)
        @test (expected, l) == (evaluated, l)
    end

    #next, test values when dividing by something which goes "round the
    #zero"... We'll use the interval (-1, 1], which is representable as 0b1101
    #-> 0b1100

    WRTZ = WP1101 → WP0100
    warlpiri_div_rtz_values = [
    WP1000 → WP0111, #WP0000 → WP0000   0 / (-1, 1] = all reals
    WP1000 → WP0111, #WP0000 → WP0001
    WP1000 → WP0111, #WP0000 → WP0010
    WP1000 → WP0111, #WP0000 → WP0011
    WP1000 → WP0111, #WP0000 → WP0100
    WP1000 → WP0111, #WP0000 → WP0101
    WP1000 → WP0111, #WP0000 → WP0110
    WP1000 → WP0111, #WP0000 → WP0111
    WP1000 → WP0111, #WP0000 → WP1000

    WP0001 → WP1111, #WP0001 → WP0001  0->0.5... / (-1,1] = all but zero.
    WP0001 → WP1111, #WP0001 → WP0010
    WP0001 → WP1111, #WP0001 → WP0011
    WP0001 → WP1111, #WP0001 → WP0100
    WP0001 → WP1111, #WP0001 → WP0101
    WP0001 → WP1111, #WP0001 → WP0110
    WP0001 → WP1111, #WP0001 → WP0111
    WP0001 → WP1111, #WP0001 → WP1000

    WP0010 → WP1101, #WP0010 → WP0010  0.5... / (-1, 1] = [0.5, -0.5)
    WP0010 → WP1101, #WP0010 → WP0011
    WP0010 → WP1101, #WP0010 → WP0100
    WP0010 → WP1101, #WP0010 → WP0101
    WP0010 → WP1101, #WP0010 → WP0110
    WP0010 → WP1101, #WP0010 → WP0111
    WP0010 → WP1101, #WP0010 → WP1000

    WP0011 → WP1101, #WP0011 → WP0011  (0.5... / (-1, 1] = (0.5, -0.5)
    WP0011 → WP1101, #WP0011 → WP0100
    WP0011 → WP1101, #WP0011 → WP0101
    WP0011 → WP1101, #WP0011 → WP0110
    WP0011 → WP1101, #WP0011 → WP0111
    WP0011 → WP1101, #WP0011 → WP1000

    WP0100 → WP1011, #WP0100 → WP0100  1... / (-1, 1] = [1, -1)
    WP0100 → WP1011, #WP0100 → WP0101
    WP0100 → WP1011, #WP0100 → WP0110
    WP0100 → WP1011, #WP0100 → WP0111
    WP0100 → WP1011, #WP0100 → WP1000

    WP0101 → WP1011, #WP0101 → WP0101  (1... / (-1, 1] = (1, -1)
    WP0101 → WP1011, #WP0101 → WP0110
    WP0101 → WP1011, #WP0101 → WP0111
    WP0101 → WP1011, #WP0101 → WP1000

    WP0110 → WP1001, #WP0110 → WP0110  [2... / (-1, 1] = [2, -2)
    WP0110 → WP1001, #WP0110 → WP0111
    WP0110 → WP1001, #WP0110 → WP1000

    WP0111 → WP1001, #WP0111 → WP0111  (2... / (-1, 1] = (2, -2)
    WP0111 → WP1001, #WP0111 → WP1000

    WP1000 → WP1000, #WP1000 → WP1000
    ]

    for (a,b) in zip(warlpiri_div_rtz_values,pos_warlpiri)
        @test (a, b) == (b / WRTZ, b)
    end

    #next, test values when dividing from something which goes "round the
    #zero"... We'll use the interval (-1, 1], which is representable as 0b1101
    #-> 0b1100

    warlpiri_rtz_div_values = [
    WP1000 → WP0111, #WP0000 → WP0000   (-1, 1] / 0 = all reals
    WP1000 → WP0111, #WP0000 → WP0001
    WP1000 → WP0111, #WP0000 → WP0010
    WP1000 → WP0111, #WP0000 → WP0011
    WP1000 → WP0111, #WP0000 → WP0100
    WP1000 → WP0111, #WP0000 → WP0101
    WP1000 → WP0111, #WP0000 → WP0110
    WP1000 → WP0111, #WP0000 → WP0111
    WP1000 → WP0111, #WP0000 → WP1000

    WP1001 → WP0111, #WP0001 → WP0001  (-1,1] / (0... = all but inf.
    WP1001 → WP0111, #WP0001 → WP0010
    WP1001 → WP0111, #WP0001 → WP0011
    WP1001 → WP0111, #WP0001 → WP0100
    WP1001 → WP0111, #WP0001 → WP0101
    WP1001 → WP0111, #WP0001 → WP0110
    WP1001 → WP0111, #WP0001 → WP0111
    WP1001 → WP0111, #WP0001 → WP1000

    WP1011 → WP0110, #WP0010 → WP0010  (-1, 1] / [0.5... = (-2, 2]
    WP1011 → WP0110, #WP0010 → WP0011
    WP1011 → WP0110, #WP0010 → WP0100
    WP1011 → WP0110, #WP0010 → WP0101
    WP1011 → WP0110, #WP0010 → WP0110
    WP1011 → WP0110, #WP0010 → WP0111
    WP1011 → WP0110, #WP0010 → WP1000

    WP1011 → WP0101, #WP0011 → WP0011  (-1, 1] / (0.5... = (-2, 2)
    WP1011 → WP0101, #WP0011 → WP0100
    WP1011 → WP0101, #WP0011 → WP0101
    WP1011 → WP0101, #WP0011 → WP0110
    WP1011 → WP0101, #WP0011 → WP0111
    WP1011 → WP0101, #WP0011 → WP1000

    WP1101 → WP0100, #WP0100 → WP0100  (-1, 1] / [1... = (-1, 1]
    WP1101 → WP0100, #WP0100 → WP0101
    WP1101 → WP0100, #WP0100 → WP0110
    WP1101 → WP0100, #WP0100 → WP0111
    WP1101 → WP0100, #WP0100 → WP1000

    WP1101 → WP0011, #WP0101 → WP0101  (-1, 1] / (1... = (-1, 1)
    WP1101 → WP0011, #WP0101 → WP0110
    WP1101 → WP0011, #WP0101 → WP0111
    WP1101 → WP0011, #WP0101 → WP1000

    WP1111 → WP0010, #WP0110 → WP0110  (-1, 1] / [2... = (0.5, -0.5]
    WP1111 → WP0010, #WP0110 → WP0111
    WP1111 → WP0010, #WP0110 → WP1000

    WP1111 → WP0001, #WP0111 → WP0111  (-1, 1] / (2.. = (0.5, -0.5)
    WP1111 → WP0001, #WP0111 → WP1000

    WP0000 → WP0000, #WP1000 → WP1000  (-1, 1] / Inf = 0
    ]

    for (a,b) in zip(warlpiri_rtz_div_values,pos_warlpiri)
        @test (a, b) == (WRTZ / b, b)
    end

    #test two rounding-zero
    @test (WP1110 → WP0001) / (WP1010 → WP0101) == (WP1001 → WP1000)

    #test dividing by a plain rounding-infinity [1, -1)
    WRTI = WP0100 → WP1011

    warlpiri_div_rti_values = [
    WP0000 → WP0000, #WP0000 → WP0000  0       / [1, -1) = 0
    WP1111 → WP0001, #WP0000 → WP0001  [0, 0.5) / [1, -1) = (-0.5, 0.5)
    WP1111 → WP0010, #WP0000 → WP0010  [0, 0.5] / [1, -1) = (-0.5, 0.5]
    WP1101 → WP0011, #WP0000 → WP0011  [0,   1) / [1, -1) = (-1,     1)
    WP1101 → WP0100, #WP0000 → WP0100  [0,   1] / [1, -1) = (-1,     1]
    WP1011 → WP0101, #WP0000 → WP0101  [0,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0000 → WP0110  [0,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0000 → WP0111  [0, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0000 → WP1000  [0, Inf] / [1, -1) = allreals

    WP1111 → WP0001, #WP0001 → WP0001  (0, 0.5) / [1, -1) = (-0.5, 0.5)
    WP1111 → WP0010, #WP0001 → WP0010  (0, 0.5] / [1, -1) = (-0.5, 0.5]
    WP1101 → WP0011, #WP0001 → WP0011  (0,   1) / [1, -1) = (-1,     1)
    WP1101 → WP0100, #WP0001 → WP0100  (0,   1] / [1, -1) = (-1,     1]
    WP1011 → WP0101, #WP0001 → WP0101  (0,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0001 → WP0110  (0,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0001 → WP0111  (0, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0001 → WP1000  (0, Inf] / [1, -1) = allreals

    WP1111 → WP0010, #WP0010 → WP0010  0.5        / [1, -1) = (-0.5, 0.5]
    WP1101 → WP0011, #WP0010 → WP0011  [0.5,   1) / [1, -1) = (-1,     1)
    WP1101 → WP0100, #WP0010 → WP0100  [0.5,   1] / [1, -1) = (-1,     1]
    WP1011 → WP0101, #WP0010 → WP0101  [0.5,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0010 → WP0110  [0.5,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0010 → WP0111  [0.5, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0010 → WP1000  [0.5, Inf] / [1, -1) = allreals

    WP1101 → WP0011, #WP0011 → WP0011  (0.5,   1) / [1, -1) = (-1,     1)
    WP1101 → WP0100, #WP0011 → WP0100  (0.5,   1] / [1, -1) = (-1,     1]
    WP1011 → WP0101, #WP0011 → WP0101  (0.5,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0011 → WP0110  (0.5,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0011 → WP0111  (0.5, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0011 → WP1000  (0.5, Inf] / [1, -1) = allreals

    WP1101 → WP0100, #WP0100 → WP0100  1        / [1, -1) = (-1,     1]
    WP1011 → WP0101, #WP0100 → WP0101  [1,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0100 → WP0110  [1,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0100 → WP0111  [1, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0100 → WP1000  [1, Inf] / [1, -1) = allreals

    WP1011 → WP0101, #WP0101 → WP0101  (1,   2) / [1, -1) = (-2,     2)
    WP1011 → WP0110, #WP0101 → WP0110  (1,   2] / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0101 → WP0111  (1, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0101 → WP1000  (1, Inf] / [1, -1) = allreals

    WP1011 → WP0110, #WP0110 → WP0110  2        / [1, -1) = (-2,     2]
    WP1001 → WP0111, #WP0110 → WP0111  [2, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0110 → WP1000  [2, Inf] / [1, -1) = allreals

    WP1001 → WP0111, #WP0111 → WP0111  (2, Inf) / [1, -1) = (-Inf, Inf)
    WP1001 → WP1000, #WP0111 → WP1000  (2, Inf] / [1, -1) = allreals

    WP1001 → WP1000, #WP1000 → WP1000  Inf / [1, -1) = allreals
    ]

    for (a,b) in zip(warlpiri_div_rti_values,pos_warlpiri)
        @test (a, b) == (b / WRTI, b)
    end

    #test dividing a rounding-inifinity
    warlpiri_rti_div_values = [
    WP1000 → WP1000, #WP0000 → WP0000  [1, -1) / 0         = Inf
    WP0111 → WP1001, #WP0000 → WP0001  [1, -1) / [0, 0.5)  = (2,     -2)
    WP0110 → WP1001, #WP0000 → WP0010  [1, -1) / [0, 0.5]  = [2,     -2)
    WP0101 → WP1011, #WP0000 → WP0011  [1, -1) / [0,   1)  = (1,     -1)
    WP0100 → WP1011, #WP0000 → WP0100  [1, -1) / [0,   1]  = [1,     -1)
    WP0011 → WP1101, #WP0000 → WP0101  [1, -1) / [0,   2)  = (0.5, -0.5)
    WP0010 → WP1101, #WP0000 → WP0110  [1, -1) / [0,   2]  = [0.5, -0.5)
    WP0001 → WP1111, #WP0000 → WP0111  [1, -1) / [0, Inf)  = allreals*
    WP1001 → WP1000, #WP0000 → WP1000  [1, -1) / [0, Inf]  = allreals

    WP0111 → WP1001, #WP0001 → WP0001  [1, -1) / (0, 0.5)  = (2,      -2)
    WP0110 → WP1001, #WP0001 → WP0010  [1, -1) / (0, 0.5]  = [2,      -2)
    WP0101 → WP1011, #WP0001 → WP0011  [1, -1) / (0,   1)  = (1,      -1)
    WP0100 → WP1011, #WP0001 → WP0100  [1, -1) / (0,   1]  = [1,      -1)
    WP0011 → WP1101, #WP0001 → WP0101  [1, -1) / (0,   2)  = (0.5, -`0.5)
    WP0010 → WP1101, #WP0001 → WP0110  [1, -1) / (0,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0001 → WP0111  [1, -1) / (0, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0001 → WP1000  [1, -1) / (0, Inf]  = allreal`s

    WP0110 → WP1001, #WP0010 → WP0010  [1, -1) / [0.5, 0.5]  = [2,      -2)
    WP0101 → WP1011, #WP0010 → WP0011  [1, -1) / [0.5,   1)  = (1,      -1)
    WP0100 → WP1011, #WP0010 → WP0100  [1, -1) / [0.5,   1]  = [1,      -1)
    WP0011 → WP1101, #WP0010 → WP0101  [1, -1) / [0.5,   2)  = (0.5, -`0.5)
    WP0010 → WP1101, #WP0010 → WP0110  [1, -1) / [0.5,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0010 → WP0111  [1, -1) / [0.5, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0010 → WP1000  [1, -1) / [0.5, Inf]  = allreal`s

    WP0101 → WP1011, #WP0011 → WP0011  [1, -1) / (0.5,   1)  = (1,      -1)
    WP0100 → WP1011, #WP0011 → WP0100  [1, -1) / (0.5,   1]  = [1,      -1)
    WP0011 → WP1101, #WP0011 → WP0101  [1, -1) / (0.5,   2)  = (0.5, -`0.5)
    WP0010 → WP1101, #WP0011 → WP0110  [1, -1) / (0.5,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0011 → WP0111  [1, -1) / (0.5, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0011 → WP1000  [1, -1) / (0.5, Inf]  = allreal`s

    WP0100 → WP1011, #WP0100 → WP0100  [1, -1) / [1,   1]  = [1,      -1)
    WP0011 → WP1101, #WP0100 → WP0101  [1, -1) / [1,   2)  = (0.5, -`0.5)
    WP0010 → WP1101, #WP0100 → WP0110  [1, -1) / [1,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0100 → WP0111  [1, -1) / [1, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0100 → WP1000  [1, -1) / [1, Inf]  = allreal`s

    WP0011 → WP1101, #WP0101 → WP0101  [1, -1) / (1,   2)  = (0.5, -`0.5)
    WP0010 → WP1101, #WP0101 → WP0110  [1, -1) / (1,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0101 → WP0111  [1, -1) / (1, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0101 → WP1000  [1, -1) / (1, Inf]  = allreal`s

    WP0010 → WP1101, #WP0101 → WP0110  [1, -1) / [2,   2]  = (0.5, -`0.5)
    WP0001 → WP1111, #WP0101 → WP0111  [1, -1) / [2, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0101 → WP1000  [1, -1) / [2, Inf]  = allreal`s

    WP0001 → WP1111, #WP0111 → WP0111  [1, -1) / (2, Inf)  = allreal`s*
    WP1001 → WP1000, #WP0111 → WP1000  [1, -1) / (2, Inf]  = allreal`s

    WP1001 → WP1000, #WP1000 → WP1000  [1, -1) / Inf = allreals
    ]

    for (a,b) in zip(warlpiri_rti_div_values,pos_warlpiri)
        @test (a, b) == (WRTI / b, b)
    end

    #test dividing by values that round both zero and infinity...  In this  case (2, 0.5]
    #values copied straight from multiplication with [2, 0.5)
    WRTB = WP0111 → WP0010

    warlpiri_div_rtb_values = [
    WP1001 → WP1000, #WP0000 → WP0000  #anything that contains zero will trigger all reals.
    WP1001 → WP1000, #WP0000 → WP0001
    WP1001 → WP1000, #WP0000 → WP0010
    WP1001 → WP1000, #WP0000 → WP0011
    WP1001 → WP1000, #WP0000 → WP0100
    WP1001 → WP1000, #WP0000 → WP0101
    WP1001 → WP1000, #WP0000 → WP0110
    WP1001 → WP1000, #WP0000 → WP0111
    WP1001 → WP1000, #WP0000 → WP1000

    WP1001 → WP1000, #WP0001 → WP0001
    WP1001 → WP1000, #WP0001 → WP0010
    WP1001 → WP1000, #WP0001 → WP0011
    WP1001 → WP1000, #WP0001 → WP0100
    WP1001 → WP1000, #WP0001 → WP0101
    WP1001 → WP1000, #WP0001 → WP0110
    WP1001 → WP1000, #WP0001 → WP0111
    WP1001 → WP1000, #WP0001 → WP1000

    WP0100 → WP0001, #WP0010 → WP0010
    WP0100 → WP0001, #WP0010 → WP0011
    WP0100 → WP0001, #WP0010 → WP0100
    WP1001 → WP1000, #WP0010 → WP0101
    WP1001 → WP1000, #WP0010 → WP0110
    WP1001 → WP1000, #WP0010 → WP0111
    WP1001 → WP1000, #WP0010 → WP1000

    WP0101 → WP0001, #WP0011 → WP0011
    WP0101 → WP0001, #WP0011 → WP0100
    WP0101 → WP0011, #WP0011 → WP0101
    WP0101 → WP0011, #WP0011 → WP0110
    WP1001 → WP1000, #WP0011 → WP0111
    WP1001 → WP1000, #WP0011 → WP1000

    WP0110 → WP0001, #WP0100 → WP0100
    WP0110 → WP0011, #WP0100 → WP0101
    WP0110 → WP0011, #WP0100 → WP0110
    WP1001 → WP1000, #WP0100 → WP0111
    WP1001 → WP1000, #WP0100 → WP1000

    WP0111 → WP0011, #WP0101 → WP0101
    WP0111 → WP0011, #WP0101 → WP0110
    WP1001 → WP1000, #WP0101 → WP0111
    WP1001 → WP1000, #WP0101 → WP1000

    WP0111 → WP0011, #WP0110 → WP0110
    WP1001 → WP1000, #WP0110 → WP0111
    WP1001 → WP1000, #WP0110 → WP1000

    WP1001 → WP1000, #WP0111 → WP0111
    WP1001 → WP1000, #WP0111 → WP1000

    WP1001 → WP1000, #WP1000 → WP1000
    ]

    for (a,b) in zip(warlpiri_div_rtb_values,pos_warlpiri)
        @test (a, b) == (b / WRTB, b)
    end

    #test dividing values that round both zero and infinity...  In this  case (2, 0.5]

    warlpiri_rtb_div_values = [
    WP1001 → WP1000, #WP0000 → WP0000  #anything that contains zero will trigger all reals.
    WP1001 → WP1000, #WP0000 → WP0001
    WP1001 → WP1000, #WP0000 → WP0010
    WP1001 → WP1000, #WP0000 → WP0011
    WP1001 → WP1000, #WP0000 → WP0100
    WP1001 → WP1000, #WP0000 → WP0101
    WP1001 → WP1000, #WP0000 → WP0110
    WP1001 → WP1000, #WP0000 → WP0111
    WP1001 → WP1000, #WP0000 → WP1000

    WP1001 → WP1000, #WP0001 → WP0001  (2, 0.5] / (0, 0.5) = allreals
    WP1001 → WP1000, #WP0001 → WP0010
    WP1001 → WP1000, #WP0001 → WP0011
    WP1001 → WP1000, #WP0001 → WP0100
    WP1001 → WP1000, #WP0001 → WP0101
    WP1001 → WP1000, #WP0001 → WP0110
    WP1001 → WP1000, #WP0001 → WP0111
    WP1001 → WP1000, #WP0001 → WP1000

    WP0111 → WP0100, #WP0010 → WP0010  (2, 0.5] / 0.5 = (2, 1]
    WP0111 → WP0100, #WP0010 → WP0011  (2, 0.5] / [0.5, 1) = (2, 1]
    WP0111 → WP0100, #WP0010 → WP0100  (2, 0.5] / [0.5, 1] = (2, 1]
    WP1001 → WP1000, #WP0010 → WP0101  (2, 0.5] / [0.5, 2) = allreals
    WP1001 → WP1000, #WP0010 → WP0110
    WP1001 → WP1000, #WP0010 → WP0111
    WP1001 → WP1000, #WP0010 → WP1000

    WP0111 → WP0011, #WP0011 → WP0011  (2, 0.5] / (0.5, 1) = (2, 1)
    WP0111 → WP0011, #WP0011 → WP0100  (2, 0.5] / (0.5, 1] = (2, 1)
    WP0101 → WP0011, #WP0011 → WP0101  (2, 0.5] / (0.5, 2) = (not 1)
    WP0101 → WP0011, #WP0011 → WP0110  (2, 0.5] / (0.5, 2] = (not 1)
    WP1001 → WP1000, #WP0011 → WP0111
    WP1001 → WP1000, #WP0011 → WP1000

    WP0111 → WP0010, #WP0100 → WP0100  (2, 0.5] / 1        = (2, 0.5]
    WP0101 → WP0010, #WP0100 → WP0101  (2, 0.5] / [1,   2) = (1, 0.5]
    WP0101 → WP0010, #WP0100 → WP0110  (2, 0.5] / [1,   2] = (1, 0.5]
    WP1001 → WP1000, #WP0100 → WP0111  (2, 0.5] / [1, Inf) = allreals
    WP1001 → WP1000, #WP0100 → WP1000

    WP0101 → WP0001, #WP0101 → WP0101  (2, 0.5] / (1,   2) = (1, 0.5)
    WP0101 → WP0001, #WP0101 → WP0110  (2, 0.5] / (1,   2] = (1, 0.5)
    WP1001 → WP1000, #WP0101 → WP0111  (2, 0.5] / (1, Inf) = allreals
    WP1001 → WP1000, #WP0101 → WP1000

    WP0101 → WP0001, #WP0110 → WP0110  (2, 0.5] / 2        = (1, 0.5)
    WP1001 → WP1000, #WP0110 → WP0111  (2, 0.5] / (2, Inf) = allreals
    WP1001 → WP1000, #WP0110 → WP1000

    WP1001 → WP1000, #WP0111 → WP0111
    WP1001 → WP1000, #WP0111 → WP1000

    WP1001 → WP1000, #WP1000 → WP1000
    ]

    for (a,b) in zip(warlpiri_rtb_div_values,pos_warlpiri)
        @test (a, b) == (WRTB / b, b)
    end

    @test (WP1001 → WP1000) == WRTI / WRTB
    @test (WP1001 → WP1000) == WRTZ / WRTB
    @test (WP1001 → WP1000) == WRTB / WRTB

    @test (WP1001 → WP1000) == WRTB / WRTI
    @test (WP1001 → WP1000) == WRTB / WRTZ
    @test (WP1001 → WP1000) == WRTB / WRTB
end
