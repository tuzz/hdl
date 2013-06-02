require "spec_helper"

describe HDL::Chip do
  let(:data) do
    {
      :inputs => [:a, :b],
      :outputs => [:out]
    }
  end

  subject { HDL::Chip.new("abstract", "/some/path", data) }

  describe "accessors" do
    its(:name)       { should == "abstract" }
    its(:path)       { should == "/some/path" }
    its(:inputs)     { should == [:a, :b] }
    its(:outputs)    { should == [:out] }
  end

  describe "#inspect" do
    it "keeps things simple" do
      subject.inspect.should == "#<HDL::Chip abstract>"
    end
  end

  describe "#primitibves" do
    before do
      @mock_primitive = mock(:primitive, :primitive? => true)
      mock_schema = mock(:schema, :primitive? => false)
      array = [@mock_primitive, mock_schema]
      subject.stub(:dependents).and_return(array)
    end

    it "returns an array of dependent primitive chips" do
      subject.primitives.should == [@mock_primitive]
    end
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
    subject do
      HDL::Loader.load("and")
    end

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

end
