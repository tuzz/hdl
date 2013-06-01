class HDL::Loader
  class << self

    def path
      @path ||= ["."]
    end
    attr_writer :path

    def load(name, options = {})
      memoize(name, options[:force]) do
        name = name.to_s

        file = file_from_path(name)
        data = HDL::Parser.parse(file.read)

        if data[:table]
          klass = HDL::TableChip
        else
          klass = HDL::SchemaChip
        end

        klass.new(name, file.path, data)
      end
    end

    private
    def memoize(key, override, &block)
      @memo ||= {}

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
