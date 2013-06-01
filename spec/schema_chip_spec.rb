require "spec_helper"

describe HDL::SchemaChip do
  subject do
    input = File.read("spec/fixtures/and.hdl")
    data = HDL::Parser.parse(input)

    HDL::SchemaChip.new("and", "/some/path", data)
  end

  describe "accessors" do
    its(:name)       { should == "and" }
    its(:path)       { should == "/some/path" }
    its(:inputs)     { should == [:a, :b] }
    its(:outputs)    { should == [:out] }
    its(:primitive?) { should be_false }
    its(:internal)   { should == [:x] }
  end

  describe "#dependents" do
    subject do
      HDL::Loader.load("mux")
    end

    it "returns an array of chips that this chip uses" do
      arr = subject.dependents.map(&:name)

      arr.size.should == 4
      arr.should =~ %w(and or not nand)
    end
  end

  describe "#dependees" do
    before do
      HDL::Loader.load("half_adder")
    end

    it "returns an array of chips that use this chip" do
      arr = subject.dependees.map(&:name)

      arr.size.should == 2
      arr.should =~ %w(half_adder xor)

      # Load a new chip that uses this chip.
      HDL::Loader.load("mux")
      arr = subject.dependees.map(&:name)

      arr.size.should == 3
      arr.should =~ %w(half_adder xor mux)
    end
  end

  describe "#components" do
    pending
  end

#    its(:components) { should be_empty }
#    its(:primitives) { should be_empty }
#    its(:dependents) { should be_empty }
end
