# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gviz do
  before(:each) do
    @g = Gviz.new
  end

  context "node" do
    it "add a node" do
      node = @g.node(:a)
      node.should be_a_instance_of Gviz::Node
      node.id.should eql :a
      node.attrs.should be_empty
      @g.nodeset.map(&:id).should eql [:a]
    end

    it "add nodes" do
      @g.node(:a)
      @g.node(:b)
      @g.nodeset.map(&:id).should eql [:a, :b]
    end

    it "add a node with attrs" do
      node = @g.node(:a, :color => 'blue', :label => 'hello')
      node.should be_a_instance_of Gviz::Node
      node.id.should eql :a
      node.attrs.should == {:color => 'blue', :label => 'hello'}
      @g.nodeset.map(&:attrs).should eql [node.attrs]
    end

    it "add nodes with same name & different attrs" do
      @g.node(:a, :color => 'blue', :label => 'hello')
      @g.node(:a, :color => 'red')
      @g.nodeset.first.attrs.should == {:color => 'red'}
    end

    it "raise an error with a string" do
      ->{ @g.node('a') }.should raise_error(ArgumentError)
    end

    it "raise an error with a symbol which include underscores" do
      ->{ @g.node(:a_b) }.should raise_error(ArgumentError)
    end
  end

  context "edge" do
    it "add a edge" do
      edge = @g.edge(:a_b)
      edge.should be_a_instance_of Gviz::Edge
      edge.st.should eql :a
      edge.ed.should eql :b
      edge.attrs.should be_empty
      @g.edgeset.map(&:to_s).should eql ["a -> b"]
    end

    it "add a edge with attrs" do
      edge = @g.edge(:a_b, :color => 'red', :arrowhead => 'none')
      edge.should be_a_instance_of Gviz::Edge
      edge.st.should eql :a
      edge.ed.should eql :b
      edge.attrs.should == {:color => 'red', :arrowhead => 'none'}
      @g.edgeset.map(&:to_s).should eql ["a -> b"]
    end

    it "overwrite same edge" do
      @g.edge(:a_b)
      @g.edge(:a_b, :color => 'red')
      @g.edgeset.map(&:to_s).should eql ["a -> b"]
      @g.edgeset.first.attrs.should == {:color => 'red'}
    end

    it "add different edges, but same name" do
      edge1 = @g.edge(:a_b)
      edge2 = @g.edge(:a_b_1)
      edge1.seq.should eql 0
      edge2.seq.should eql 1
      @g.edgeset.map(&:to_s).should eql ["a -> b", "a -> b"]
    end

    it "can accept a string id" do
      @g.edge('a_b')
      @g.edgeset.first.to_s.should eql "a -> b"
    end

    it "can take ports with a string id" do
      @g.edge("a:n_b:f")
      edge = @g.edgeset.first
      edge.st.should eql :a
      edge.ed.should eql :b
      edge.st_port.should eql :n
      edge.ed_port.should eql :f
      edge.to_s.should eql "a:n -> b:f"
    end
    
    it "can take ports with a string id 2" do
      @g.add(:a => :b)
      @g.edge("a:n_b:f", color:'red')
      @g.edgeset.map(&:id).should eql [:a_b]
      
    end
  end

  context "add" do
    context "edges" do
      it "one to many" do
        @g.add :a => [:b, :c, :d]
        @g.edgeset.map(&:to_s).should eql ['a -> b', 'a -> c', 'a -> d']
        @g.nodeset.map(&:id).should eql [:a, :b, :c, :d]
      end

      it "many to many" do
        @g.add [:main, :sub] => [:a, :b, :c]
        @g.edgeset.map(&:to_s)
            .should eql ['main -> a', 'main -> b', 'main -> c',
                         'sub -> a',  'sub -> b',  'sub -> c']
        @g.nodeset.map(&:id).should eql [:main, :a, :b, :c, :sub]
      end

      it "sequence" do
        @g.add :main => :sub, :sub => [:a, :b]
        @g.edgeset.map(&:to_s)
            .should eql ['main -> sub', 'sub -> a', 'sub -> b']
        @g.nodeset.map(&:id).should eql [:main, :sub, :a, :b]
      end

      it "several sequences" do
        @g.add :main => :a, :a => [:c, :d]
        @g.add :main => :b, :b => [:e, :f]
        @g.edgeset.map(&:to_s)
            .should eql ['main -> a', 'a -> c', 'a -> d',
                         'main -> b', 'b -> e', 'b -> f']
        @g.nodeset.map(&:id).should eql [:main, :a, :c, :d, :b, :e, :f]
      end
    end

    context "nodes" do
      it "add a node" do
        @g.add :a
        @g.nodeset.map(&:id).should eql [:a]
      end

      it "add several nodes" do
        @g.add :a, :b, :c
        @g.nodeset.map(&:id).should eql [:a, :b, :c]
      end

      it "raise error with a string" do
        ->{ @g.add 'a' }.should raise_error(ArgumentError)
      end
    end
  end

  context "graph" do
    it "add routes" do
      @g.graph do
        add :main => [:a, :b, :c]
        add :a => [:d, :e]
      end
      @g.edgeset.map(&:to_s)
          .should eql ['main -> a', 'main -> b', 'main -> c',
                       'a -> d', 'a -> e']
      @g.nodeset.map(&:id).should eql [:main, :a, :b, :c, :d, :e]
    end
  end

  context "nodes" do
    it "set nodes attributes globally" do
      attr = {:style => "filled", :color => "purple"}
      @g.nodes(attr)
      @g.gnode_attrs.should == attr
    end
    
    it "add nodes attributes globally" do
      attr = {:style => "filled", :color => "purple"}
      attr2 = {:color => "red", :shape => "box"}
      @g.nodes(attr)
      @g.nodes(attr2)
      @g.gnode_attrs.should == {:style => "filled", :color => "red", :shape => "box"}
    end
  end

  context "edges" do
    it "set edges attributes globally" do
      attr = {:style => "dotted", :color => "purple"}
      @g.edges(attr)
      @g.gedge_attrs.should == attr
    end

    it "add edges attributes globally" do
      attr = {:style => "dotted", :color => "purple"}
      attr2 = {:color => "red", :arrowhead => "none"}
      @g.edges(attr)
      @g.edges(attr2)
      @g.gedge_attrs.should == {:style => "dotted", :color => "red", :arrowhead => "none"}
    end
  end

  context "global" do
    it "set global graph attributes" do
      attrs = {:label => "A simple graph", :rankdir => "LR"}
      @g.global(attrs)
      @g.graph_attrs.should == attrs
    end
  end

  context "to_s(output dot data)" do
    it "without attrs" do
      @g.add :main => [:init, :parse]
      @g.add :init => :printf
      @g.to_s.should eql ~<<-EOS
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
      @g.add :a => :b
      @g.node(:a, :color => 'red', :style => 'filled')
      @g.to_s.should eql ~<<-EOS
          digraph {
            a[color="red",style="filled"];
            b;
            a -> b;
          }
          EOS
    end

    it "with edge attrs" do
      @g.edge(:a_b, :color => 'red')
      @g.to_s.should eql ~<<-EOS
          digraph {
            a;
            b;
            a -> b[color="red"];
          }
          EOS
    end

    it "with 2 edges with different attrs" do
      @g.edge(:a_b, :color => 'red')
      @g.edge(:a_b_1, :color => 'blue')
      @g.to_s.should eql ~<<-EOS
        digraph {
          a;
          b;
          a -> b[color="red"];
          a -> b[color="blue"];
        }
        EOS
    end

    it "with global node attributes" do
      @g.nodes(:shape => 'box', :style => 'filled')
      @g.add(:a => :b)
      @g.to_s.should eql ~<<-EOS
        digraph {
          node[shape="box",style="filled"];
          a;
          b;
          a -> b;
        }
        EOS
    end

    it "with global edges attributes" do
      @g.edges(:style => 'dotted', :color => 'red')
      @g.add(:a => :b)
      @g.to_s.should eql ~<<-EOS
        digraph {
          edge[style="dotted",color="red"];
          a;
          b;
          a -> b;
        }
        EOS
    end

    it "with global attributes" do
      @g.global(:label => "A Simple Graph", :rankdir => "LR")
      @g.add(:a => :b)
      @g.to_s.should eql ~<<-EOS
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
      @g.node(:a, :label => "hello\nworld")
      @g.to_s.should eql ~<<-EOS
        digraph {
          a[label="hello\\nworld"];
        }
        EOS
    end

    it "can handle unicode labels" do
      @g.node(:a, :label => "こんにちは、世界！")
      @g.to_s.should eql ~<<-EOS
        digraph {
          a[label="こんにちは、世界！"];
        }
        EOS
    end
    
    it "take port on edges" do
      @g.route(:a => [:b, :c])
      @g.edge("a:n_c:f")
      @g.node(:a, label:"<n> a | b |<p> c")
      @g.node(:c, label:"<o> d | e |<f> f")
      @g.to_s.should eql ~<<-EOS
        digraph {
          a[label="<n> a | b |<p> c"];
          b;
          c[label="<o> d | e |<f> f"];
          a -> b;
          a:n -> c:f;
        }
        EOS
    end
  end
end