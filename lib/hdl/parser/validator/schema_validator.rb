class HDL::Parser::Validator::SchemaValidator < HDL::Parser::Validator

  def validate!
    inputs!
    outputs!
  end

  private
  def inputs!
    inputs = @hash[:inputs]
    disconnected_inputs = inputs - connected_pins
    disconnected_pins_error(disconnected_inputs, "input")
  end

  def outputs!
    outputs = @hash[:outputs]
    disconnected_outputs = outputs - connected_pins
    disconnected_pins_error(disconnected_outputs, "output")

    repetitions = outputs.select { |o| connected_pins.count(o) > 1 }
    if repetitions.size == 1
      raise "The output `#{repetitions.first}' is connected multiple times"
    elsif repetitions.size > 1
      list = repetitions.join(', ')
      raise "These outputs are connected multiple times: #{list}"
    end
  end

  def connected_pins
    schema = @hash[:schema]
    wiring = schema.map(&:values).flatten
    wiring.map(&:values).flatten
  end

  def disconnected_pins_error(disconnected_pins, type)
    if disconnected_pins.size == 1
      raise "The #{type} `#{disconnected_pins.first}' is not connected"
    elsif disconnected_pins.size > 1
      list = disconnected_pins.join(", ")
      raise "The following #{type}s are not connected: #{list}"
    end
  end

end
