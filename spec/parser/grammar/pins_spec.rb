require "spec_helper"

describe PinsParser do

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

    describe "#input_array" do
      it "returns a symbolized array of inputs" do
        expectations = {
          "inputs a, b outputs c" => [:a, :b],
          "inputs a \n outputs b" => [:a]
        }

        expectations.each do |input, output|
          subject.parse(input).input_array.should == output
        end
      end
    end

    describe "#output_array" do
      it "returns a symbolized array of outputs" do
        expectations = {
          "inputs a, b outputs c" => [:c],
          "inputs a \n outputs b" => [:b]
        }

        expectations.each do |input, output|
          subject.parse(input).output_array.should == output
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

end
