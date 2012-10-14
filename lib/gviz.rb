# encoding: UTF-8
class Gviz
end

def Graph(name=:G, type=:digraph, &blk)
  Gviz.new(name, type).graph(&blk)
end

%w(core node edge version system_extension).each do |lib|
  require_relative 'gviz/' + lib
end
