class HDL::Parser
  def self.parse(definition)
    parser = HDLParser.new

    ast = parser.parse(definition)
    if ast.nil?
      raise ParseError, parser.failure_reason
    end

    structured_data = ast.structured
    Validator.validate!(structured_data)

    structured_data
  end

  class ::ParseError < StandardError; end
end
