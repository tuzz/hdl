require "spec_helper"

describe VarsParser do

  describe "vars" do
    valid(["a, b", "out", "a, b,c, d", "a,\n\n b", "a_b1, c"])
    invalid(["a ,b", "A", "fooBar", "a\n,b", "a,b ,d", ""])

    describe "#to_array" do
      it "returns an array of the variable names as symbols" do
        expectations = {
          "a, b"       => [:a, :b],
          "out"        => [:out],
          "a0, b1, c2" => [:a0, :b1, :c2],
          "foo_bar"    => [:foo_bar]
        }

        expectations.each do |input, output|
          subject.parse(input).to_array.should == output
        end
      end
    end
  end

  describe "var" do
    valid(["a", "foo", "a123", "foo999", "a_b", "a_1_b_2"])
    invalid(["a b", "A", "0", "_", "Asd", "0ab", "_foo"])

    describe "#to_sym" do
      it "returns the ruby symbol for the string" do
        expectations = {
          "a" => :a, "foo" => :foo, "asd123" => :asd123, "foo_bar" => :foo_bar
        }

        expectations.each do |input, output|
          subject.parse(input).to_sym.should == output
        end
      end
    end
  end

  describe "ws" do
    valid(["    ", "  \t  \t", "\n\n", "\r\n\t  \r \t"])
    invalid(["a", "_", "  _", " r n t ", "."])
  end

  describe "boolean" do
    valid(["0", "1", "T", "F"])
    invalid(["", " 0", "1 ", "t", "FF"])

    describe "#to_bool" do
      it "returns the ruby boolean equivalent" do
        expectations = {
          "0" => false,
          "1" => true,
          "F" => false,
          "T" => true
        }

        expectations.each do |input, output|
          subject.parse(input).to_bool.should == output
        end
      end
    end
  end

end
