# encoding: UTF-8
require "gviz/graphviz_attrs"
require "gviz/draw"

class Gviz
  include Draw
end

# +Graph+ fuction is a shortcut method of `Gviz#graph`.
def Graph(name=:G, type=:digraph, &blk)
  Gviz.new(name, type).graph(&blk)
end

# This value will be changed to ':graph' only when Graph initiate with :graph type.
# then effect globally to edge connectors from '->' to '--'.
$graph_type = :digraph

%w(core node edge version system_extension command).each do |lib|
  require 'gviz/' + lib
end
