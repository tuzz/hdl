class HDL::Parser::Validator

  def self.validate!(hash)
    new(hash).validate!
  end

  def initialize(hash)
    @hash = hash
  end

  def validate!
    InputValidator.validate!(@hash)

    if @hash[:schema]
      validator = SchemaValidator
    else
      validator = TableValidator
    end

    validator.validate!(@hash)
  end

  private
  def raise(string)
    super(ParseError.new(string))
  end

end
