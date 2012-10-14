# encoding: UTF-8
require_relative "spec_helper"

describe Gviz::Node do
  describe ".new" do
    context "when only a symbol passed" do
      subject { Gviz::Node.new(:a) }
      it { should be_a_instance_of Gviz::Node }
      its(:id) { should be :a }
      its(:attrs) { should be_empty }
    end
    
    context "when only a string passed" do
      subject { Gviz::Node.new('a') }
      it { should be_a_instance_of Gviz::Node }
      its(:id) { should eq 'a' }
      its(:attrs) { should be_empty }
    end

    context "when a symbol and hash options passed" do
      opts = { shape:'circle', style:'filled' }
      subject { Gviz::Node.new(:a, opts) }
      its(:id) { should be :a }
      its(:attrs) { should eq opts }
    end

    context "when a symbol with underscore passed" do
      it "raise an error" do
        ->{ Gviz::Node.new(:a_b) }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    subject { Gviz::Node.new(:a, style:'filled').to_s }
    it { should eq "a" }
  end
end

describe Gviz::Edge do
  describe ".new" do
    context "when a symbol with an underscore passed" do
      subject { Gviz::Edge.new(:a_b) }
      it { should be_a_instance_of Gviz::Edge }
      its(:id) { should be :a_b }
      its(:st) { should be :a }
      its(:ed) { should be :b }
      its(:seq) { should eq 0 }
      its(:st_port) { should be_nil }
      its(:ed_port) { should be_nil }
      its(:to_s) { should eq "a -> b" }
    end

    context "when a string with an underscore passed" do
      subject { Gviz::Edge.new('a_b') }
      it { should be_a_instance_of Gviz::Edge }
      its(:id) { should be :a_b }
      its(:st) { should be :a }
      its(:ed) { should be :b }
      its(:seq) { should eq 0 }
      its(:st_port) { should be_nil }
      its(:ed_port) { should be_nil }
      its(:to_s) { should eq "a -> b" }
    end

    context "when a symbol with two underscores passed" do
      subject { Gviz::Edge.new('a_b_1') }
      it { should be_a_instance_of Gviz::Edge }
      its(:id) { should be :a_b_1 }
      its(:st) { should be :a }
      its(:ed) { should be :b }
      its(:seq) { should eq 1 }
      its(:st_port) { should be_nil }
      its(:ed_port) { should be_nil }
      its(:to_s) { should eq "a -> b" }
    end

    context "when a string with a colon passed" do
      subject { Gviz::Edge.new('a:x_b:y') }
      it { should be_a_instance_of Gviz::Edge }
      its(:id) { should be :a_b }
      its(:st) { should be :a }
      its(:ed) { should be :b }
      its(:seq) { should eq 0 }
      its(:st_port) { should be :x }
      its(:ed_port) { should be :y }
      its(:to_s) { should eq "a:x -> b:y" }
    end

    context "when a symbol and hash options passed" do
      opts = { style:'bold', color:'red' }
      subject { Gviz::Edge.new(:a_b, opts) }
      its(:id) { should be :a_b }
      its(:attrs) { should eq opts }
    end

    context "when a string with other than words or colon passed" do
      it "raise an error" do
        ->{ Gviz::Edge.new('a!b_c') }.should raise_error(ArgumentError)
      end
    end
  end
end

describe Gviz do
  let(:gv) { Gviz.new }

  describe "#node" do
    context "define a node" do
      before { gv.node(:a) }
      subject { gv.nodeset }
      its(:size) { should eql 1}
      its(:first) { should be_a_instance_of Gviz::Node }
    end

    context "define several nodes" do
      before do
        gv.node(:a)
        gv.node(:b)
      end
      subject { gv.nodeset }
      its(:size) { should eql 2 }
    end

    context "define a node with attrs" do
      subject { gv.node(:a, color:'blue', label:'hello') }
      its(:id) { should eql :a }
      its(:attrs) { should be { color:'blue', label:'hello' } }
    end

    context "update node attrs" do
      before do
        gv.node(:a, color:'red', label:'hello')
        gv.node(:a, color:'blue', shape:'box')
      end
      subject { gv.nodeset.first.attrs }
      it { should be { color:'blue', label:'hello', shape:'box' } }
    end

    context "when pass a string" do
      it "raise an error" do
        ->{ gv.node('a') }.should raise_error(ArgumentError)
      end
    end

    context "when pass a symbol with an underscore" do
      it "raise an error" do
        ->{ gv.node(:a_b) }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#edge" do
    context "define a edge" do
      before { gv.edge(:a_b) }
      subject { gv.edgeset }
      its(:size) { should eql 1}
      its(:first) { should be_a_instance_of Gviz::Edge }
    end

    context "update edge attrs" do
      before do
        gv.edge(:a_b, color:'blue', style:'bold')
        gv.edge(:a_b, color:'red')
      end
      subject { gv.edgeset.first }
      its(:attrs) { should be { color:'red', style:'bold'} }
    end

    context "define different edges with same name" do
      before do
        gv.edge(:a_b)
        gv.edge(:a_b_1)
      end
      subject { gv.edgeset }
      its(:size) { should eql 2 }
    end
  end

  describe "#add" do
    context "edges" do
      context "one to many" do
        before { gv.add :a => [:b, :c, :d] }
        subject { gv.edgeset }
        its(:size) { should eq 3 }
        describe "nodes" do
          subject { gv.nodeset }
          its(:size) { should eq 4 }
        end
      end

      context "many to many" do
        before { gv.add [:main, :sub] => [:a, :b, :c] }
        subject { gv.edgeset }
        its(:size) { should eq 6 }
        describe "nodes" do
          subject { gv.nodeset }
          its(:size) { should eq 5 }
        end
      end

      context "pass two routes" do
        before { gv.add :main => :sub, :sub => [:a, :b] }
        subject { gv.edgeset }
        its(:size) { should eq 3 }
        describe "nodes" do
          subject { gv.nodeset }
          its(:size) { should eq 4 }
        end
      end

      context "when call twice" do
        before do
          gv.add :main => :a, :a => [:c, :d]
          gv.add :main => :b, :b => [:e, :f]
        end
        subject { gv.edgeset }
        its(:size) { should eq 6 }
        describe "nodes" do
          subject { gv.nodeset }
          its(:size) { should eq 7 }
        end
      end
    end

    context "nodes" do
      context "one" do
        before { gv.add :a }
        subject { gv.nodeset }
        its(:size) { should eql 1 }
      end

      context "several" do
        before { gv.add :a, :b, :c }
        subject { gv.nodeset }
        its(:size) { should eql 3 }
      end

      context "pass a string" do
        it "raise an error" do
          ->{ gv.add 'a' }.should raise_error(ArgumentError)
        end
      end
    end
  end

  describe "#graph" do
    context "when add routes" do
      before do
        gv.graph do
          add :main => [:a, :b, :c]
          add :a => [:d, :e]
        end
      end
      subject { gv.edgeset }
      its(:size) { should eq 5 }
    end
  end

  describe "#subgraph" do
    context "when add one" do
      before do
        gv.subgraph { add :main => [:a, :b] }
      end
      subject { gv.subgraphs }
      its(:size) { should eq 1 }
    end

    context "when add one" do
      before do
        gv.subgraph { add :main => [:a, :b] }
        gv.subgraph { add :main => [:a, :b] }
      end
      subject { gv.subgraphs }
      its(:size) { should eq 2 }
    end

    context "it has a name other than `cluster**`" do
      it "raise an error" do
        ->{ gv.subgraph(:clu) {} }.should raise_error
      end
    end
  end

  describe "#nodes" do
    context "set node attributes" do
      opts = { style:"filled", color:"purple" }
      before { gv.nodes(opts) }
      subject { gv.gnode_attrs }
      it { should eql opts }
    end
    
    context "update node attributes" do
      opts1 = { style:"filled", color:"purple" }
      opts2 = { color:"red", shape:"box" }
      before do
        gv.nodes(opts1)
        gv.nodes(opts2)
      end
      subject { gv.gnode_attrs }
      it { should be { style:"filled", color:"red", shape:"box" } }
    end
  end

  describe "#edges" do
    context "set edge attributes" do
      opts = { style:"dotted", color:"purple" }
      before { gv.edges(opts) }
      subject { gv.gedge_attrs }
      it { should eq opts }
    end

    context "update edge attributes" do
      opts = { style:"dotted", color:"purple" }
      opts2 = { color:"red", arrowhead:"none" }
      before do
        gv.edges(opts)
        gv.edges(opts2)
      end
      subject { gv.gedge_attrs }
      it { should be { style:"dotted", color:"red", arrowhead:"none" } }
    end
  end

  describe "#global" do
    context "set graph attributes" do
      opts = { label:"A simple graph", rankdir:"LR" }
      before { gv.global(opts) }
      subject { gv.graph_attrs }
      it { should eq opts }
    end
  end

  describe "#rank" do
    context "set same" do
      before do
        gv.route(:a => [:b, :c], :b => [:d, :e])
        gv.rank(:same, :b, :d, :e)
      end
      subject { gv.ranks.first }
      it { should eq [:same, [:b, :d, :e]] }
    end
  end

  describe "#to_s" do
    context "without attrs" do
      before do
        gv.add :main => [:init, :parse]
        gv.add :init => :printf
      end
      subject { gv.to_s }
      it do
        should eq ~<<-EOS
          digraph G {
            main;
            init;
            parse;
            printf;
            main -> init;
            main -> parse;
            init -> printf;
          }
          EOS
      end
    end

    context "with node attrs" do
      before do
        gv.add :a => :b
        gv.node(:a, color:'red', style:'filled')
      end
      subject { gv.to_s }
      it do
        should eq ~<<-EOS
          digraph G {
            a[color="red",style="filled"];
            b;
            a -> b;
          }
          EOS
      end
    end

    context "with edge attrs" do
      before do
        gv.edge(:a_b, color:'red')
      end
      subject { gv.to_s }
      it do
        should eq ~<<-EOS
          digraph G {
            a;
            b;
            a -> b[color="red"];
          }
          EOS
      end
    end

    context "with 2 edges with different attrs" do
      before do
        gv.edge(:a_b, color:'red')
        gv.edge(:a_b_1, color:'blue')
      end
      subject { gv.to_s }
      it do
        should eq ~<<-EOS
          digraph G {
            a;
            b;
            a -> b[color="red"];
            a -> b[color="blue"];
          }
          EOS
      end
    end

    context "with global node attributes" do
      before do
        gv.nodes(shape:'box', style:'filled')
        gv.add(:a => :b)
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            node[shape="box",style="filled"];
            a;
            b;
            a -> b;
          }
          EOS
      end
    end

    context "with global edge attributes" do
      before do
        gv.edges(style:'dotted', color:'red')
        gv.add(:a => :b)
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            edge[style="dotted",color="red"];
            a;
            b;
            a -> b;
          }
          EOS
      end
    end

    context "with graph attributes" do
      before do
        gv.global(label:"A Simple Graph", rankdir:"LR")
        gv.add(:a => :b)
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            label="A Simple Graph";
            rankdir="LR";
            a;
            b;
            a -> b;
          }
          EOS
      end
    end

    context "when a label include `\\n`" do
      before { gv.node(:a, label:"hello\nworld") }
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            a[label="hello\\nworld"];
          }
          EOS
      end
    end

    context "when a label include unicode" do
      before { gv.node(:a, label:"こんにちは、世界！") }
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            a[label="こんにちは、世界！"];
          }
          EOS
      end
    end
    
    context "take ports on edges" do
      before do
        gv.route(:a => [:b, :c])
        gv.edge("a:n_c:f")
        gv.node(:a, label:"<n> a | b |<p> c")
        gv.node(:c, label:"<o> d | e |<f> f")
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            a[label="<n> a | b |<p> c"];
            b;
            c[label="<o> d | e |<f> f"];
            a -> b;
            a:n -> c:f;
          }
          EOS
      end
    end

    context "with subgraph" do
      before do
        gv.route(:a => :b)
        gv.subgraph { route :c => :d }
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            a;
            b;
            a -> b;
            subgraph cluster0 {
              c;
              d;
              c -> d;
            }
          }
          EOS
      end
    end

    context "with ranks" do
      before do
        gv.route(:a => [:b, :c], :b => [:d, :e])
        gv.rank(:same, :b, :d, :e)
        gv.rank(:min, :c)
      end
      subject { gv.to_s }
      it do
        should eql ~<<-EOS
          digraph G {
            a;
            b;
            c;
            d;
            e;
            a -> b;
            a -> c;
            b -> d;
            b -> e;
            { rank=same; b; d; e; }
            { rank=min; c; }
          }
          EOS
      end
    end
  end
end

describe '#Graph' do
  context "build a shortcut of Gviz.new.graph" do
    before do
      @gv = Graph(:X) do
        add :a => [:b, :c]
      end
    end
    subject { @gv }
    it { should be_a_instance_of Gviz }
    its(:to_s) do
      should eql ~<<-EOS
        digraph X {
          a;
          b;
          c;
          a -> b;
          a -> c;
        }
        EOS
    end
  end
end
