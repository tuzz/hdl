module HDL
  class << self

    def version
      "1.0.1"
    end

    def path
      Loader.path
    end

    def load(name)
      Loader.load(name, :force => true)
    end

    def parse(name, definition)
      Loader.load(name,
        :force => true,
        :definition => definition
      )
    end

  end
end
