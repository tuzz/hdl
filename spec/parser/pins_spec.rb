require "spec_helper"

describe PinsParser do

  describe "ws" do
    valid(["    ", "  \t  \t", "\n\n", "\r\n\t  \r \t"])
    invalid(["a", "_", "  _", " r n t ", "."])
  end

  describe "var" do
    valid(["a", "foo", "a123", "foo999", "a_b", "a_1_b_2"])
    invalid(["a b", "A", "0", "_", "Asd", "0ab", "_foo"])
  end

  describe "vars" do
    valid(["a, b", "out", "a, b,c, d", "a,\n\n b", "a_b1, c"])
    invalid(["a ,b", "A", "fooBar", "a\n,b", "a,b ,d", ""])

    describe "#to_a" do
      it "returns an array of the variable names as symbols" do
        expectations = {
          "a, b"       => [:a, :b],
          "out"        => [:out],
          "a0, b1, c2" => [:a0, :b1, :c2],
          "foo_bar"    => [:foo_bar]
        }

        expectations.each do |input, output|
          subject.parse(input).to_a.should == output
        end
      end
    end
  end

  describe "inputs" do
    valid(["inputs a, b", "inputs a_b", "inputs a0,b1,c2"])
    invalid(["input a", "inputsa", "inputs 0abc", "inputs"])
  end

  describe "outputs" do
    valid(["outputs out", "outputs a0", "outputs \n\r\t asd"])
    invalid(["", "output a", "outputs _a", "outputs"])
  end

  describe "pins" do
    valid([
      "inputs a, b \n outputs out",
      "inputs in outputs out",
      "inputs \n\n a_in1, \n b_in2 \n\n outputs o_out"
    ])

    invalid([
      "inputs a, boutputs c",
      "inputs a",
      "   inputs a, b \n outputs c",
      "inputs a outputs b  "
    ])

    describe "#to_hash" do
      it "returns a hash of the input and output pins" do
        expectations = {
          "inputs a, b outputs c" => { :inputs => [:a, :b], :outputs => [:c] },
          "inputs a \n outputs b" => { :inputs => [:a], :outputs => [:b] }
        }

        expectations.each do |input, output|
          subject.parse(input).to_hash.should == output
        end
      end
    end
  end

end
