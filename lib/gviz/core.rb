class Gviz
  attr_reader :gnode_attrs, :gedge_attrs, :graph_attrs, :subgraphs, :ranks
  def initialize(name=:G, type=:digraph)
    @name, @type = name, type
    @edges = {}
    @nodes = {}
    @gnode_attrs = {}
    @gedge_attrs = {}
    @graph_attrs = {}
    @subgraphs = []
    @ranks = []
  end
  
  # Access to all defined node objects.
  def nodeset
    @nodes.values
  end

  # Access to all defined edge objects.
  def edgeset
    @edges.values
  end

  # Define a node or update a node attributes.
  # The first argument is `id` of the node which must a symbol form.
  #
  #   node(:a, color:'red', shape:'circle')
  #
  def node(id, attrs={})
    Node[id, attrs].tap do |node|
      if exist = @nodes[node.id]
        exist.attrs.update(node.attrs)
      else
        @nodes.update(node.id => node)
      end
    end
  end

  # Difine a edge or update a edge attributes.
  # The first argument is `id` of the edge, which is a symbol or string constructed
  # from two nodes joined with '_'(underscore).
  #
  #   edge(:a_b, color:'red')
  #
  # The corresponding nodes will be defined if these are not exist.
  #
  # When `id` includes '*'(asterisk), multiple edges are updated.
  #
  #   add(:a => [:b, :c])
  #   edge('a_*', arrowhead:'none')
  #
  # is equivalent to:
  #
  #   edge(:a_b, arrowhead:'none')
  #   edge(:a_c, arrowhead:'none')
  #
  # You can draw two or more edges between a pair of nodes,
  # by adding a identifier with a underscore after the edge id.
  #
  #   gv.edge(:a_b)
  #   gv.edge(:a_b_1)
  #
  # This create two nodes between a, b nodes.
  #
  # You can define a endpoint to a node, by adding a point identifier
  # with a colon after the each node. You must specify the identifiers
  # it the label of the corresponding nodes.
  #
  #   gv.edge("a:x_b:y")
  #   gv.node(:a, label:"<x> 1 | 2 | 3")
  #   gv.node(:b, label:"4 | 5 |<y> 6")
  #
  # The edge 'a-b' joins 1 of the node 'a' with 6 of the node 'b'.
  def edge(id, attrs={})
    if md = id.match(/\*/)
      return multi_edge(md, attrs)
    end

    Edge[id, attrs].tap do |edge|
      if exist = @edges[id.intern]
        exist.attrs.update(edge.attrs)
      else
        @edges.update(edge.id => edge)
        create_nodes
      end
    end
  end

  # Define all nodes attributes.
  def nodes(attrs)
    @gnode_attrs.update(attrs)
  end

  # Define all edges attributes.
  def edges(attrs)
    @gedge_attrs.update(attrs)
  end

  # Define graph global attributes.
  def global(attrs)
    @graph_attrs.update(attrs)
  end

  # Define subgraph.
  #
  #   subgraph do
  #     global label:sub1
  #     add :a => :b
  #   end
  #
  def subgraph(&blk)
    Gviz.new("cluster#{subgraphs.size}", :subgraph).tap do |graph|
      subgraphs << graph
      graph.instance_eval &blk
    end
  end
  
  # +graph+ is a shorcut method.
  #
  #   gv = Gviz.new
  #   gv.graph do
  #     add :a => :b
  #     node :a, color:'red'
  #   end
  #
  # is equivalent to:
  #
  #   gv = Gviz.new
  #   gv.add :a => :b
  #   gv.node :a, color:'red'
  #
  def graph(&blk)
    instance_eval(&blk)
    self
  end

  # Define nodes or routes(node-edge combinaitons).
  # When an argument is a symbol, a node is defined.
  #
  #   add :a, :b
  #
  # is equivalent to:
  #
  #   node :a
  #   node :b
  #
  # When an argument is a hash, edges are defined.
  #
  #   add :a => [:b, :c], :c => :d
  #
  # is equivalent to:
  #
  #   edge :a_b
  #   edge :a_c
  #   edge :c_d
  #
  def add(*nodes_or_routes)
    nodes_or_routes.each do |unit|
      case unit
      when Hash
        unit.each do |sts, eds|
          Array(sts).product(Array(eds))
                    .each { |st, ed| edge "#{st}_#{ed}" }
        end
      when Symbol
        node(unit)
      else
        raise ArgumentError, 'pass nodes in symbol or edges in hash'
      end
    end
    self
  end
  alias :route :add

  # Define a rank to nodes.
  # :same, :min, :max, :source and :sink are acceptable types.
  #
  #   rank(:same, :a, :b)
  #
  def rank(type, *nodes)
    types = [:same, :min, :max, :source, :sink]
    unless types.include?(type)
      raise ArgumentError, "type must match any of #{types.join(', ')}"
    end
    @ranks << [type, nodes]
  end

  def to_s
    result = []
    tabs = "  "
    result << "#{@type} #{@name} {"

    unless graph_attrs.empty?
      result << tabs + build_attrs(graph_attrs, false).join(";\n#{tabs}") + ";"
    end

    unless gnode_attrs.empty?
      result << tabs + "node#{build_attrs(gnode_attrs)};"
    end
    
    unless gedge_attrs.empty?
      result << tabs + "edge#{build_attrs(gedge_attrs)};"
    end
    
    @nodes.values.each do |node|
      result << tabs + "#{node.id}#{build_attrs(node.attrs)};"
    end

    @edges.values.each do |edge|
      result << tabs + "#{edge}#{build_attrs(edge.attrs)};"
    end

    subgraphs.each do |graph|
      graph.to_s.lines do |line|
        result << tabs + line.chomp
      end
    end

    @ranks.each do |type, nodes|
      result << tabs + "{ rank=#{type}; #{nodes.join('; ')}; }"
    end
    
    result << "}\n"
    result.join("\n")
  end

  # Create a graphviz dot file. When an image type is specified,
  # the image is also created.
  def save(path, type=nil)
    File.open("#{path}.dot", "w") { |f| f.puts self }
    system "dot -T#{type} #{path}.dot -o #{path}.#{type}" if type
  end
  
  private
  def create_nodes
    # only create unregistered nodes
    ids = @edges.values.flat_map(&:nodes).uniq - @nodes.keys
    ids.each { |id| node(id) }
    @nodes
  end

  def build_attrs(attrs, join=true)
    return nil if attrs.empty?
    arr = attrs.map { |k, v| %(#{k}="#{v}").gsub("\n", "\\n") }
    join ? '[' + arr.join(',') + ']' : arr
  end

  def multi_edge(md, attrs)
    st = (md.pre_match + md.post_match).delete('_')
    edges = edgeset.select { |edge| edge.nodes.include? st.intern }
    edges.each { |eg| edge eg.id, attrs }
  end
end
