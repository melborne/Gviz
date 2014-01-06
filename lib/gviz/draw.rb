module Draw
  def circle(id, x:0, y:0, r:1, color:"black", fillcolor:"white")
    pos = "#{x},#{y}!"
    attrs = {pos:pos, width:r, color:color, fillcolor:fillcolor}
    global(layout:"neato")
    node(id, attrs)
  end
end