require "spec_helper"

describe "Generating expression in disjunctive normal form" do

  context "for a table chip" do
    subject { HDL.load("nand") }

    it "returns a DNF string from an evaluation" do
      result = subject.evaluate(:a => "x", :b => "y")
      clauses = result[:out].split("OR").map(&:strip)

      clauses.should =~ [    # | a | b | out |
        "NOT(x) AND NOT(y)", # | 0 | 0 |  1  | <--
        "NOT(x) AND y",      # | 0 | 1 |  1  | <--
        "x AND NOT(y)"       # | 1 | 0 |  1  | <--
        # row is false       # | 1 | 1 |  0  |
      ]
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
        "x AND y"            # | 1 | 1 |  1  | <--
      ]
    end
  end

  describe "partial evaluations" do
    subject { HDL.load("nand") }

    it "collapses terms and clauses" do
      result = subject.evaluate(:a => "x", :b => true)

      # NOT(x) AND NOT(true) OR  <-- clause disappears
      # NOT(x) AND true      OR  <--   term disappears
      # x      AND NOT(true)     <-- clause disappears

      result[:out].should == "NOT(x)"
    end

    it "evaluates tautologies" do
      result = subject.evaluate(:a => "x", :b => false)

      # NOT(x) AND NOT(false) OR  <--   term disappears
      # NOT(x) AND false      OR  <-- clause disappears
      # x      AND NOT(false)     <--   term disappears
      #
      # NOT(x) OR x <=> true

      result[:out].should be_true
    end

    it "evaluates contradictions" do
      subject = HDL.load("and")
      result = subject.evaluate(:a => "x", :b => false)

      pending
    end
  end

end
