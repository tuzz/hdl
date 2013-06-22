class HDL::TableChip < HDL::Chip

  def initialize(name, path, data)
    super
    @table = data[:table]
  end

  def internal
    []
  end

  def components
    {}
  end

  def primitive?
    true
  end

  def evaluate(pins = {})
    memoize(pins) do
      check_pins!(pins)
      row = find_row(pins)
      row ||= dnf_for(pins)
      select_outputs(row)
    end
  end

  private
  def find_row(pins)
    @table.detect do |row|
      inputs.all? { |i| row[i] == pins[i] }
    end
  end

  def select_outputs(row)
    filtered = row.select { |p, _| outputs.include?(p) }
    Hash[filtered]
  end

  def dnf_for(pins)
    outputs.inject({}) do |hash, out|
      true_rows = @table.select { |row| row[out] }

      clauses = true_rows.map do |row|
        clause = clause_for(row, pins)
      end

      clauses.reject! { |c| c.any? { |t| t == false } }

      hash.merge(out => expression_for(clauses))
    end
  end

  def clause_for(row, pins)
    row = row.select { |k, v| inputs.include?(k) }
    row = Hash[row]

    terms = inputs.map do |input|
      term_for(input, row, pins)
    end

    terms.reject { |t| t == true }
  end

  def term_for(input, row, pins)
    bool = row[input]
    term = pins[input]

    if bool
      term
    elsif [true, false].include?(term)
      !term
    else
      "NOT(#{term})"
    end
  end

  def expression_for(clauses)
    expr = clauses.map { |c| c.join(" AND ") }.join(" OR ")
    simplify(expr)
  end

  def simplify(expression, previous = nil)
    this = expression.dup

    # TODO

    # Simplify until no improvements can be made.
    if this == previous
      this
    else
      simplify(this, this)
    end
  end

end
