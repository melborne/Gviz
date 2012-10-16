class Gviz::Edge < Struct.new(:id, :attrs)
  attr_reader :st, :ed, :seq, :st_port, :ed_port
  def initialize(id, attrs={})
    raise ArgumentError, "edge `attrs` must a hash" unless attrs.is_a?(Hash)
    id, @st, @ed, @seq, @st_port, @ed_port = parse_id(id)
    super(id, attrs)
  end

  def to_s
    stp = ":#{st_port}" if st_port
    edp = ":#{ed_port}" if ed_port
    "#{st}#{stp} -> #{ed}#{edp}"
  end

  def nodes
    [st, ed]
  end

  private
  def parse_id(id)
    unless id.match(/._./)
      raise ArgumentError, 'edge `id` must a symbol in which node names joined with "_"'
    end
    if id.match(/[^\d\w:-]/)
      raise ArgumentError, "edge `id` must not include other than ASCII words, colon or minus"
    end
    st, ed, seq = "#{id}".split('_')
    st, st_port = st.split(':').map(&:intern)
    ed, ed_port = ed.split(':').map(&:intern)
    id = seq ? :"#{st}_#{ed}_#{seq}" : :"#{st}_#{ed}"
    [id, st, ed, seq.to_i, st_port, ed_port]
  end
end

