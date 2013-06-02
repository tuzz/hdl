require "spec_helper"

describe HDL do

  it "parses the example schema correctly" do
    chip = HDL.parse "and", <<-HDL
      # and.hdl
      inputs  a, b
      outputs out

      nand(a=a, b=b, out=x)
      nand(a=x, b=x, out=out)
    HDL

    chip.name.should == "and"

    chip.evaluate(:a => true, :b => false).
      should == { :out => false }
  end

  it "parses the example truth table correctly" do
    chip = HDL.parse "nand", <<-HDL
      # nand.hdl
      inputs  a, b
      outputs out

      | a | b | out |
      | 0 | 0 |  1  |
      | 0 | 1 |  1  |
      | 1 | 0 |  1  |
      | 1 | 1 |  0  |
    HDL

    chip.name.should == "nand"

    chip.evaluate(:a => false, :b => true).
      should == { :out => true }
  end

  it "works correctly for the examples in the readme" do
    chip = HDL.load("and")

    chip.evaluate(:a => true, :b => false).
      should == { :out => false }

    HDL.path << "chips"
    HDL.path.should include("chips")

    foo = HDL.parse "foo", <<-HDL
      # Some made up chip.
      inputs in
      outputs a, b

      and(a=in, b=in, out=a)
      nand(a=in, b=in, out=b)
    HDL

    foo.name.should == "foo"
    foo.path.should be_nil

    foo.evaluate(:in => true).
      should == { :a => true, :b => false }

    chip.name.should == "and"
    chip.path.should == "spec/fixtures/and.hdl"
    chip.inputs.should == [:a, :b]
    chip.outputs.should == [:out]
    chip.internal.should == [:x]

    c = chip.components
    c.size.should == 1
    c.keys.first.name.should == "nand"
    c.values.first.should == 2

    chip.should_not be_primitive

    p = chip.primitives
    p.size.should == 1
    p.first.name.should == "nand"

    d = chip.dependents
    d.size.should == 1
    d.first.name.should == "nand"

    chip.dependees.map(&:name).should == ["foo"]
  end

end
