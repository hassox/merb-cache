module Enumerable
  def capture_first
    each do |o|
      return yield(o) || next
    end

    nil
  end

  def capture_intersection
    inject(nil) do |c, o|
      val = yield(o)
      c || val
    end
  end

  def capture_conjunction
    return nil if empty?

    inject(true) do |c, o|
      c && yield(o)
    end
  end
end