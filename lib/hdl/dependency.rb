class HDL::Dependency
  class << self

    # dependee depends on dependent

    def create(dependee, dependent)
      check_for_cycles!(dependee, dependent)
      set << { dependee => dependent }
    end

    def all
      set
    end

    def where(filter = {})
      scope = all

      if (f = filter[:dependee])
        scope = scope.select { |h| h.keys.first == f }
      end

      if (f = filter[:dependent])
        scope = scope.select { |h| h.values.first == f }
      end


      scope
    end

    # What does the dependee depend on?
    def dependents_for(dependee)
      recursive_ancestors_for(dependee, :dependee, :values)
    end

    # What depends on the dependent?
    def dependees_for(dependent)
      recursive_ancestors_for(dependent, :dependent, :keys)
    end

    private
    def set
      @dependencies ||= Set.new
    end

    def check_for_cycles!(dependee, dependent)
      if dependee == dependent
        err = "'#{dependee}` cannot depend on itself"
      elsif dependees_for(dependee).include?(dependent)
        err = "'#{dependee}` and '#{dependent}` depend on each other"
      end

      raise CircularError, err if err
    end

    def recursive_ancestors_for(object, type, side_of_hash)
      hashes = where(type => object)
      children = hashes.map(&side_of_hash).flatten

      ancestors = children.to_set
      children.each do |c|
        ancestors += recursive_ancestors_for(
          c, type, side_of_hash
        )
      end
      ancestors.to_a
    end

    class ::CircularError < StandardError; end
  end
end
