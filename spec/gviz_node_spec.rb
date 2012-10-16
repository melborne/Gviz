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

    context "when a string passed" do
      it "raise an error" do
        ->{ Gviz::Node.new('a') }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    subject { Gviz::Node.new(:a, style:'filled').to_s }
    it { should eq "a" }
  end
end
