# Arrow Varieties
require_relative "../lib/gviz"

arrows = DATA.lines.map(&:chomp).reject { |l| l.empty? }

g = Gviz.new

g.graph do
  arrows.each_slice(6).with_index do |gr, i|
    gr.push i
    gr.each_cons(2) do |a, b|
      edge "#{a}_#{b}", arrowhead: a, label: a
    end
  end
  nodes(color:'orchid', shape:'circle', label:"Arrow")
end

puts g

__END__
box
lbox
rbox
obox
olbox
orbox
crow
lcrow
rcrow
diamond
ldiamond
rdiamond
odiamond
oldiamond
ordiamond
dot
odot
inv
linv
rinv
oinv
olinv
orinv
none
normal
lnormal
rnormal
onormal
olnormal
ornormal
tee
ltee
rtee
vee
lvee
rvee
curve
lcurve
rcurve