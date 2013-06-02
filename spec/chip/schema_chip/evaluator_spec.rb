require "spec_helper"

describe HDL::SchemaChip::Evaluator do

  def check(chip, expectations)
    evaluator = chip.instance_variable_get(:@evaluator)

    to_bool = lambda { |i| i.zero? ? false : true }
    expectations = expectations.inject({}) do |hash, (ins, outs)|
      ins.map!  { |i| to_bool[i] }
      outs.map! { |i| to_bool[i] }

      ins =  Hash[chip.inputs.zip(ins)]
      outs = Hash[chip.outputs.zip(outs)]

      hash.merge(ins => outs)
    end

    expectations.each do |ins, outs|
      result = evaluator.evaluate(ins)
      result.should eq(outs),
        "Got #{result.inspect} for #{ins.inspect}"
    end
  end

  after do
    check(@chip, @expectations)
  end

  it "evaluates 'and' correctly" do
    @chip = HDL::Loader.load("and")

    @expectations = {
      [0, 0] => [0],
      [0, 1] => [0],
      [1, 0] => [0],
      [1, 1] => [1]
    }
  end

  it "evaluates 'half_adder correctly" do
    @chip = HDL::Loader.load("half_adder")

    @expectations = {
      [0, 0] => [0, 0],
      [0, 1] => [1, 0],
      [1, 0] => [1, 0],
      [1, 1] => [0, 1]
    }
  end

  it "evaluates 'mux correctly" do
    @chip = HDL::Loader.load("mux")

    @expectations = {
      [0, 0, 0] => [0],
      [0, 0, 1] => [0],
      [0, 1, 0] => [0],
      [0, 1, 1] => [1],
      [1, 0, 0] => [1],
      [1, 0, 1] => [0],
      [1, 1, 0] => [1],
      [1, 1, 1] => [1]
    }
  end

  it "evaluates 'not correctly" do
    @chip = HDL::Loader.load("not")

    @expectations = {
      [0] => [1],
      [1] => [0]
    }
  end

  it "evaluates 'or correctly" do
    @chip = HDL::Loader.load("or")

    @expectations = {
      [0, 0] => [0],
      [0, 1] => [1],
      [1, 0] => [1],
      [1, 1] => [1]
    }
  end

  it "evaluates 'xor correctly" do
    @chip = HDL::Loader.load("xor")

    @expectations = {
      [0, 0] => [0],
      [0, 1] => [1],
      [1, 0] => [1],
      [1, 1] => [0]
    }
  end

  it "raises errors if no new info......."

end
