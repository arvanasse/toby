require 'spec'
require File.join( File.dirname(__FILE__), "..", "fixed_point.rb" )

describe FixedPoint do
  describe 'initialized with a floating point' do
    before :each do
      @positive = FixedPoint.new(  2.25 )
      @negative = FixedPoint.new( -2.5  )
    end

    it "should set the sign bit to 0 for a positive number" do
      @positive.instance_variable_get(:@bitmap).last.should == 0
    end

    it "should set the sign bit to 1 for a negative number" do
      @negative.instance_variable_get(:@bitmap).last.should == 1
    end

    it "should map the integer part of the floating point number to the integer part of the FixedPoint" do
      @positive.send(:integer).should eql(2)
      @negative.send(:integer).should eql(2)
    end

    it "should map the fractional part of the floating point number to the fractional part of the FixedPoint" do
      @positive.send(:fraction).should eql(0.25)
      @negative.send(:fraction).should eql(0.5)
    end

    { 0x0000_8000 => 1.0, 0x8000_8000 => -1.0, 0x0001_0000 => 2.0, 0x8001_4000 => -2.5 }.each do |packed, value|
      it "should map #{value} to #{'0x%08x' % packed}" do
        fixed_point = FixedPoint.new value
        fixed_point.to_packed.should == packed
      end
    end
  end
end
