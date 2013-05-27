class HDL::Parser::Validator::TableValidator < HDL::Parser::Validator

  def validate!
    headers!
    combinations!
  end

  private
  def headers!
    external_pins = @hash[:inputs] + @hash[:outputs]
    table_headers = @hash[:table].first.keys

    unless external_pins.to_set == table_headers.to_set
      raise "expecting table headers #{external_pins.join(",")}, got #{table_headers.join(",")}"
    end
  end

  def combinations!
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
