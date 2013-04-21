require "spec_helper"

describe TableParser do

  describe "table" do
    valid([
      "| a | b | out |
       | 0 | 0 |  1  |
       | 0 | 1 |  1  |
       | 1 | 0 |  1  |
       | 1 | 1 |  0  |",

      "| in | out |
       | 0  |  1  |
       | 1  |  0  |",

      "| in_1 | in_2 | out_a | out_b |
       |  0   |  0   |   T   |   T   |
       |  0   |  1   |   F   |   T   |
       |  1   |  0   |   T   |   F   |
       |  1   |  1   |   F   |   F   |"
    ])

    invalid([
      "",

      "| a | b | out |",

      "| 0 | 1 |",

      "in out
       0   1
       1   0 "
    ])

    describe "#to_array" do
      it "returns an array of the mappings for each row" do
        expectations = {
          "| in | out |
           | 0  |  1  |
           | 1  |  0  |" => [
             { :in => false, :out => true },
             { :in => true, :out => false }
          ],

          "| a | b | out |
           | 0 | 0 |  T  |
           | 0 | 1 |  T  |
           | 1 | 0 |  T  |
           | 1 | 1 |  F  |" => [
             { :a => false, :b => false, :out => true  },
             { :a => false, :b => true,  :out => true  },
             { :a => true,  :b => false, :out => true  },
             { :a => true,  :b => true,  :out => false }
          ]
        }

        expectations.each do |input, output|
          subject.parse(input).to_array.should == output
        end
      end
    end
  end

  describe "header" do
    valid(["| a | b | out |", "|a|b|out|", "| in|  out|", "|a_b1 | c_d_e |"])
    invalid(["", "a b out", "| a b out |", "| a ||", "| 0 | 1 |"])
  end

  describe "row" do
    valid(["|0|", "|0|1|0|", "| T | F |", "|T|0|1|\tF\n|F|", "|0|0|0|"])
    invalid([" |0|", "|1| ", "|a|", "|2|", "|T|f|", "0 | 1", "|T | F"])
  end

  describe "header_cells" do
    valid(["a | b | out", "a|b|out", "\n\n a|b \t |o_u_t", "in \t|\t out|a|b"])
    invalid(["", "| a | b | out |", "0 | 1", "a | T", "\t a_b b|_c"])

    describe "#to_array" do
      it "returns an array of variable names for the header" do
        expectations = {
          "a | b | out" => [:a, :b, :out],
          "  foo_bar | baz " => [:foo_bar, :baz],
          " a | b | c1 | d2" => [:a, :b, :c1, :d2]
        }

        expectations.each do |input, output|
          subject.parse(input).to_array.should == output
        end
      end
    end
  end

  describe "row_cells" do
    valid(["0|1|0", " 1 |F| 0\t", "0|1 | T|F\n|F\t|1", "1|1|1|1|1"])
    invalid(["", "t", "T |", "|0", "0 | 1 | 2", "o | 1"])

    describe "#to_array" do
      it "returns an array of booleans for the row" do
        expectations = {
          "0 | 1 | T | F" => [false, true, true, false],
          "1|1|1" => [true, true, true],
          "F|F \t |T|0" => [false, false, true, false]
        }

        expectations.each do |input, output|
          subject.parse(input).to_array.should == output
        end
      end
    end
  end
end
