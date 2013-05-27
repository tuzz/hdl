module HDL
  class << self

    def version
      "0.0.0"
    end

    def path
      @path ||= ["."]
    end
    attr_writer :path

    def load(name)
      file = file_from_path(name)
      parse(name, File.read(file), :path => file)
    end

    def parse(name, definition, options = {})
      raise NotImplementedError
    end

    private
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
