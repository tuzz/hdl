require "spec_helper"

describe HDL::TableChip do
  subject do
    input = File.read("spec/fixtures/nand.hdl")
    data = HDL::Parser.parse(input)

    HDL::TableChip.new("nand", "/some/path", data)
  end

  describe "accessors" do
    its(:internal)   { should be_empty }
    its(:components) { should be_empty }
    its(:primitive?) { should be_true }
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

    it "memoizes the result for faster successive evaluations" do
      subject.evaluate(:a => true, :b => false)
      subject.should_not_receive(:check_pins!)
      subject.evaluate(:a => true, :b => false)
    end
  end

end
