require 'spec'
require File.join( File.dirname(__FILE__), '..', 'fixed_point.rb' )

describe FixedPoint do
  describe 'initializing with packed encoding' do
    before :each do
      @positive = FixedPoint.new(0x0002_4000)
      @negative = FixedPoint.new(0x8002_4000)
    end
    
    it "should map the left-most bit to the sign" do
      @positive.send(:"negative?").should be_false
      @negative.send(:"negative?").should be_true
    end

    it "should map the 16 bits next to the sign bit to the integr part of the number" do
      @positive.send(:integer).should eql(4)
      @negative.send(:integer).should eql(4)
    end

    it "should map the last fifteen bits to the fractional part" do
      @positive.send(:fraction).should eql(0.5)
      @negative.send(:fraction).should eql(0.5)
    end

    it "should yield a value equal to the signed sum of the fraction and integer" do
      @positive.value.should eql( 4.5)
      @negative.value.should eql(-4.5)
    end

    { 0x0000_8000 => 1.0, 0x8000_8000 => -1.0, 0x0001_0000 => 2.0, 0x8001_4000 => -2.5 }.each do |packed, value|
      it "should map #{'0x%08x' % packed} to #{value}" do
        fixed_point = FixedPoint.new packed
        fixed_point.value.should eql(value)
      end
    end
  end
end
