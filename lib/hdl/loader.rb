class HDL::Loader
  class << self

    def path
      @path ||= ["."]
    end
    attr_writer :path

    def load(name, options = {})
      memoize(name, options[:force]) do
        name = name.to_s

        if (d = options[:definition])
          raw = d
          path = nil
        else
          file = file_from_path(name)
          raw  = file.read
          path = file.path
        end

        data = HDL::Parser.parse(raw)

        if data[:table]
          klass = HDL::TableChip
        else
          klass = HDL::SchemaChip
        end

        klass.new(name, path, data)
      end
    end

    private
    def memoize(key, override, &block)
      @memo ||= {}
      key = key.to_s

      if @memo.has_key?(key) && !override
        @memo[key]
      else
        @memo[key] = yield
      end
    end

    def file_from_path(name)
      path.each do |p|
        q = File.join(p, name) + ".hdl"
        return File.new(q) if File.exists?(q)
      end

      err = "Could not locate chip definition for `#{name}'"
      raise FileNotFound, err
    end

    class ::FileNotFound < StandardError; end

  end
end
