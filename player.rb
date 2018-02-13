require 'gosu'
require_relative 'animation'
require_relative 'point'
require_relative 'constants'

PlayerState = OpenStruct.new(
  position: Point.new(100, 100),
  velocity: Point.new(0, 0)
)

# Player class represents the helicopter
class Player
  attr_accessor :state, :alive

  def initialize
    @frames = Gosu::Image.load_tiles 'images/heli-sprites.png', 423, 150
    @fire = Gosu::Image.load_tiles 'images/fire-sprites.png', 64, 128
    @move = { slow: Animation.new(@frames[0..3], 0.06, false),
              fast: Animation.new(@frames[0..3], 0.03, false),
              fire: Animation.new(@fire[0..31], 0.01, false) }
    @rot_speed = :slow
    @state = PlayerState.clone
    @alive = true
  end

  def restart
    @state = PlayerState.clone
    @alive = true
  end

  def collides_with(b)
    return false unless x_overlaps(b)
    return false unless x_overlaps_1(b)
    return false unless y_overlaps(b)
    return false unless y_overlaps_1(b)
    true
  end

  def x_overlaps(b)
    @state.position.x + 423 * HELISIZE > b.pos.x
  end

  def x_overlaps_1(b)
    @state.position.x < b.pos.x + b.size.x
  end

  def y_overlaps(b)
    @state.position.y + 150 * HELISIZE > b.pos.y
  end

  def y_overlaps_1(b)
    @state.position.y < b.pos.y + b.size.y
  end

  def update(ms)
    unless @alive
      @state.position.x -= ms / 1000 * (BG_SCROLL_SPEED * 11) # 11 is N of bgs
      return
    end
    @state.velocity += ms / 1000 * GRAVITY
    @state.position += ms / 1000 * @state.velocity
  end

  def exceeded?(a, b)
    true unless @state.position.y.between?(a, b - 150 * HELISIZE)
  end

  def die!
    @alive = false
  end

  def draw
    @move[@rot_speed].start.draw @state.position.x, @state.position.y, 1, \
                                 HELISIZE, HELISIZE
    add_fire unless @alive
  end

  def add_fire
    x = @state.position.x + 423 * HELISIZE / 2 - 32
    y = @state.position.y - 128 + 150 * HELISIZE
    @move[:fire].start.draw(x, y, 1)
  end

  def move
    @rot_speed = :fast
  end

  def stop_move
    @rot_speed = :slow
  end

  def apply_acceleration
    @state.velocity += LIFT
  end
end
