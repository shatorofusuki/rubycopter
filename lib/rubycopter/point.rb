# Point class makes it easier to hold X and Y coordinates
class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def clone
    Point.new(@x, @y)
  end

  def +(other)
    Point.new(@x + other.x, @y + other.y)
  end

  def -(other)
    Point.new(@x - other.x, @y - other.y)
  end

  def -@
    Point.new(-x, -y)
  end

  def *(other)
    return Point.new(@x * other.x, @y * other.y) if other.is_a?(Point)
    return Point.new(@x * other, @y * other) if other.is_a?(Numeric)
  end

  def coerce(left)
    [self, left]
  end

  def ==(other)
    @x == other.x && @y == other.y
  end
end
