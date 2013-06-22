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
    memoize(pins) do
      check_pins!(pins)
      row = find_row(pins)
      select_outputs(row)
    end
  end

  private
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
