class HDL::SchemaChip::Evaluator

  def initialize(chip, schema)
    @chip   = chip
    @schema = schema
    @parts  = partition_io
    @order  = evaluation_order(@parts, chip.inputs)

    check_multi_internal!
  end

  def evaluate(pins)
    results = @order.inject(pins) do |known_pins, i|
      known_pins.merge(evaluate_line(@parts[i], known_pins))
    end

    filter_outputs(results)
  end

  private
  def evaluate_line(line, pins)
    chip, inputs, outputs = line

    chip_in  = connect_inputs(inputs, pins)
    chip_out = chip.evaluate(chip_in)

    connect_outputs(outputs, chip_out)
  end

  def connect_inputs(inputs, pins)
    is_bool = lambda { |x| [true, false].include?(x) }

    inputs.inject({}) do |hash, (dest, source)|
      value = is_bool[source] ? source : pins[source]
      hash.merge(dest => value)
    end
  end

  def connect_outputs(outputs, pins)
    outputs.inject({}) do |hash, (dest, source)|
      hash.merge(source => pins[dest])
    end
  end

  def filter_outputs(pins)
    f = pins.select { |k, _| @chip.outputs.include?(k) }
    Hash[f]
  end

  def evaluation_order(schema_lines, known_pins, first_call = true)
    schema_lines = schema_lines.each_with_index if first_call

    known, unknown = schema_lines.partition do |line, _|
      all_inputs_known?(line, known_pins)
    end

    known_outputs = known.map do |line, _|
      outputs_for_line(line)
    end.flatten

    check_for_new_information!(known_outputs, unknown)

    if unknown.any?
      # Recursive case.
      next_pins = known_pins + known_outputs
      tail = evaluation_order(unknown, next_pins, false)
    else
      # Base case.
      tail = []
    end

    known_indexes = known.map(&:last)
    known_indexes + tail
  end

  def all_inputs_known?(line, known_pins)
    _, inputs, _ = line
    inputs.values.all? do |pin|
      (known_pins + [true, false]).include?(pin)
    end
  end

  def partition_io
    @schema.map do |line|
      chip_name   = line.keys.first
      wiring      = line.values.first
      dest_pins   = wiring.keys
      source_pins = wiring.values
      chip        = fetch_chip(chip_name)

      inputs, outputs = wiring.partition do |dest, source|
        chip.inputs.include?(dest)
      end

      [chip, Hash[inputs], Hash[outputs]]
    end
  end

  def outputs_for_line(line)
    line.last.values
  end

  def check_for_new_information!(information, unknown)
    if information.empty?
      p = unknown.map do |(chip, _, _), exp|
        { (exp + 1) => chip.name }.inspect
      end.join(", ")

      if unknown.size == 1
        err = "Unknown internal pin for expression: #{p}"
      else
        err = "Unknowable internal pins for expressions: #{p}"
      end

      raise CircularError, err
    end
  end

  # We can't check this at parse time because we
  # don't know which are getters/setters.
  def check_multi_internal!
    set_pins = @parts.map do |_, _, outputs|
      outputs.values
    end.flatten

    repetitions = set_pins.select { |p| set_pins.count(p) > 1 }.uniq
    if repetitions.size == 1
      err = "The internal pin `#{repetitions.first}' is set multiple times"
      raise ParseError, err
    elsif repetitions.size > 1
      list = repetitions.join(', ')
      err = "These internal pins are set multiple times: #{list}"
      raise ParseError, err
    end
  end

  def fetch_chip(name)
    HDL::Loader.load(name)
  end

end
