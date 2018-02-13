require 'gosu'

# Animation is self-explanatory
class Animation
  def initialize(frames, time_in_secs, once = false)
    @frames = frames
    @time = time_in_secs * 1000
    @once = once
    @stopped = false
    @lastnum = 0
  end

  def start
    return @frames[@frames.size - 1] if @stopped
    number = frame_number
    frame = @frames[number]
    stop if @once && number == @frames.size - 1
    frame
  end

  def frame_number
    number = Gosu.milliseconds / @time % @frames.size
    if number < @lastnum && @once
      @stopped = true
    elsif (@lastnum = number)
    end
    number
  end

  def stop
    @frames[0]
  end

  def should_draw?
    !(@once && @stopped)
  end
end
