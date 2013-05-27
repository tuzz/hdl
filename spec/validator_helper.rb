module ValidatorHelper
  def t
    true
  end

  def f
    false
  end

  def valid(array)
    array.each do |hash|
      expect { klass.validate!(hash) }.to_not raise_error
    end
  end

  def invalid(array)
    array.each do |hash|
      expect { klass.validate!(hash) }.to raise_error,
        "no error raised for: #{hash.inspect}"
    end
  end
end
