def random_string(n)
  n.times.inject(''){|string, n| string += (SecureRandom.random_number(25) + 97).chr}
end
 
def random_number(max, opt = {:null => false})
  if opt[:null]
    SecureRandom.random_number(max)
  else
    SecureRandom.random_number(max -1) + 1
  end
end

