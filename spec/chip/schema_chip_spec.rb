require "spec_helper"

describe HDL::SchemaChip do
  subject do
    input = File.read("spec/fixtures/and.hdl")
    data = HDL::Parser.parse(input)

    HDL::SchemaChip.new("and", "/some/path", data)
  end

  describe "#internal" do
    it "returns an array of the internal pins" do
      subject.internal.should == [:x]
    end
  end

  describe "#components" do
    subject { HDL::Loader.load("mux") }

    it "returns a components list as a hash" do
      # Names of chips are easier to work with
      hash = subject.components.inject({}) do |h, (k, v)|
        h.merge(k.name => v)
      end

      hash.should == {
        "nand" => 8,
        "not"  => 3,
        "and"  => 2,
        "or"   => 1
      }
    end
  end

  describe "#primitive?" do
    it "returns false" do
      subject.should_not be_primitive
    end
  end

  describe "#evaluate" do
    pending
  end

end
