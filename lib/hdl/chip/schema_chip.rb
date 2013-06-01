class HDL::SchemaChip < HDL::Chip

  attr_reader :name, :path, :inputs, :outputs

  def initialize(name, path, data)
    @name    = name.to_s
    @path    = path
    @inputs  = data[:inputs]
    @outputs = data[:outputs]
    @schema  = data[:schema]

    create_dependencies
    load_dependencies(:dependents)
  end

  def primitive?
    false
  end

  def internal
    wiring_values - inputs - outputs - [true, false]
  end

  def dependents
    load_dependencies(:dependents)
  end

  def dependees
    load_dependencies(:dependees)
  end

  private
  def create_dependencies
    @schema.map(&:keys).flatten.each do |dep|
      HDL::Dependency.create(name, dep.to_s)
    end
  end

  def load_dependencies(type)
    deps = HDL::Dependency.send("#{type}_for", name)
    deps.map { |d| HDL::Loader.load(d) }
  end

  def wiring
    @schema.map(&:values).flatten
  end

  def wiring_values
    wiring.map(&:values).flatten.uniq
  end

end
