class HDL::TableChip < HDL::Chip

  def initialize(name, path, data)
    super
    @table = data[:table]
  end

  def internal
    []
  end

  def components
    {}
  end

  def primitive?
    true
  end

  def evaluate(pins = {})
    check_pins!(pins)

    row = find_row(pins)
    select_outputs(row)
  end

  private
  def check_pins!(pins)
    unless pins.keys.to_set == inputs.to_set
      err = "Expecting inputs #{inputs.inspect}, given #{pins.keys.inspect}"
      raise ArgumentError, err
    end
  end

  def find_row(pins)
    @table.detect do |row|
      inputs.all? { |i| row[i] == pins[i] }
    end
  end

  def select_outputs(row)
    filtered = row.select { |p, _| outputs.include?(p) }
    Hash[filtered]
  end

end
