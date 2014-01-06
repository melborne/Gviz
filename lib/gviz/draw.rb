module Draw
  def circle(id, x:0, y:0, r:0.5, **attrs)
    attrs = {label:"", color:"black", fillcolor:"#FFFFFF00"}.merge(attrs)
    attrs.update(shape:"circle", pos:"#{x},#{y}!", width:r*2)
    global(layout:"neato")
    nodes(style:"filled")
    node(id, attrs)
  end
end