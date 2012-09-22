# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Yagviz do
  before(:each) do
    @yag = Yagviz.new
  end

  context "node" do
    it "add a node" do
      node = @yag.node(:a)
      node.should be_a_instance_of Yagviz::Node
      node.id.should eql :a
      node.attrs.should be_empty
      @yag.nodeset.map(&:id).should eql [:a]
    end

    it "add nodes" do
      @yag.node(:a)
      @yag.node(:b)
      @yag.nodeset.map(&:id).should eql [:a, :b]
    end

    it "add a node with attrs" do
      node = @yag.node(:a, :color => 'blue', :label => 'hello')
      node.should be_a_instance_of Yagviz::Node
      node.id.should eql :a
      node.attrs.should == {:color => 'blue', :label => 'hello'}
      @yag.nodeset.map(&:attrs).should eql [node.attrs]
    end

    it "add nodes with same name & different attrs" do
      @yag.node(:a, :color => 'blue', :label => 'hello')
      @yag.node(:a, :color => 'red')
      @yag.nodeset.first.attrs.should == {:color => 'red'}
    end

    it "raise an error with a string" do
      ->{ @yag.node('a') }.should raise_error(ArgumentError)
    end

    it "raise an error with a symbol which include underscores" do
      ->{ @yag.node(:a_b) }.should raise_error(ArgumentError)
    end
  end

  context "edge" do
    it "add a edge" do
      edge = @yag.edge(:a_b)
      edge.should be_a_instance_of Yagviz::Edge
      edge.st.should eql :a
      edge.ed.should eql :b
      edge.attrs.should be_empty
      @yag.edgeset.map(&:to_s).should eql ["a -> b"]
    end

    it "add a edge with attrs" do
      edge = @yag.edge(:a_b, :color => 'red', :arrowhead => 'none')
      edge.should be_a_instance_of Yagviz::Edge
      edge.st.should eql :a
      edge.ed.should eql :b
      edge.attrs.should == {:color => 'red', :arrowhead => 'none'}
      @yag.edgeset.map(&:to_s).should eql ["a -> b"]
    end

    it "overwrite same edge" do
      @yag.edge(:a_b)
      @yag.edge(:a_b, :color => 'red')
      @yag.edgeset.map(&:to_s).should eql ["a -> b"]
      @yag.edgeset.first.attrs.should == {:color => 'red'}
    end

    it "add different edges, but same name" do
      edge1 = @yag.edge(:a_b)
      edge2 = @yag.edge(:a_b_1)
      edge1.seq.should eql 0
      edge2.seq.should eql 1
      @yag.edgeset.map(&:to_s).should eql ["a -> b", "a -> b"]
    end

    it "raise an error with a string" do
      ->{ @yag.edge('a_b') }.should raise_error(ArgumentError)
    end
  end

  context "add" do
    context "edges" do
      it "one to many" do
        @yag.add :a => [:b, :c, :d]
        @yag.edgeset.map(&:to_s).should eql ['a -> b', 'a -> c', 'a -> d']
        @yag.nodeset.map(&:id).should eql [:a, :b, :c, :d]
      end

      it "many to many" do
        @yag.add [:main, :sub] => [:a, :b, :c]
        @yag.edgeset.map(&:to_s)
            .should eql ['main -> a', 'main -> b', 'main -> c',
                         'sub -> a',  'sub -> b',  'sub -> c']
        @yag.nodeset.map(&:id).should eql [:main, :a, :b, :c, :sub]
      end

      it "sequence" do
        @yag.add :main => :sub, :sub => [:a, :b]
        @yag.edgeset.map(&:to_s)
            .should eql ['main -> sub', 'sub -> a', 'sub -> b']
        @yag.nodeset.map(&:id).should eql [:main, :sub, :a, :b]
      end

      it "several sequences" do
        @yag.add :main => :a, :a => [:c, :d]
        @yag.add :main => :b, :b => [:e, :f]
        @yag.edgeset.map(&:to_s)
            .should eql ['main -> a', 'a -> c', 'a -> d',
                         'main -> b', 'b -> e', 'b -> f']
        @yag.nodeset.map(&:id).should eql [:main, :a, :c, :d, :b, :e, :f]
      end
    end

    context "nodes" do
      it "add a node" do
        @yag.add :a
        @yag.nodeset.map(&:id).should eql [:a]
      end

      it "add several nodes" do
        @yag.add :a, :b, :c
        @yag.nodeset.map(&:id).should eql [:a, :b, :c]
      end

      it "raise error with a string" do
        ->{ @yag.add 'a' }.should raise_error(ArgumentError)
      end
    end
  end

  context "graph" do
    it "add routes" do
      @yag.graph do
        add :main => [:a, :b, :c]
        add :a => [:d, :e]
      end
      @yag.edgeset.map(&:to_s)
          .should eql ['main -> a', 'main -> b', 'main -> c',
                       'a -> d', 'a -> e']
      @yag.nodeset.map(&:id).should eql [:main, :a, :b, :c, :d, :e]
    end
  end

  context "nodes" do
    it "set nodes attributes globally" do
      attr = {:style => "filled", :color => "purple"}
      @yag.nodes(attr)
      @yag.gnode_attrs.should == attr
    end
    
    it "add nodes attributes globally" do
      attr = {:style => "filled", :color => "purple"}
      attr2 = {:color => "red", :shape => "box"}
      @yag.nodes(attr)
      @yag.nodes(attr2)
      @yag.gnode_attrs.should == {:style => "filled", :color => "red", :shape => "box"}
    end
  end

  context "edges" do
    it "set edges attributes globally" do
      attr = {:style => "dotted", :color => "purple"}
      @yag.edges(attr)
      @yag.gedge_attrs.should == attr
    end

    it "add edges attributes globally" do
      attr = {:style => "dotted", :color => "purple"}
      attr2 = {:color => "red", :arrowhead => "none"}
      @yag.edges(attr)
      @yag.edges(attr2)
      @yag.gedge_attrs.should == {:style => "dotted", :color => "red", :arrowhead => "none"}
    end
  end

  context "global" do
    it "set global graph attributes" do
      attrs = {:label => "A simple graph", :rankdir => "LR"}
      @yag.global(attrs)
      @yag.graph_attrs.should == attrs
    end
  end

  context "to_s(output dot data)" do
    it "without attrs" do
      @yag.add :main => [:init, :parse]
      @yag.add :init => :printf
      @yag.to_s.should eql ~<<-EOS
          digraph {
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

    it "with node attrs" do
      @yag.add :a => :b
      @yag.node(:a, :color => 'red', :style => 'filled')
      @yag.to_s.should eql ~<<-EOS
          digraph {
            a[color="red",style="filled"];
            b;
            a -> b;
          }
          EOS
    end

    it "with edge attrs" do
      @yag.edge(:a_b, :color => 'red')
      @yag.to_s.should eql ~<<-EOS
          digraph {
            a;
            b;
            a -> b[color="red"];
          }
          EOS
    end

    it "with 2 edges with different attrs" do
      @yag.edge(:a_b, :color => 'red')
      @yag.edge(:a_b_1, :color => 'blue')
      @yag.to_s.should eql ~<<-EOS
        digraph {
          a;
          b;
          a -> b[color="red"];
          a -> b[color="blue"];
        }
        EOS
    end

    it "with global node attributes" do
      @yag.nodes(:shape => 'box', :style => 'filled')
      @yag.add(:a => :b)
      @yag.to_s.should eql ~<<-EOS
        digraph {
          node[shape="box",style="filled"];
          a;
          b;
          a -> b;
        }
        EOS
    end

    it "with global edges attributes" do
      @yag.edges(:style => 'dotted', :color => 'red')
      @yag.add(:a => :b)
      @yag.to_s.should eql ~<<-EOS
        digraph {
          edge[style="dotted",color="red"];
          a;
          b;
          a -> b;
        }
        EOS
    end

    it "with global attributes" do
      @yag.global(:label => "A Simple Graph", :rankdir => "LR")
      @yag.add(:a => :b)
      @yag.to_s.should eql ~<<-EOS
        digraph {
          label="A Simple Graph";
          rankdir="LR";
          a;
          b;
          a -> b;
        }
        EOS
    end

    it "handle carridge return in a label nicely" do
      @yag.node(:a, :label => "hello\nworld")
      @yag.to_s.should eql ~<<-EOS
        digraph {
          a[label="hello\\nworld"];
        }
        EOS
    end

    it "can handle unicode labels" do
      @yag.node(:a, :label => "こんにちは、世界！")
      @yag.to_s.should eql ~<<-EOS
        digraph {
          a[label="こんにちは、世界！"];
        }
        EOS
    end
  end
end