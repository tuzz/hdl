class HDL::Loader
  class << self

    def path
      @path ||= ["."]
    end
    attr_writer :path

    def load(name, options = {})
      memoize(name, options[:force]) do
        file = file_from_path(name)
        parse(name, File.read(file), :path => file)
      end
    end

    def parse(name, definition, options = {})
      raise NotImplementedError
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
        file = File.join(p, name) + ".hdl"
        return file if File.exists?(file)
      end

      err = "Could not locate chip definition for `#{name}'"
      raise FileNotFound, err
    end

    class ::FileNotFound < StandardError; end

  end
end
