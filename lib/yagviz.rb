class Yagviz
  class Node < Struct.new(:id, :attrs)
    def initialize(id, attrs={})
      raise ArgumentError, "`id` must not include underscores" if id.match(/_/)
      super
    end

    def to_s
      "#{id}"
    end
  end

  class Edge < Struct.new(:id, :attrs)
    attr_reader :st, :ed, :seq
    def initialize(id, attrs={})
      raise ArgumentError, "`attrs` must a hash" unless attrs.is_a?(Hash)
      st, ed, seq = "#{id}".split('_')
      @st, @ed = [st, ed].map(&:intern)
      @seq = seq.to_i
      super
    end

    def to_s
      "#{st} -> #{ed}"
    end

    def nodes
      [st, ed]
    end
  end

  attr_reader :gnode_attrs, :gedge_attrs, :graph_attrs
  def initialize
    @edges = {}
    @nodes = {}
    @gnode_attrs = {}
    @gedge_attrs = {}
    @graph_attrs = {}
  end
  
  def nodeset
    @nodes.values
  end

  def edgeset
    @edges.values
  end

  def node(id, attrs={})
    raise ArgumentError, '`id` must a symbol' unless id.is_a?(Symbol)
    Node[id, attrs].tap { |node| @nodes.update(id => node) }
  end

  def edge(id, attrs={})
    unless id.is_a?(Symbol) && id.match(/._./)
      raise ArgumentError, '`id` must a symbol in which node names joined with "_"'
    end
    Edge[id, attrs].tap do |edge|
      @edges.update(id => edge)
      create_nodes
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
  
  def graph(&blk)
    instance_eval(&blk)
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

  def to_s
    result = []
    tabs = "  "
    result << "digraph {"

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
    
    result << "}\n"
    result.join("\n")
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

if __FILE__ == $0
  yag = Yagviz.new
  yag.graph do
    add(:main => [:printf, :parse, :init, :cleanup])
    add(:parse => :execute, :init => :make)
    add(:execute => [:printf, :compare, :make])
    node(:main, :shape => 'box')
    node(:make, :label => "make a\nstring")
    node(:compare, :shape => 'box', :style => 'filled', :color => ".7 .3 1.0")
    edge(:main_parse, :weight => 8)
    edge(:main_init, :style => 'dotted')
    edge(:main_printf, :style => 'bold', :label => "100 times", :color => 'red')
    edge(:execute_compare, :color => 'red')
  end
  puts yag
end

