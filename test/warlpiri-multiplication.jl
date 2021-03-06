
@testset "warlpiri-multiplication" begin

  #comprehensive commutativity and negative distribution testset
  for a in WP, b in WP, c in WP, d in WP
      @test ((a → b) * (c → d)) == ((c → d) * (a → b))
      @test -((a → b) * (c → d)) == ((-(a → b)) * (c → d))
      @test -((a → b) * (c → d)) == ((a → b) * (-(c → d)))
      @test ((a → b) * (c → d)) == ((-(a → b)) * (-(c → d)))
  end

  const warlpiri_prod_matrix = [
   #W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W2_2 W2_3 W2_4 W2_5 W2_6 W2_7 W2_8   W3_3 W3_4 W3_5 W3_6 W3_7 W3_8   W4_4 W4_5 W4_6 W4_7 W4_8   W5_5 W5_6 W5_7 W5_8   W6_6 W6_7 W6_8   W7_7 W7_8   W8_8
    W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 WALL   W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 WALL   W0_0 W0_0 W0_0 W0_0 W0_0 W0_0 WALL   W0_0 W0_0 W0_0 W0_0 W0_0 WALL   W0_0 W0_0 W0_0 W0_0 WALL   W0_0 W0_0 W0_0 WALL   W0_0 W0_0 WALL   W0_0 WALL   WALL # * W0_0
    W0_0 W0_1 W0_1 W0_1 W0_1 W0_3 W0_3 W0_7 WALL   W0_1 W0_1 W0_1 W0_1 W0_3 W0_3 W0_7 WALL   W0_1 W0_1 W0_1 W0_3 W0_3 W0_7 WALL   W0_1 W0_1 W0_3 W0_3 W0_7 WALL   W0_1 W0_3 W0_3 W0_7 WALL   W0_3 W0_3 W0_7 WALL   W0_3 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_1 W0_1 W0_1 W0_2 W0_3 W0_4 W0_7 WALL   W0_1 W0_1 W0_1 W0_2 W0_3 W0_4 W0_7 WALL   W0_1 W0_1 W0_2 W0_3 W0_4 W0_7 WALL   W0_1 W0_2 W0_3 W0_4 W0_7 WALL   W0_2 W0_3 W0_4 W0_7 WALL   W0_3 W0_4 W0_7 WALL   W0_4 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_1 W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 WALL   W0_1 W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 WALL   W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 WALL   W0_3 W0_3 W0_5 W0_5 W0_7 WALL   W0_3 W0_5 W0_5 W0_7 WALL   W0_5 W0_5 W0_7 WALL   W0_5 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 WALL   W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 WALL   W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 WALL   W0_3 W0_4 W0_5 W0_6 W0_7 WALL   W0_4 W0_5 W0_6 W0_7 WALL   W0_5 W0_6 W0_7 WALL   W0_6 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 WALL   W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 WALL   W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 WALL   W0_5 W0_5 W0_7 W0_7 W0_7 WALL   W0_5 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 WALL   W0_7 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 WALL   W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 WALL   W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 WALL   W0_5 W0_6 W0_7 W0_7 W0_7 WALL   W0_6 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 WALL   W0_7 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 W0_7 WALL   W0_7 W0_7 W0_7 WALL   W0_7 W0_7 WALL   W0_7 WALL   WALL # * W0_0
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 W0_8 WALL   W0_8 W0_8 W0_8 WALL   W0_8 W0_8 WALL   W0_8 WALL   WALL # * W0_0

    W0_0 W0_1 W0_1 W0_1 W0_1 W0_3 W0_3 W0_7 W0_8   W1_1 W1_1 W1_1 W1_1 W1_3 W1_3 W1_7 W1_8   W1_1 W1_1 W1_1 W1_3 W1_3 W1_7 W1_8   W1_1 W1_1 W1_3 W1_3 W1_7 W1_8   W1_1 W1_3 W1_3 W1_7 W1_8   W1_3 W1_3 W1_7 W1_8   W1_3 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_1
    W0_0 W0_1 W0_1 W0_1 W0_2 W0_3 W0_4 W0_7 W0_8   W1_1 W1_1 W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W1_1 W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W1_2 W1_3 W1_4 W1_7 W1_8   W1_3 W1_4 W1_7 W1_8   W1_4 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_2
    W0_0 W0_1 W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 W0_8   W1_1 W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_3 W1_5 W1_5 W1_7 W1_8   W1_5 W1_5 W1_7 W1_8   W1_5 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_3
    W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_4 W1_5 W1_6 W1_7 W1_8   W1_5 W1_6 W1_7 W1_8   W1_6 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_4
    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 W0_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_5 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_5
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_6 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_8   W1_7 W1_8   W8_8 # 8 W1_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8   W1_8 W1_8   W8_8 # 8 W1_8

    W0_0 W0_1 W0_1 W0_1 W0_2 W0_3 W0_4 W0_7 W0_8   W1_1 W1_1 W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W1_1 W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W1_1 W1_2 W1_3 W1_4 W1_7 W1_8   W2_2 W2_3 W2_4 W2_7 W2_8   W3_3 W3_4 W3_7 W3_8   W4_4 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_2
    W0_0 W0_1 W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 W0_8   W1_1 W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W2_3 W2_5 W2_5 W2_7 W2_8   W3_5 W3_5 W3_7 W3_8   W4_5 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_3
    W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W2_4 W2_5 W2_6 W2_7 W2_8   W3_5 W3_6 W3_7 W3_8   W4_6 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_4
    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 W0_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W2_5 W2_7 W2_7 W2_7 W2_8   W3_7 W3_7 W3_7 W3_8   W4_7 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_5
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W2_6 W2_7 W2_7 W2_7 W2_8   W3_7 W3_7 W3_7 W3_8   W4_7 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W2_7 W2_7 W2_7 W2_7 W2_8   W3_7 W3_7 W3_7 W3_8   W4_7 W4_7 W4_8   W5_7 W5_8   W8_8 # * W2_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W2_8 W2_8 W2_8 W2_8 W2_8   W3_8 W3_8 W3_8 W3_8   W4_8 W4_8 W4_8   W5_8 W5_8   W8_8 # * W2_8

    W0_0 W0_1 W0_1 W0_3 W0_3 W0_5 W0_5 W0_7 W0_8   W1_1 W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_1 W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_8   W3_3 W3_5 W3_5 W3_7 W3_8   W3_5 W3_5 W3_7 W3_8   W5_5 W5_7 W5_8   W5_7 W5_8   W8_8 # * W3_3
    W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W3_4 W3_5 W3_6 W3_7 W3_8   W3_5 W3_6 W3_7 W3_8   W5_6 W5_7 W5_8   W5_7 W5_8   W8_8 # * W3_4
    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 W0_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W3_5 W3_7 W3_7 W3_7 W3_8   W3_7 W3_7 W3_7 W3_8   W5_7 W5_7 W5_8   W5_7 W5_8   W8_8 # * W3_5
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W3_6 W3_7 W3_7 W3_7 W3_8   W3_7 W3_7 W3_7 W3_8   W5_7 W5_7 W5_8   W5_7 W5_8   W8_8 # * W3_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W3_7 W3_7 W3_7 W3_7 W3_8   W3_7 W3_7 W3_7 W3_8   W5_7 W5_7 W5_8   W5_7 W5_8   W8_8 # * W3_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W3_8 W3_8 W3_8 W3_8 W3_8   W3_8 W3_8 W3_8 W3_8   W5_8 W5_8 W5_8   W5_8 W5_8   W8_8 # * W3_8

    W0_0 W0_1 W0_2 W0_3 W0_4 W0_5 W0_6 W0_7 W0_8   W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 W1_7 W1_8   W2_2 W2_3 W2_4 W2_5 W2_6 W2_7 W2_8   W3_3 W3_4 W3_5 W3_6 W3_7 W3_8   W4_4 W4_5 W4_6 W4_7 W4_8   W5_5 W5_6 W5_7 W5_8   W6_6 W6_7 W6_8   W7_7 W7_8   W8_8 # * W4_4
    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 W0_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W2_3 W2_5 W2_5 W2_7 W2_7 W2_7 W2_8   W3_5 W3_5 W3_7 W3_7 W3_7 W3_8   W4_5 W4_7 W4_7 W4_7 W4_8   W5_7 W5_7 W5_7 W5_8   W6_7 W6_7 W6_8   W7_7 W7_8   W8_8 # * W4_5
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W2_4 W2_5 W2_6 W2_7 W2_7 W2_7 W2_8   W3_5 W3_6 W3_7 W3_7 W3_7 W3_8   W4_6 W4_7 W4_7 W4_7 W4_8   W5_7 W5_7 W5_7 W5_8   W6_7 W6_7 W6_8   W7_7 W7_8   W8_8 # * W4_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W2_7 W2_7 W2_7 W2_7 W2_7 W2_7 W2_8   W3_7 W3_7 W3_7 W3_7 W3_7 W3_8   W4_7 W4_7 W4_7 W4_7 W4_8   W5_7 W5_7 W5_7 W5_8   W6_7 W6_7 W6_8   W7_7 W7_8   W8_8 # * W4_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W2_8 W2_8 W2_8 W2_8 W2_8 W2_8 W2_8   W3_8 W3_8 W3_8 W3_8 W3_8 W3_8   W4_8 W4_8 W4_8 W4_8 W4_8   W5_8 W5_8 W5_8 W5_8   W6_8 W6_8 W6_8   W7_8 W7_8   W8_8 # * W4_8

    W0_0 W0_3 W0_3 W0_5 W0_5 W0_7 W0_7 W0_7 W0_8   W1_3 W1_3 W1_5 W1_5 W1_7 W1_7 W1_7 W1_8   W3_3 W3_5 W3_5 W3_7 W3_7 W3_7 W3_8   W3_5 W3_5 W3_7 W3_7 W3_7 W3_8   W5_5 W5_7 W5_7 W5_7 W5_8   W5_7 W5_7 W5_7 W5_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W5_5
    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W3_4 W3_5 W3_6 W3_7 W3_7 W3_7 W3_8   W3_5 W3_6 W3_7 W3_7 W3_7 W3_8   W5_6 W5_7 W5_7 W5_7 W5_8   W5_7 W5_7 W5_7 W5_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W5_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W3_7 W3_7 W3_7 W3_7 W3_7 W3_7 W3_8   W3_7 W3_7 W3_7 W3_7 W3_7 W3_8   W5_7 W5_7 W5_7 W5_7 W5_8   W5_7 W5_7 W5_7 W5_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W5_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W3_8 W3_8 W3_8 W3_8 W3_8 W3_8 W3_8   W3_8 W3_8 W3_8 W3_8 W3_8 W3_8   W5_8 W5_8 W5_8 W5_8 W5_8   W5_8 W5_8 W5_8 W5_8   W7_8 W7_8 W7_8   W7_8 W7_8   W8_8 # * W5_8

    W0_0 W0_3 W0_4 W0_5 W0_6 W0_7 W0_7 W0_7 W0_8   W1_3 W1_4 W1_5 W1_6 W1_7 W1_7 W1_7 W1_8   W4_4 W4_5 W4_6 W4_7 W4_7 W4_7 W4_8   W5_5 W5_6 W5_7 W5_7 W5_7 W5_8   W6_6 W6_7 W6_7 W6_7 W6_8   W7_7 W7_7 W7_7 W7_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W6_6
    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W4_7 W4_7 W4_7 W4_7 W4_7 W4_7 W4_8   W5_7 W5_7 W5_7 W5_7 W5_7 W5_8   W6_7 W6_7 W6_7 W6_7 W6_8   W7_7 W7_7 W7_7 W7_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W6_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W4_8 W4_8 W4_8 W4_8 W4_8 W4_8 W4_8   W5_8 W5_8 W5_8 W5_8 W5_8 W5_8   W6_8 W6_8 W6_8 W6_8 W6_8   W7_8 W7_8 W7_8 W7_8   W7_8 W7_8 W7_8   W7_8 W7_8   W8_8 # * W6_8

    W0_0 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_7 W0_8   W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_7 W1_8   W5_7 W5_7 W5_7 W5_7 W5_7 W5_7 W5_8   W5_7 W5_7 W5_7 W5_7 W5_7 W5_8   W7_7 W7_7 W7_7 W7_7 W7_8   W7_7 W7_7 W7_7 W7_8   W7_7 W7_7 W7_8   W7_7 W7_8   W8_8 # * W7_7
    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8 W1_8   W5_8 W5_8 W5_8 W5_8 W5_8 W5_8 W5_8   W5_8 W5_8 W5_8 W5_8 W5_8 W5_8   W7_8 W7_8 W7_8 W7_8 W7_8   W7_8 W7_8 W7_8 W7_8   W7_8 W7_8 W7_8   W7_8 W7_8   W8_8 # * W7_8

    WALL WALL WALL WALL WALL WALL WALL WALL WALL   W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8   W8_8 W8_8 W8_8 W8_8 W8_8 W8_8 W8_8   W8_8 W8_8 W8_8 W8_8 W8_8 W8_8   W8_8 W8_8 W8_8 W8_8 W8_8   W8_8 W8_8 W8_8 W8_8   W8_8 W8_8 W8_8   W8_8 W8_8   W8_8 # * W8_8
    ]

    warlpiri_mul_test_matrix = [a * b for a in pos_warlpiri, b in pos_warlpiri]
    warlpiri_label_matrix = [(a, b) for a in pos_warlpiri, b in pos_warlpiri]

    for (expected, evaluated, l) in zip(warlpiri_prod_matrix, warlpiri_mul_test_matrix, warlpiri_label_matrix)
        #println(l)
        @test (expected, l) == (evaluated, l)
    end

    #next, test values when multiplying times something which goes "round the
    #zero"... We'll use the interval (-1, 1], which is representable as 0b1101
    #-> 0b1100

    WRTZ = WP1101 → WP0100
    warlpiri_mul_rtz_values = [
    WP0000 → WP0000, #WP0000 → WP0000
    WP1111 → WP0001, #WP0000 → WP0001
    WP1111 → WP0010, #WP0000 → WP0010
    WP1101 → WP0011, #WP0000 → WP0011
    WP1101 → WP0100, #WP0000 → WP0100
    WP1011 → WP0101, #WP0000 → WP0101
    WP1011 → WP0110, #WP0000 → WP0110
    WP1001 → WP0111, #WP0000 → WP0111
    WP1001 → WP1000, #WP0000 → WP1000

    WP1111 → WP0001, #WP0001 → WP0001
    WP1111 → WP0010, #WP0001 → WP0010
    WP1101 → WP0011, #WP0001 → WP0011
    WP1101 → WP0100, #WP0001 → WP0100
    WP1011 → WP0101, #WP0001 → WP0101
    WP1011 → WP0110, #WP0001 → WP0110
    WP1001 → WP0111, #WP0001 → WP0111
    WP1001 → WP1000, #WP0001 → WP1000

    WP1111 → WP0010, #WP0010 → WP0010
    WP1101 → WP0011, #WP0010 → WP0011
    WP1101 → WP0100, #WP0010 → WP0100
    WP1011 → WP0101, #WP0010 → WP0101
    WP1011 → WP0110, #WP0010 → WP0110
    WP1001 → WP0111, #WP0010 → WP0111
    WP1001 → WP1000, #WP0010 → WP1000

    WP1101 → WP0011, #WP0011 → WP0011
    WP1101 → WP0100, #WP0011 → WP0100
    WP1011 → WP0101, #WP0011 → WP0101
    WP1011 → WP0110, #WP0011 → WP0110
    WP1001 → WP0111, #WP0011 → WP0111
    WP1001 → WP1000, #WP0011 → WP1000

    WP1101 → WP0100, #WP0100 → WP0100
    WP1011 → WP0101, #WP0100 → WP0101
    WP1011 → WP0110, #WP0100 → WP0110
    WP1001 → WP0111, #WP0100 → WP0111
    WP1001 → WP1000, #WP0100 → WP1000

    WP1011 → WP0101, #WP0101 → WP0101
    WP1011 → WP0110, #WP0101 → WP0110
    WP1001 → WP0111, #WP0101 → WP0111
    WP1001 → WP1000, #WP0101 → WP1000

    WP1011 → WP0110, #WP0110 → WP0110
    WP1001 → WP0111, #WP0110 → WP0111
    WP1001 → WP1000, #WP0110 → WP1000

    WP1001 → WP0111, #WP0111 → WP0111
    WP1001 → WP1000, #WP0111 → WP1000

    WP1001 → WP1000, #WP1000 → WP1000
    ]

    for (a,b) in zip(warlpiri_mul_rtz_values,pos_warlpiri)
        @test (a, b) == (WRTZ * b, b)
    end

    #test two rounding-zero
    @test (WP1110 → WP0001) * (WP1010 → WP0101) == (WP1101 → WP0100)

    #test a plain rounding-infinity

    WRTI = WP0100 → WP1011

    warlpiri_mul_rti_values = [
    WP1001 → WP1000, #WP0000 → WP0000
    WP1001 → WP1000, #WP0000 → WP0001
    WP1001 → WP1000, #WP0000 → WP0010
    WP1001 → WP1000, #WP0000 → WP0011
    WP1001 → WP1000, #WP0000 → WP0100
    WP1001 → WP1000, #WP0000 → WP0101
    WP1001 → WP1000, #WP0000 → WP0110
    WP1001 → WP1000, #WP0000 → WP0111
    WP1001 → WP1000, #WP0000 → WP1000

    WP0001 → WP1111, #WP0001 → WP0001
    WP0001 → WP1111, #WP0001 → WP0010
    WP0001 → WP1111, #WP0001 → WP0011
    WP0001 → WP1111, #WP0001 → WP0100
    WP0001 → WP1111, #WP0001 → WP0101
    WP0001 → WP1111, #WP0001 → WP0110
    WP0001 → WP1111, #WP0001 → WP0111
    WP0001 → WP1111, #WP0001 → WP1000

    WP0010 → WP1101, #WP0010 → WP0010
    WP0010 → WP1101, #WP0010 → WP0011
    WP0010 → WP1101, #WP0010 → WP0100
    WP0010 → WP1101, #WP0010 → WP0101
    WP0010 → WP1101, #WP0010 → WP0110
    WP0010 → WP1101, #WP0010 → WP0111
    WP0010 → WP1101, #WP0010 → WP1000

    WP0011 → WP1101, #WP0011 → WP0011
    WP0011 → WP1101, #WP0011 → WP0100
    WP0011 → WP1101, #WP0011 → WP0101
    WP0011 → WP1101, #WP0011 → WP0110
    WP0011 → WP1101, #WP0011 → WP0111
    WP0011 → WP1101, #WP0011 → WP1000

    WP0100 → WP1011, #WP0100 → WP0100
    WP0100 → WP1011, #WP0100 → WP0101
    WP0100 → WP1011, #WP0100 → WP0110
    WP0100 → WP1011, #WP0100 → WP0111
    WP0100 → WP1011, #WP0100 → WP1000

    WP0101 → WP1011, #WP0101 → WP0101
    WP0101 → WP1011, #WP0101 → WP0110
    WP0101 → WP1011, #WP0101 → WP0111
    WP0101 → WP1011, #WP0101 → WP1000

    WP0110 → WP1001, #WP0110 → WP0110
    WP0110 → WP1001, #WP0110 → WP0111
    WP0110 → WP1001, #WP0110 → WP1000

    WP0111 → WP1001, #WP0111 → WP0111
    WP0111 → WP1001, #WP0111 → WP1000

    WP1000 → WP1000, #WP1000 → WP1000
    ]

    for (a,b) in zip(warlpiri_mul_rti_values,pos_warlpiri)
        @test (a, b) == (WRTI * b, b)
    end

    #test values that round both zero and infinity
    WRTB = WP0110 → WP0001

    warlpiri_mul_rtb_values = [
    WP1001 → WP1000, #WP0000 → WP0000  #anything that contains zero will trigger all reals.
    WP1001 → WP1000, #WP0000 → WP0001
    WP1001 → WP1000, #WP0000 → WP0010
    WP1001 → WP1000, #WP0000 → WP0011
    WP1001 → WP1000, #WP0000 → WP0100
    WP1001 → WP1000, #WP0000 → WP0101
    WP1001 → WP1000, #WP0000 → WP0110
    WP1001 → WP1000, #WP0000 → WP0111
    WP1001 → WP1000, #WP0000 → WP1000

    WP1001 → WP1000, #WP0001 → WP0001 #the 0b0111 * 0b0001 closes the gap here.
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

    for (a,b) in zip(warlpiri_mul_rtb_values,pos_warlpiri)
        @test (a, b) == (WRTB * b, b)
    end

    @test (WP1001 → WP1000) == WRTB * WRTI
    @test (WP1001 → WP1000) == WRTB * WRTZ
    @test (WP1001 → WP1000) == WRTB * WRTB
end
