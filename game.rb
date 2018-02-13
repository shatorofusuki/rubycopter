require 'gosu'
require 'ostruct'
require_relative 'player'
require_relative 'point'
require_relative 'constants'
require_relative 'block'

GameState = OpenStruct.new(
  scroll_x: 0,
  player_pos: Point.new(0, 0),
  last_scroll_check: 0,
  last_block_added: 0,
  score: 0,
  blocks: [],
  block_probability: BASE_BLOCK_PROBABILITY
)

# GameWindow defines the Game window
class GameWindow < Gosu::Window # rubocop:disable Metrics/ClassLength
  def initialize
    super 800, 604
    @backgrounds = []
    1.upto(11) { |n| @backgrounds << Gosu::Image.new("images/#{n}.png") }
    @state = GameState.clone
    @player = Player.new
    @font = Gosu::Font.new(self, Gosu.default_font_name, 50)
    @best = 0
  end

  def button_down(button)
    close if button == Gosu::KbEscape
    restart if button == Gosu::KbReturn
  end

  def update
    update_background
    update_blocks
    update_player
    update_block_probability
    update_for_living if @player.alive
  end

  def update_for_living
    update_current_score
    update_best_score
    update_collisions
  end

  def draw
    draw_backgrounds
    @player.draw
    draw_blocks
    draw_score
    draw_highscore
    draw_block_probability
    draw_dialogue unless @player.alive
  end

  def update_block_probability
    @state.block_probability = BASE_BLOCK_PROBABILITY + @state.score / 10_000
  end

  def update_collisions
    @player.die! if @state.blocks.select(&:healthy?)\
                          .find { |b| @player.collides_with(b) }
    @player.die! if @player.exceeded?(0, 470)
  end

  def update_blocks
    move_blocks
    create_random_blocks
    # remove runaways
    @state.blocks.reject! { |b| b.pos.x < -47 }
  end

  def create_random_blocks
    dist = distance_since_last_check(@state.last_block_added) * 11
    block_size = 47
    if dist > block_size && Random.rand > @state.block_probability
      block_y = Random.rand(469)
      @state.blocks << Block.new(width, block_y)
    end
    @state.last_block_added = @state.scroll_x if dist > block_size
  end

  def move_blocks
    @state.blocks.each do |b|
      b.update(update_interval)
    end
  end

  def draw_blocks
    @state.blocks.each(&:draw)
  end

  def restart
    @player.restart
    scroll = @state.scroll_x
    @state = GameState.clone
    @state.blocks.each(&:explode)
    # @state.blocks.clear
    @state.scroll_x = scroll
    @state.last_scroll_check = scroll
  end

  def draw_dialogue
    @font.draw('Press Enter to start over', 130, height / 2 - 50, 1)
  end

  def draw_score
    x = width / 15
    y = height * 5 / 6
    @font.draw('Distance : ' + @state.score.round.to_s, x, y, 1)
  end

  def draw_block_probability
    x = width * 2 / 5
    y = height * 1 / 6
    @font.draw('LVL : ' + @state.block_probability.round(2).to_s, x, y, 1)
  end

  def draw_highscore
    x = width * 7 / 10
    y = height * 5 / 6
    @font.draw('Best : ' + @best.round.to_s, x, y, 1)
  end

  def update_current_score
    @state.score += distance_since_last_check(@state.last_scroll_check)
    @state.last_scroll_check = @state.scroll_x
  end

  def distance_since_last_check(last)
    now = @state.scroll_x
    return now - last if now > last
    return @backgrounds[10].width - last + now if last > now
    0
  end

  def update_best_score
    @best = @state.score if @state.score > @best
  end

  def update_player
    if Gosu.button_down?(Gosu::KbUp)
      @player.move
      @player.apply_acceleration
    else
      @player.stop_move
    end
    @player.update(update_interval)
  end

  def update_background
    ms = update_interval
    # update background parallax
    @state.scroll_x += BG_SCROLL_SPEED * ms / 1000
    @state.scroll_x = 0 if @state.scroll_x > @backgrounds[0].width
  end

  def draw_backgrounds
    @backgrounds.each_with_index do |img, i|
      divergence_x = -@state.scroll_x * (i + 1)
      img.draw(divergence_x % img.width, 0, 0)
      img.draw(divergence_x % img.width - img.width, 0, 0)
    end
  end
end

GameWindow.new.show
