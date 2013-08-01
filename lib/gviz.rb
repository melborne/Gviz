# encoding: UTF-8
class Gviz
end

# +Graph+ fuction is a shortcut method of `Gviz#graph`.
def Graph(name=:G, type=:digraph, &blk)
  Gviz.new(name, type).graph(&blk)
end

%w(core node edge version system_extension graphviz_attrs command).each do |lib|
  require_relative 'gviz/' + lib
end
