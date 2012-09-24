# Shape Varieties
require_relative "../lib/gviz"

shapes = DATA.lines.map(&:chomp).reject { |l| l.empty? }

g = Gviz.new

g.graph do
  nodes(style:'filled', fillcolor:'orchid')
  edges(arrowhead:'none')
  shapes.each { |shape| node shape.intern, shape: shape }

  shapes.each_slice(10) do |gr|
    gr.each_cons(2) do |a, b|
      route a.intern => b.intern
    end
  end
  edge(:circle_point, headlabel:'point')
end


puts g

__END__
box
polygon
ellipse
oval
circle
point
egg
triangle
plaintext
diamond
trapezium
parallelogram
house
pentagon
hexagon
septagon
octagon
doublecircle
doubleoctagon
tripleoctagon
invtriangle
invtrapezium
invhouse
Mdiamond
Msquare
Mcircle
rect
rectangle
square
none
note
tab
folder
box3d
component
promoter
cds
terminator
utr
primersite
restrictionsite
fivepoverhang
threepoverhang
noverhang
assembly
signature
insulator
ribosite
rnastab
proteasesite
proteinstab
rpromoter
rarrow
larrow
lpromoter
