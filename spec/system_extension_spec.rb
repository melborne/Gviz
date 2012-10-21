# encoding: UTF-8
require_relative 'spec_helper'

describe Numeric do
  describe "#norm" do
    context "normalize into 0.0-1.0" do
      it "works for integer" do
        5.norm(0..10).should eql 0.5
        2.norm(0..10).should eql 0.2
        0.norm(0..10).should eql 0.0
        10.norm(0..10).should eql 1.0
        5.norm(5..10).should eql 0.0
        10.norm(5..10).should eql 1.0
        7.norm(5..10).should eql 0.4
      end

      it "works for float" do
        2.5.norm(0..10).should eql 0.25
        7.4.norm(0..10).should eql 0.74
        0.0.norm(0..10).should eql 0.0
        10.0.norm(0..10).should eql 1.0
        15.0.norm(10..20).should eql 0.5
      end
    end

    context "normalize into other than 0.0-1.0" do
      it "works for integer" do
        5.norm(0..10, 0..20).should eql 10.0
        2.norm(0..10, 10..20).should eql 12.0
        0.norm(0..10, 10..15).should eql 10.0
        10.norm(0..10, 10..15).should eql 15.0
        5.norm(0..10, 10..15).should eql 12.5
      end

      it "works for float" do
        2.5.norm(0..10, 0..5).should eql 1.25
        2.5.norm(0..10, 5..10).should eql 6.25
      end
    end
  end
end

describe Object do
  describe "#to_id" do
    describe "return a uniq symbol for node id" do
      context "for integer" do
        subject { 10.to_id }
        it { should be_a_kind_of Symbol }
        it { should be 10.to_id }
      end

      context "for unicode" do
        subject { "グラフ".to_id }
        it { should be_a_kind_of Symbol }
        it { should be "グラフ".to_id }
      end
    end
  end

  describe "#wrap" do
    it "works for any object" do
      'a'.wrap(['(',')']).should eql '(a)'
      10.wrap(['<','>']).should eql '<10>'
      :a.wrap(['/','/']).should eql '/a/'
    end

    it "wrap with '{}' in default" do
      'a'.wrap.should eql '{a}'
      10.wrap.should eql '{10}'
      :a.wrap.should eql '{a}'
    end
  end
end

describe Array do
  describe "#tileize" do
    it "build label for record shape" do
      [:a, :b].tileize.should eql "{a|b}"
      [[:a, :b], [1, 2]].tileize.should eql "{{a|b}|{1|2}}"
      [[:a, :b], [1, 2], [:x, :y]].tileize.should eql "{{a|b}|{1|2}|{x|y}}"
      [[[:a, :b], :c], [1, 2, 3]].tileize.should eql "{{{a|b}|c}|{1|2|3}}"
    end
  end
end