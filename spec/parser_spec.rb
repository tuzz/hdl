require "spec_helper"

describe HDL::Parser do
  let(:klass) { subject.class }

  it "parses a definition and returns structured data" do
    result = klass.parse(File.read("spec/fixtures/and.hdl"))
    result.should be_a(Hash)

    result[:inputs].should == [:a, :b]
    result[:outputs].should == [:out]
    result[:schema].should == [
      { :nand => { :a => :a, :b => :b, :out => :x   } },
      { :nand => { :a => :x, :b => :x, :out => :out } }
    ]
  end

  context "when the input is not a member of the grammar" do
    let(:input) { "inputs in outputs out nand a:a, b:b, out:out" }

    it "raises a parse error" do
      expect {
        klass.parse(input)
      }.to raise_error(ParseError, /Expected \( at line 1/)
    end
  end

  context "when the input has other fundamental problems" do
    let(:input) { "inputs out outputs out nand(a=a,b=b,out=out)" }

    it "raises a parse error" do
      expect {
        klass.parse(input)
      }.to raise_error(ParseError, /`out' is both/)
    end
  end

end
