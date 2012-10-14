class Gviz::Node < Struct.new(:id, :attrs)
  def initialize(id, attrs={})
    raise ArgumentError, "`id` must not include underscores" if id.match(/_/)
    super
  end

  def to_s
    "#{id}"
  end
end

