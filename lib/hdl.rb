module HDL
  def self.path
    []
  end
end

require "set"

require "polyglot"
require "treetop"

require "hdl/parser"
require "hdl/parser/validator"
require "hdl/parser/tree_walker.rb"
require "hdl/parser/grammar/vars"
require "hdl/parser/grammar/pins"
require "hdl/parser/grammar/table"
require "hdl/parser/grammar/schema"
require "hdl/parser/grammar/hdl"
