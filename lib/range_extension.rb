class Range
  def overlap(other)
    return nil if other.nil?
    return multi_overlaps(other.dup) if other.is_a?(Array)

    # Accept range of times or a booking
    range = other.is_a?(Booking) ? other.time_range : other
    raise "Class error: overlap is only defined for ranges" unless range.is_a?(Range)

    overlap = nil
    if self.cover?(range.begin) 
      overlap = range.begin...(self.cover?(range.end) ? range.end : self.end)
    elsif range.cover?(self.begin)
      overlap = self.begin...(range.cover?(self.end) ? self.end : range.end) 
    end
    overlap
  end


  private
  def multi_overlaps(others, overlaps = {0 => [self]})
    overlaps.delete_if{|k,v| v.blank?}
    return overlaps if others.empty?

    # overlaps.dup does not work here, because the values stay the same objects! There's nothing like ".deep_dup"
    result = {}
    overlaps.each_pair{|k,v| result[k] = v.dup}

    other = others.shift
    overlaps.each_pair do |key, value|
      value.each{ |range| (result[key+1] ||= []) << range.overlap(other) unless range.nil? }
      result[key+1] = result[key+1].compact.uniq
    end
    multi_overlaps(others, result)
  end

  #TODO
  #def merge(overlap_hash)
  #end
end
