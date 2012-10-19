# encoding: UTF-8
class Gviz
  # Returns Graphviz attributes. Acceptable attributes are:
  # :Graph, :Node, :Edge, :Subgraph or :Cluster
  def self.ATTR(target)
    target = target[0].upcase
    name = %w(Graph Node Edge Subgraph Cluster).detect { |n| n[0] == target }
    header = ["- #{name} attributes (type|default|minimum|notes) -"]
    body = ATTR_BASE.select { |attr| attr[0].include? target.intern }
                    .map { |_, attr, *desc| "#{attr} (#{desc.join(" | ")})" }
    [header] + body
  end
end

# +Graph+ fuction is a shortcut method of `Gviz#graph`.
def Graph(name=:G, type=:digraph, &blk)
  Gviz.new(name, type).graph(&blk)
end


%w(core node edge version system_extension graphviz_attrs).each do |lib|
  require_relative 'gviz/' + lib
end
