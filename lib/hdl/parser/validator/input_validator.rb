class HDL::Parser::Validator::InputValidator < HDL::Parser::Validator

  def validate!
    intersection = @hash[:inputs] & @hash[:outputs]
    if intersection.size == 1
      raise "`#{intersection.first}' is both an input and an output"
    elsif intersection.size > 1
      pins = intersection.map { |p| "`#{p}'" }.join(", ")
      raise "These pins are both inputs and outputs: #{pins}"
    end
  end

end
