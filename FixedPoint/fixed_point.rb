class FixedPoint
  def initialize( original )
    initialize_bitmap(original)
  end

  def value
    negative? ? -1 * abs : abs
  end
  alias_method :to_f, :value

  def abs
    integer + fraction
  end

  def inspect
    value.to_s
  end

  def to_packed
    sum_of_bits(@bitmap)
  end

  def negative?
    @bitmap.last==1
  end

  def <=>(other)
    value<=>other.value
  end

  class << self
    def new(original)
      return from_float(original) if original.is_a?(Float)
      super
    end

    def from_fixnum( original )
      new( original )
    end

    def from_float( original )
      sign = original<0 ? 0x8000_0000 : 0

      abs = original.abs
      int_val = abs.truncate << 15

      fractional_val = fraction_to_packed( abs - abs.truncate )

      new( sign | int_val | fractional_val )
    end

    def fraction_to_packed(frac)
      (0..14).inject([0, frac]) do |map, pwr|
        current_val = 1.0 / (2<<pwr)
        if map.last >= current_val
          [map.first + (1<<(14-pwr)), map.last - current_val]
        else
          map
        end
      end.first
    end
  end

  private
  def initialize_bitmap( original )
    @bitmap = (0..31).inject([ ]) do |map, pwr|
      bit = 1<<pwr
      map.push( (original & bit) / bit )
    end
  end

  def integer
    sum_of_bits integer_bits
  end

  def fraction
    return 0.0 if fraction_bits.all?{|bit| bit.zero? }
    fraction_from_bits fraction_bits
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
