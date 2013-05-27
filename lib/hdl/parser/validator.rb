class HDL::Parser::Validator

  def self.validate!(hash)
    new(hash).validate!
  end

  def initialize(hash)
    @hash = hash
  end

  def validate!
    inputs!
    @hash[:schema] ? schema! : table!
  end

  private
  def inputs!
    intersection = @hash[:inputs] & @hash[:outputs]
    if intersection.size == 1
      raise "`#{intersection.first}' is both an input and an output"
    elsif intersection.size > 1
      pins = intersection.map { |p| "`#{p}'" }.join(", ")
      raise "These pins are both inputs and outputs: #{pins}"
    end
  end

  def schema!

  end

  def table!
    table_headers!
    table_combinations!
  end

  def table_headers!
    external_pins = @hash[:inputs] + @hash[:outputs]
    table_headers = @hash[:table].first.keys

    unless external_pins.to_set == table_headers.to_set
      raise "expecting table headers #{external_pins.join(",")}, got #{table_headers.join(",")}"
    end
  end

  def table_combinations!
    inputs = @hash[:inputs]

    combi = @hash[:table].inject([]) do |acc, row|
      only_inputs = row.select { |k, _| inputs.include?(k) }
      acc + [Hash[only_inputs]]
    end

    repetitions = combi.select { |c| combi.count(c) > 1 }.uniq
    if repetitions.size == 1
      raise "The row for #{repetitions.first.inspect} appears multiple times"
    elsif repetitions.size > 1
      list = repetitions.map(&:inspect).join(', ')
      raise "These rows appear multiple times: #{list}"
    end

    required_size = 2 ** inputs.size
    given_size = combi.size
    unless given_size == required_size
      rows = given_size > 1 ? "rows were" : "row was"
      raise "#{given_size} #{rows} given, but #{required_size} rows are required"
    end
  end

end
