class Numeric
  def norm(range, tgr=0.0..1.0)
    unit = (self - range.min) / (range.max - range.min).to_f
    unit * (tgr.max - tgr.min) + tgr.min
  end
end

class Object
  def to_id
    to_s.hash.to_s.intern
  end
end
