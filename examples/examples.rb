require_relative "../lib/gviz"

simple = Gviz.new
simple.graph do
  route :main => [:init, :parse, :cleanup, :printf]
  route :init => :make
  route :parse => :execute
  route :execute => [:make, :compare, :printf]
end
# puts simple

enhanced = Gviz.new
enhanced.graph do
  route :main => [:init, :parse, :cleanup, :printf]
  route :init => :make, :parse => :execute
  route :execute => [:make, :compare, :printf]
  node(:main, :shape => 'box')
  node(:compare, :shape => 'box', :style => 'filled', :color => '.7 .3 1.0')
  node(:make, :label => "make a\nstring")
  edge(:main_printf, :style => 'bold', :label => "100 times", :color => 'red', :weight => 8)
  edge(:main_parse, :weight => 8)
  edge(:main_init, :style => "dotted")
  edge(:execute_compare, :color => 'red')
end
# puts enhanced

polygonal = Gviz.new
polygonal.graph do
  route :a => :b, :b => [:c, :d]
  node(:a, :shape => 'polygon', :sides => 5, :peripheries => 3, :style => 'filled', :fillcolor => '#DA70D6')
  node(:c, :shape => 'polygon', :sides => 4, :skew => 0.4, :label => "hellow world", :peripheries => 2, :orientation => 20, :fontname => 'Helvetica', :fontcolor => '#DA70D6')
  node(:d, :shape => 'invtriangle')
  node(:e, :shape => 'polygon', :style => 'setlinewidth(8)', :sides => 4, :distortion => 0.7)
  edge(:b_d, :label => 'path to the world', :decorate => true, :labelfloat => true)
  edge(:a_b, :dir => 'both', :headport => 'se')
  edge(:a_b_1, :dir => 'back')
  global(:rankdir => "TB", :rankseq => 'equally')
end
# puts polygonal

record = Gviz.new
record.graph do
  nodes(:shape => 'record')
  route :st1 => [:st2, :st3]
  node(:st1, :label => "<f0> left|<f1> middle|<f2> right")
  node(:st2, :label => "<f0> one|<f1> two")
  node(:st3, :label => "hello\nworld|{b|{c|<here> d|e}|f}|g|h")
  edge("st1:f1_st2:f0")
  edge("st1:f2_st3:here")
end
# puts record

sub = Gviz.new
sub.graph do
  subgraph do
    nodes(style:'filled', color:'white')
    global(style:'filled', color:'lightgrey', label:'process #1')
    route(:a0 => :a1, :a1 => :a2, :a2 => :a3)
  end

  subgraph do
    nodes(style:'filled')
    global(color:'blue', label:'process #2')
    route(:b0 => :b1, :b1 => :b2, :b2 => :b3)
  end
  route :start => [:a0, :b0]
  route :a1 => :b3, :b2 => :a3, :a3 => [:a0, :end], :b3 => :end
  node(:start, shape:'Mdiamond')
  node(:end, shape:'Msquare')
end
puts sub