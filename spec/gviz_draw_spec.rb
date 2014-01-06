require "spec_helper"

describe Gviz do
  let(:gv) { Gviz.new }

  describe "#circle" do
    before { @node = gv.circle(:a, x:1, y:2, r:10) }
    it 'generate a node with circle shape' do
      expect(@node).to be_a_instance_of Gviz::Node
      expect(@node.id).to eq :a 
      expect(@node.attrs).to eq({pos:"1,2!", width:10, color:"black",fillcolor:"white"})
    end
  end
end
