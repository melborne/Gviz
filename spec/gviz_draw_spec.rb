require "spec_helper"

describe Gviz do
  let(:gv) { Gviz.new }

  describe "#circle" do
    let(:defo_attrs) { {shape:"circle", pos:"0,0!", width:1, label:"", color:"black", fillcolor:"#FFFFFF00"} }
    context 'without attributes' do
      it 'returns a circle node with default attributes' do
        circle = gv.circle(:a)
        expect(circle).to be_a_instance_of Gviz::Node
        expect(circle.id).to eq :a
        expect(circle.attrs).to eq defo_attrs
      end
    end

    context 'with some attributes' do
      it 'returns a circle node with attributes' do
        circle = gv.circle(:a, x:10, y:-20, r:1, fillcolor:"green", label:"a")
        attrs = defo_attrs.merge(pos:"10,-20!", width:2, label:"a", fillcolor:"green")
        expect(circle.attrs).to eq attrs
      end

      it 'overwrites shape and pos attrs if they are passed' do
        circle = gv.circle(:a, shape:"box", pos:"10,10!")
        expect(circle.attrs).to eq defo_attrs
      end
    end
  end
end
