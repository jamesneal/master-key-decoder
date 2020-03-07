#!/usr/bin/env ruby

MACS = 7
bits = [3, 3, 1, 7, 2]

def abs(num)
  return num.abs
end

def diff(num1, num2)
  return (num2 - num1).abs
end

def keygen(offset, bits, id)
  bits = bits.join(",")
  offset = offset.join(",")
  return "translate([#{offset}]) rotate([180,0,0]) sc1([#{bits}], \"#{id}\");"
end

def sane(bits, pin, height)
  if diff(bits[pin], height) <= 1
    return false
  end
  if pin > 0 && diff(bits[pin - 1], height) >= MACS
    return false
  end
  if pin < 4 && abs(bits[pin + 1] - height) >= MACS
    return false
  end
  return true
end

puts keygen([0, -15, 0], bits, "M")

5.times do |pinid|
  row = 0
  (0..9).each do |height|
    newbits = bits.dup
    if sane(newbits, pinid, height)
      newbits[pinid] = height
      puts keygen([45 * pinid, 15 * row, 0], newbits, "#{pinid}-#{height}")
      row += 1
    end
  end
end
