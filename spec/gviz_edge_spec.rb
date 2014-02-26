# encoding: UTF-8
require_relative "spec_helper"

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

    context "when a number string passed" do
      subject { Gviz::Edge.new('1234_1235') }
      its(:id) { should be :'1234_1235' }
      its(:st) { should be :'1234' }
      its(:ed) { should be :'1235' }
    end

    context "when a string with minus sign" do
      subject { Gviz::Edge.new('-123_124') }
      its(:id) { should be :'-123_124' }
      its(:st) { should be :'-123' }
      its(:ed) { should be :'124' }
    end

    context "when a string with other than words or colon passed" do
      it "raise an error" do
        ->{ Gviz::Edge.new('a!b_c') }.should raise_error(ArgumentError)
      end
    end

    context "when a symbol without underscore passed" do
      it "raise an error" do
        ->{ Gviz::Edge.new(:abc) }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    context "when type of graph is 'graph'" do
      before do
        $graph_type = :graph
      end
      it "returns undirected graph edges" do
        expect(Gviz::Edge.new('a_b').to_s).to eq "a -- b"
      end
      after() do
        $graph_type = :digraph
      end
    end
  end
end
