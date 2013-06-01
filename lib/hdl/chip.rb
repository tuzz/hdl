class HDL::Chip

  attr_reader :name, :path, :inputs, :outputs

  def initialize(name, path, data)
    @name    = name.to_s
    @path    = path
    @inputs  = data[:inputs]
    @outputs = data[:outputs]
  end

end
