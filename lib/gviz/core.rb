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
  
  def nodeset
    @nodes.values
  end

  def edgeset
    @edges.values
  end

  def node(id, attrs={})
    raise ArgumentError, '`id` must a symbol' unless id.is_a?(Symbol)
    Node[id, attrs].tap do |node|
      if exist = @nodes[node.id]
        exist.attrs.update(node.attrs)
      else
        @nodes.update(node.id => node)
      end
    end
  end

  def edge(id, attrs={})
    unless id.match(/._./)
      raise ArgumentError, '`id` must a symbol in which node names joined with "_"'
    end
    Edge[id.intern, attrs].tap do |edge|
      if exist = @edges[id.intern]
        exist.attrs.update(edge.attrs)
      else
        @edges.update(edge.id => edge)
        create_nodes
      end
    end
  end

  def nodes(attrs)
    @gnode_attrs.update(attrs)
  end

  def edges(attrs)
    @gedge_attrs.update(attrs)
  end

  def global(attrs)
    @graph_attrs.update(attrs)
  end

  def subgraph(&blk)
    Gviz.new("cluster#{subgraphs.size}", :subgraph).tap do |graph|
      subgraphs << graph
      graph.instance_eval &blk
    end
  end
  
  def graph(&blk)
    instance_eval(&blk)
    self
  end

  def add(*nodes_or_routes)
    nodes_or_routes.each do |unit|
      case unit
      when Hash
        unit.each do |sts, eds|
          Array(sts).product(Array(eds))
                    .each { |st, ed| edge([st,ed].join('_').intern) }
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
end
