class TreeWalker
  def self.walk(element, method)
    array = []

    if element.respond_to?(method)
      array << element.send(method)
    elsif !element.terminal?
      array += element.elements.map { |e| walk(e, method) }.flatten(1)
    end

    array
  end
end
