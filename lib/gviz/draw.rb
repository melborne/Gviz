module Draw
  def ellipse(id, x:0, y:0, **attrs)
    draw_init
    attrs = {label:"", color:"black", fillcolor:"#FFFFFF00"}.merge(attrs)
    attrs.update(shape:"ellipse", pos:"#{x},#{y}!")
    node(id, attrs)
  end

  def circle(id, x:0, y:0, r:0.5, **attrs)
    attrs.update(width:r*2)
    ellipse(id, x:x, y:y, **attrs)
  end

  def rect(id, x:0, y:0, **attrs)
    draw_init
    attrs = {label:"", color:"black", fillcolor:"#FFFFFF00"}.merge(attrs)
    attrs.update(shape:"rect", pos:"#{x},#{y}!")
    node(id, attrs)
  end

  def square(id, x:0, y:0, **attrs)
    w, h = %i(width height).map { |at| attrs.delete at }
    size = w || h
    attrs.update(width:size) if size
    rect(id, x:x, y:y, **attrs)
  end

  private
  def draw_init
    global(layout:"neato")
    nodes(style:"filled")
  end
end