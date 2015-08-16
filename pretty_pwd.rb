require 'pathname';
home_directory=Pathname.new(ENV['HOME'])
current_directory=Pathname.new(Dir.pwd)

home_directory_string = home_directory.cleanpath.to_s
current_directory_string = current_directory.cleanpath.to_s
#if the current path is the home directory, display a "~"

current_path = ""
prefix_string = ""

if  current_directory_string == home_directory_string
  prefix_string = "~"
#if the current path is relative to the home directory, prefix the string with a "~/"
elsif current_directory_string.start_with?(home_directory_string) then
  prefix_string = "~/"
  current_path=current_directory.relative_path_from(home_directory).to_s
#otherwise, print the whole path
else
    current_path=current_directory.to_s
end

directories = current_path.split("/")
final_directory = "#{directories[-1]}"
intermediate_directories = directories[0...-1].map do |directory|
  {:directory=>directory,:weight=>0}
end


# display the first 3 characters of every directory except the last one
# and print the last directory in its entirety
max_output_length = 40; #characters
available_chars = max_output_length - prefix_string.length -  intermediate_directories.length - final_directory.length
puts "Available characters:#{available_chars}"
# the remaining available characters are dispersed amongst the intermediate directories
# based on the desired function defined from [0,1]
# the amount of assigned characters is equal to the integral of the defined directory's range as a percentage of the whole
# for example, if there are two intermediate directories, then the first will span from [0,0.5) and the second will span from [0.5,1]
# if there are 20 remaining characters and the function is y=1, then the integral is y=x and the first directory gets 0.5x-0x=0.5x=0.5*20=10 chars
# and the second equation gets 1x-0.5x=0.5x=0.5*20=10 chars
# rounding is done after all characters have been assigned

# all of the following functions are integrals of the functions they define

# y = 1
constant_function = lambda { |start_x,end_x| end_x-start_x}

# y = x
linear_function = lambda {|start_x,end_x| end_x**2-start_x**2}

distribution_function = linear_function


intermediate_directories.each_with_index do |hash, x|
  start_x = x/intermediate_directories.length.to_f
  end_x  = (x+1)/intermediate_directories.length.to_f
  result = distribution_function.call(start_x,end_x)*available_chars
  hash[:weight] = result
end

puts "Weights:#{intermediate_directories.map{|x|x[:weight]}}"

unrounded_characters_used = intermediate_directories.inject(0){|sum,x|sum+x[:weight].to_i}
remaining_rounding_characters = available_chars-unrounded_characters_used

puts "Remaining rounding characters:#{remaining_rounding_characters}"
intermediate_directories = intermediate_directories.reverse().each {|hash|
  weight = hash[:weight]
  if weight.floor != weight && remaining_rounding_characters > 0 then
    remaining_rounding_characters -= 1
    weight = weight.ceil
  else
    weight = weight.floor
  end
  hash[:weight]=weight
  }.reverse()

puts "Weights:#{intermediate_directories.map{|x|x[:weight]}}"

STDOUT.print  prefix_string+intermediate_directories.map{|hash|
  directory = hash[:directory];
  weight = hash[:weight];
  puts "Directory:#{directory}, Weight:#{weight}"
if directory.length < weight
  next directory;
end
abbreviated = directory[0]+directory[1..-1].gsub(/[aeiou]/i, '')
if abbreviated.length < weight
  abbreviated = directory;
end
"#{abbreviated[0...weight]}"
  }.join("/")+"/#{final_directory}"
STDOUT.flush
