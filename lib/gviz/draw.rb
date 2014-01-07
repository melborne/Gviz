module Draw
  def ellipse(id, x:0, y:0, **attrs)
    draw_init
    attrs = {label:"", color:"black", fillcolor:"#FFFFFF00"}.merge(attrs)
    attrs.update(shape:"ellipse", pos:"#{x},#{y}!")
    node(id, attrs)
  end

  def circle(id, x:0, y:0, r:0.5, **attrs)
    attrs.update(width:r*2, height:r*2)
    ellipse(id, x:x, y:y, **attrs)
  end

  def square(id, x:0, y:0, **attrs)
    w, h = %i(width height).map { |at| attrs.delete at }
    size = w || h || 1
    attrs.update(width:size, height:size)
    rect(id, x:x, y:y, **attrs)
  end

  def point(id, x:0, y:0, **attrs)
    draw_init
    attrs.update(shape:"point", pos:"#{x},#{y}!")
    node(id, attrs)
  end

  def line(id, from:[0,0], **attrs)
    draw_init
    unless to = attrs.delete(:to)
      raise ArgumentError, "Argument 'to' is required"
    end
    n1_id, n2_id = [1, 2].map { |i| "#{id}#{i}".to_id }
    point(n1_id, x:from[0], y:from[1],
          color:"#FFFFFF00", fillcolor:"#FFFFFF00")
    point(n2_id, x:to[0], y:to[1],
          color:"#FFFFFF00", fillcolor:"#FFFFFF00")
    attrs.update(arrowhead:"none")
    edge(:"#{n1_id}_#{n2_id}", attrs)
  end

  ["rect", "box", "polygon", "oval", "egg", "triangle", "plaintext", "diamond", "trapezium", "house", "pentagon", "hexagon", "septagon", "octagon", "doublecircle", "doubleoctagon", "invtriangle", "invtrapezium", "invhouse", "Mdiamond", "Msquare", "Mcircle", "rectangle", "none", "note", "tab", "folder", "box3d", "component", "promoter", "cds", "terminator", "utr", "primersite", "fivepoverhang", "threepoverhang", "noverhang", "assembly", "signature", "insulator", "rnastab", "proteasesite", "proteinstab", "rpromoter", "rarrow", "larrow", "lpromoter"].each do |shape|
    define_method(shape) do |id, x:0, y:0, **attrs|
      draw_init
      attrs = {label:"", color:"black", fillcolor:"#FFFFFF00"}.merge(attrs)
      attrs.update(shape:shape, pos:"#{x},#{y}!")
      node(id, attrs)
    end
  end

  private
  def draw_init
    global(layout:"neato")
    nodes(style:"filled")
  end
end