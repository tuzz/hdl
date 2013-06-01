class HDL::PrimitiveChip

  attr_reader :name, :path, :inputs, :outputs

  def internal;   [] end
  def components; [] end
  def primitives; [] end
  def dependents; [] end

  def primitive?
    true
  end

  def initialize(name, path, data)
    @name    = name.to_sym
    @path    = path
    @inputs  = data[:inputs]
    @outputs = data[:outputs]
    @table   = data[:table]
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
