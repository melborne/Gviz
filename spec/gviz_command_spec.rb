require_relative "spec_helper"

ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

describe "gviz command" do
  context "when a graph file exist" do
    subject { syscmd "#{ROOT}/bin/gviz -f spec/graph.ru" }
    it do
      should eql ~<<-EOS
        digraph G {
          a;
          b;
          a -> b;
        }
        EOS
    end
  end

  context "when a graph file not exist" do
    subject { syscmd "#{ROOT}/bin/gviz", :err }
    it { should eql "graph file `graph.ru` not found\n" }
  end

  context "when a name option passed" do
    subject { syscmd "#{ROOT}/bin/gviz -n ABC -f spec/graph.ru" }
    it do
      should eql ~<<-EOS
        digraph ABC {
          a;
          b;
          a -> b;
        }
        EOS
    end
  end

  context "when a type option passed" do
    subject { syscmd "#{ROOT}/bin/gviz -t graph -f spec/graph.ru" }
    it do
      should eql ~<<-EOS
        graph G {
          a;
          b;
          a -> b;
        }
        EOS
    end
  end

  context "when -m with correct attr passed" do
    subject { syscmd "#{ROOT}/bin/gviz -m arrows" }
    it { should eql Gviz::ARROWS.join(", ") + "\n" }
  end

  context "when -m with man word passed" do
    subject { syscmd "#{ROOT}/bin/gviz -m man" }
    it do
      should eql ~<<-EOS
        --man(-m) accepts any of them:
          graph, node, edge, subgraph, cluster,
          arrows, shapes, output_formats
          color_names, color_schemes,
          full_color_names, full_color_schemes,
        EOS
    end
  end

  context "when -m with incorrect attr passed" do
    subject { syscmd "#{ROOT}/bin/gviz -m abc" }
    it do
      should eql ~<<-EOS
        Error: unknown subcommand 'abc' for --man
        --man(-m) accepts any of them:
          graph, node, edge, subgraph, cluster,
          arrows, shapes, output_formats
          color_names, color_schemes,
          full_color_names, full_color_schemes,
        EOS
    end
  end
end
