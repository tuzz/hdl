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
      pending "depends on improvements to github.com/tuzz/boolean_simplifier"

      result = subject.evaluate(:a => "x", :b => "y")
      raise result[:out]
      clauses = result[:out].split("||").map(&:strip)

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

      # !x && !true           ||  <-- clause disappears
      # !x &&  true           ||  <--   term disappears
      #  x && !true               <-- clause disappears

      result[:out].should == "!x"
    end

    it "evaluates tautologies" do
      result = subject.evaluate(:a => "x", :b => false)

      # !x && !false          ||  <--   term disappears
      # !x &&  false          ||  <-- clause disappears
      #  x && !false              <--   term disappears
      #
      # !x || x <=> true

      result[:out].should eq true
    end

    it "evaluates contradictions" do
      subject = HDL.load("and")
      result = subject.evaluate(:a => "x", :b => false)

      # x && false <=> false

      result[:out].should eq false
    end
  end

end
