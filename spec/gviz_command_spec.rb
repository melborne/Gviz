require_relative "spec_helper"

ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

describe "gviz command" do
  context "when a graph file exist" do
    subject { syscmd "#{ROOT}/bin/gviz spec/graph.ru" }
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
    subject { syscmd "#{ROOT}/bin/gviz -n ABC spec/graph.ru" }
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
    subject { syscmd "#{ROOT}/bin/gviz -t graph spec/graph.ru" }
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
end
