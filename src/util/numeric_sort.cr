# Properly sort alphanumeric strings
# Used to sort the images files inside the archives
# https://github.com/hkalexling/Mango/issues/12

require "big"

def numeric_string?(str) : Bool
  /^\d+/.match(str) != nil
end

def split_by_alphanumeric(str)
  arr = [] of String
  str.scan(/([^\d\n\r]*)(\d*)([^\d\n\r]*)/) do |match|
    arr += match.captures.select &.!= ""
  end
  arr
end

def compare_numerically(c, d)
  is_c_bigger = c.size <=> d.size
  if c.size > d.size
    d += [nil] * (c.size - d.size)
  elsif c.size < d.size
    c += [nil] * (d.size - c.size)
  end
  c.zip(d) do |a, b|
    return -1 if a.nil?
    return 1 if b.nil?
    if numeric_string?(a) && numeric_string?(b)
      compare = a.to_big_i <=> b.to_big_i
      return compare if compare != 0
    else
      compare = a <=> b
      return compare if compare != 0
    end
  end
  is_c_bigger
end

def compare_numerically(a : String, b : String)
  compare_numerically split_by_alphanumeric(a), split_by_alphanumeric(b)
end
