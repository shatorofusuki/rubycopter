require 'gosu'
require_relative 'animation'
require_relative 'point'
require_relative 'constants'

# Blocks are obstacles on the heli's way
class Block
  attr_accessor :pos, :size

  def initialize(x, y)
    @pos = Point.new(x, y)
    @img = Gosu::Image.new('data/images/rock47.png')
    @size = Point.new(@img.height, @img.width)
    # 637 x 478 | 8 x 6 | ~ 80 x 80
    @explosion_img = Gosu::Image.load_tiles 'data/images/expl-sprites.png', 80, 80
    @explosion_anim = Animation.new(@explosion_img[0..47], 0.02, true)
    @explode = false
  end

  def draw
    @img.draw(@pos.x, @pos.y, 1) unless @explode
    @explosion_anim.start.draw(@pos.x - 20, @pos.y - 20, 1) \
                    if @explode && @explosion_anim.should_draw?
  end

  def update(ms)
    @pos.x -= ms / 1000 * (BG_SCROLL_SPEED * 11)
  end

  def explode
    @explode = true
  end

  def healthy?
    !@explode
  end
end
