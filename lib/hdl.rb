module HDL
  def self.path
    []
  end
end

require "polyglot"
require "treetop"
require "hdl/tree_walker.rb"
require "hdl/grammar/vars"
require "hdl/grammar/pins"
require "hdl/grammar/table"
require "hdl/grammar/schema"
