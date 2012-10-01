require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Numeric do
  context "norm" do
    it "normalize a integer into range of 0.0-1.0" do
      5.norm(0..10).should eql 0.5
      2.norm(0..10).should eql 0.2
      0.norm(0..10).should eql 0.0
      10.norm(0..10).should eql 1.0
      5.norm(5..10).should eql 0.0
      10.norm(5..10).should eql 1.0
      7.norm(5..10).should eql 0.4
    end
    
    it "normalize a float into range of 0.0-1.0" do
      2.5.norm(0..10).should eql 0.25
      7.4.norm(0..10).should eql 0.74
      0.0.norm(0..10).should eql 0.0
      10.0.norm(0..10).should eql 1.0
      15.0.norm(10..20).should eql 0.5
    end

    it "can take target range other than 0.0-1.0" do
      5.norm(0..10, 0..20).should eql 10.0
      2.norm(0..10, 10..20).should eql 12.0
      0.norm(0..10, 10..15).should eql 10.0
      10.norm(0..10, 10..15).should eql 15.0
      5.norm(0..10, 10..15).should eql 12.5
      2.5.norm(0..10, 0..5).should eql 1.25
      2.5.norm(0..10, 5..10).should eql 6.25
    end
  end
end