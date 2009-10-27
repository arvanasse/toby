class FixedPoint
  def initialize( original )
    @bitmap = (0..31).inject([ ]) do |map, pwr|
      bit = 1<<pwr
      map.push( (original & bit) / bit )
    end
  end

  def value
    negative? ? -1 * abs : abs
  end

  def abs
    integer + fraction
  end

  def inspect
    to_hex
  end

  def negative?
    @bitmap.last==1
  end

  class << self
    def from_fixnum( original )
      new( original )
    end

    def from_float( original )
      sign = original<0 ? 0x8000_0000 : 0
      int_val = original.abs.truncate << 15
      new( sign | int_val )
    end
  end

  private
  def integer
    sum_of_bits integer_bits
  end

  def fraction
    return 0.0 if fraction_bits.all?{|bit| bit.zero? }
    fraction_from_bits fraction_bits
  end

  def to_hex
    "0x%08x" % sum_of_bits(@bitmap)
  end

  def integer_bits
    @bitmap[15, 16]
  end

  def fraction_bits
    @bitmap[0, 15].reverse
  end

  def sum_of_bits(bitmap)
    pwr = 0
    bitmap.inject(0) do |sum, val| 
      adder = val * (1 << pwr)
      pwr += 1
      sum + adder
    end
  end

  def fraction_from_bits(bitmap)
    pwr = 0
    bitmap.inject(0.0) do |sum, val|
      frac =val * (1.0 / (2 << pwr)) 
      pwr += 1
      sum + frac
    end
  end
end
