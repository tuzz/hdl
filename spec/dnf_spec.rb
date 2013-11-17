require "spec_helper"

describe "Generating expression in disjunctive normal form" do

  context "for a table chip" do
    subject { HDL.load("nand") }

    it "returns a DNF string from an evaluation" do
      result = subject.evaluate(:a => "x", :b => "y")
      result[:out].should == [
        "!(x || y)",         # | 0 | 0 |  1  | <-- Note: DeMorgan's applied
        "!x && y",           # | 0 | 1 |  1  | <--
        "x && !y"            # | 1 | 0 |  1  | <--
        # row is false       # | 1 | 1 |  0  |
      ].join(" || ")
    end
  end

  context "for a schema chip" do
    subject { HDL.load("and") }

    it "returns a DNF string from an evaluation" do
      pending

      result = subject.evaluate(:a => "x", :b => "y")
      raise result[:out]
      clauses = result[:out].split("OR").map(&:strip)

      clauses.should =~ [    # | a | b | out |
        # row is false       # | 0 | 0 |  0  |
        # row is false       # | 0 | 1 |  0  |
        # row is false       # | 1 | 0 |  0  |
        "x && y"             # | 1 | 1 |  1  | <--
      ]
    end
  end

  describe "partial evaluations" do
    subject { HDL.load("nand") }

    it "collapses terms and clauses" do
      result = subject.evaluate(:a => "x", :b => true)

      # !x && !true           OR  <-- clause disappears
      # !x &&  true           OR  <--   term disappears
      #  x && !true               <-- clause disappears

      result[:out].should == "!x"
    end

    it "evaluates tautologies" do
      result = subject.evaluate(:a => "x", :b => false)

      # !x && !false          OR  <--   term disappears
      # !x &&  false          OR  <-- clause disappears
      #  x && !false              <--   term disappears
      #
      # !x OR x <=> true

      result[:out].should be_true
    end

    it "evaluates contradictions" do
      subject = HDL.load("and")
      result = subject.evaluate(:a => "x", :b => false)

      pending
    end
  end

end
