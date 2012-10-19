class Numeric
  # Return a normalized value of the receiver between 0.0 to 1.0.
  #
  #   5.norm(0..10).should eql 0.5
  #   7.norm(5..10).should eql 0.4
  #
  # When the target range specified, the result is adjusted to the range.
  #
  #   5.norm(0..10, 0..20).should eql 10.0
  #
  def norm(range, tgr=0.0..1.0)
    unit = (self - range.min) / (range.max - range.min).to_f
    unit * (tgr.max - tgr.min) + tgr.min
  end
end

class Object
  # Returns a uniq number of the object in symbol form.
  # This is used for creating ids of node or edge.
  def to_id
    to_s.hash.to_s.intern
  end
end

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end
