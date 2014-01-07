require "spec_helper"

describe Gviz do
  let(:gv) { Gviz.new }

  describe "#circle" do
    let(:defo_attrs) { {shape:"ellipse", pos:"0,0!", width:1, label:"", color:"black", fillcolor:"#FFFFFF00"} }
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

  describe "#ellipse" do
    let(:defo_attrs) { {shape:"ellipse", pos:"0,0!", label:"", color:"black", fillcolor:"#FFFFFF00"} }
    context 'without attributes' do
      it 'returns a ellipse node with default attributes' do
        ellipse = gv.ellipse(:a)
        expect(ellipse).to be_a_instance_of Gviz::Node
        expect(ellipse.id).to eq :a
        expect(ellipse.attrs).to eq defo_attrs
      end
    end

    context 'with some attributes' do
      it 'returns a ellipse node with attributes' do
        ellipse = gv.ellipse(:a, x:10, y:-20, fillcolor:"green", label:"a", width:2, height:4)
        attrs = defo_attrs.merge(pos:"10,-20!", width:2, height:4, label:"a", fillcolor:"green")
        expect(ellipse.attrs).to eq attrs
      end

      it 'overwrites shape and pos attrs if they are passed' do
        ellipse = gv.ellipse(:a, shape:"box", pos:"10,10!")
        expect(ellipse.attrs).to eq defo_attrs
      end
    end
  end

  describe "#rect" do
    let(:defo_attrs) { {shape:"rect", pos:"0,0!", label:"", color:"black", fillcolor:"#FFFFFF00"} }
    context 'without attributes' do
      it 'returns a rect node with default attributes' do
        rect = gv.rect(:a)
        expect(rect).to be_a_instance_of Gviz::Node
        expect(rect.id).to eq :a
        expect(rect.attrs).to eq defo_attrs
      end
    end

    context 'with some attributes' do
      it 'returns a rect node with attributes' do
        rect = gv.rect(:a, x:10, y:-20, fillcolor:"green", label:"a", width:2, height:4)
        attrs = defo_attrs.merge(pos:"10,-20!", width:2, height:4, label:"a", fillcolor:"green")
        expect(rect.attrs).to eq attrs
      end
    end
  end

  describe "#square" do
    let(:defo_attrs) { {shape:"rect", pos:"0,0!", label:"", color:"black", fillcolor:"#FFFFFF00"} }
    context 'without attributes' do
      it 'returns a square node with default attributes' do
        square = gv.square(:a)
        expect(square.attrs).to eq defo_attrs
      end
    end

    context 'with some attributes' do
      it 'returns a square node with attributes' do
        square = gv.square(:a, x:10, y:-20, fillcolor:"green", label:"a", width:2)
        attrs = defo_attrs.merge(pos:"10,-20!", width:2, label:"a", fillcolor:"green")
        expect(square.attrs).to eq attrs
      end
    end
  end

  describe "#point" do
    let(:defo_attrs) { {shape:"point", pos:"0,0!"} }
    context 'without attributes' do
      it 'returns a point node with default attributes' do
        point = gv.point(:a)
        expect(point.attrs).to eq defo_attrs
      end
    end

    context 'with some attributes' do
      it 'returns a point node with attributes' do
        point = gv.point(:a, x:10, y:-20, color:"green", width:0.1)
        attrs = defo_attrs.merge(pos:"10,-20!", width:0.1, color:"green")
        expect(point.attrs).to eq attrs
      end
    end
  end

  describe "#line" do
    it 'generate an edge between two points' do
      line = gv.line(:a, from:[50,50], to:[100,100])
      expect(gv.nodeset.size).to eq 2
      expect(gv.edgeset.size).to eq 1
      n1, n2 = gv.nodeset
      expect(n1.attrs).to eq(shape:"point", pos:"50,50!")
      expect(n2.attrs).to eq(shape:"point", pos:"100,100!")
      expect(line.id).to eq :"#{n1.id}_#{n2.id}"
    end

    context 'without from or to arguments' do
      it 'returns [0,0] without "from" argument' do
        line = gv.line(:a, to:[100,100])
        n1, n2 = gv.nodeset
        expect(n1.attrs).to eq(shape:"point", pos:"0,0!")
        expect(n2.attrs).to eq(shape:"point", pos:"100,100!")
      end

      it 'raise an ArgumentError without "to" argument' do
        expect{ gv.line(:a, from:[0,0]) }.to raise_error ArgumentError
      end
    end
  end
end
