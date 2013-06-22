class HDL::Chip

  attr_reader :name, :path, :inputs, :outputs

  def initialize(name, path, data)
    @name    = name.to_s
    @path    = path
    @inputs  = data[:inputs]
    @outputs = data[:outputs]
  end

  def inspect
    "#<HDL::Chip #{name}>"
  end

  def primitives
    dependents.select { |d| d.primitive? }
  end

  def dependents
    load_dependencies(:dependents)
  end

  def dependees
    load_dependencies(:dependees)
  end

  private
  def load_dependencies(type)
    deps = HDL::Dependency.send("#{type}_for", name)
    deps.map { |d| HDL::Loader.load(d) }
  end

  def check_pins!(pins)
    unless pins.keys.to_set == inputs.to_set
      err = "Expecting inputs #{inputs.inspect}, given #{pins.keys.inspect}"
      raise ArgumentError, err
    end
  end

  def memoize(pins, &block)
    @memo ||= {}
    @memo[pins] ||= yield
  end

end
