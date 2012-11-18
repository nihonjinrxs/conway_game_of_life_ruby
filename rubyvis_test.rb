require 'rubyvis'
data = [[]]
(1..n).each do |i|
  (1..m).each do |j|
    data[i] << @board[i,j].value
  end
end

