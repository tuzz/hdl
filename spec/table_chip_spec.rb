require "spec_helper"

describe HDL::TableChip do
  subject do
    input = File.read("spec/fixtures/nand.hdl")
    data = HDL::Parser.parse(input)

    HDL::TableChip.new("nand", "/some/path", data)
  end

  describe "accessors" do
    its(:name)       { should == "nand" }
    its(:path)       { should == "/some/path" }
    its(:inputs)     { should == [:a, :b] }
    its(:outputs)    { should == [:out] }
    its(:primitive?) { should be_true }
    its(:internal)   { should be_empty }
    its(:components) { should be_empty }
    its(:primitives) { should be_empty }
    its(:dependents) { should be_empty }
  end
describe "#inspect" do it "keeps things simple" do
      pending "delegate to super"
      subject.inspect.should == "#<HDL::Chip nand>"
    end
  end

  describe "#evaluate" do
    it "fetches the result from the truth table" do
      subject.evaluate(:a => false, :b => false).
        should == { :out => true }

      subject.evaluate(:a => false, :b => true).
        should == { :out => true }

      subject.evaluate(:a => true, :b => false).
        should == { :out => true }

      subject.evaluate(:a => true, :b => true).
        should == { :out => false }
    end

    it "raises an argument error if any other pin is set" do
      expect {
        subject.evaluate(:a => true, :b => true, :x => true)
      }.to raise_error(ArgumentError, /Expecting inputs \[:a, :b\]/)

      expect {
        subject.evaluate(:a => true, :b => true, :out => true)
      }.to raise_error(ArgumentError, /Expecting inputs \[:a, :b\]/)
    end

    it "raises an argument error if an input is not set" do
      expect {
        subject.evaluate(:a => false)
      }.to raise_error(ArgumentError, /Expecting inputs \[:a, :b\]/)
    end
  end

  describe "#dependees" do
    pending "set up some chips that use nand"
  end

end
