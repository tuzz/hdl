class HDL::SchemaChip < HDL::Chip

  def initialize(name, path, data)
    super
    @schema = data[:schema]
    create_dependencies
    load_dependencies(:dependents)
    evaluate_some_expression
  end

  def internal
    wiring_values - inputs - outputs - [true, false]
  end

  def components
    chips = component_names.map do |name|
      HDL::Loader.load(name)
    end

    freq = frequencies(chips)
    hashes = [freq] + chips.map(&:components)

    hashes.inject({}) do |acc, hash|
      acc.merge(hash) { |_, a, b| a + b }
    end
  end

  def primitive?
    false
  end

  def evaluate(pins = {})
    memoize(pins) do
      check_pins!(pins)
      evaluator.evaluate(pins)
    end
  end

  private
  def create_dependencies
    component_names.each do |dep|
      HDL::Dependency.create(name, dep.to_s)
    end
  end

  def component_names
    @schema.map(&:keys).flatten
  end

  def wiring
    @schema.map(&:values).flatten
  end

  def wiring_values
    wiring.map(&:values).flatten.uniq
  end

  def evaluator
    @evaluator ||= Evaluator.new(self, @schema)
  end

  def frequencies(array)
    array.inject(Hash.new(0)) do |hash, element|
      hash[element] += 1
      hash
    end
  end

  # Check upfront if there are circular problems
  # by evaluating something on the chip.
  def evaluate_some_expression
    pins = Hash[inputs.zip(inputs.map { true })]
    evaluate(pins)
  end

end
