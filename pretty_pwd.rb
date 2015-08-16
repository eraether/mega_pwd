require 'pathname';
home_directory=Pathname.new(ENV['HOME'])
current_directory=Pathname.new(Dir.pwd)

home_directory_string = home_directory.cleanpath.to_s
current_directory_string = current_directory.cleanpath.to_s

current_path = ""
prefix_string = ""

#if the current path is the home directory, display a "~"
if  current_directory_string == home_directory_string
  prefix_string = "~"

#if we're at the root directory, print something.
elsif current_directory_string == "/"
  prefix_string = "/"
#if the current path is relative to the home directory, prefix the string with a "~/"
elsif current_directory_string.start_with?(home_directory_string) then
  prefix_string = "~/"
  current_path=current_directory.relative_path_from(home_directory).to_s
#otherwise, print the whole path
else
  current_path=current_directory.to_s
end

directories = current_path.split("/")
final_directory = directories[-1]
intermediate_directories = directories[0...-1].map do |directory|
  {:directory=>directory,:weight=>0}
end

# display the first 3 characters of every directory except the last one
# and print the last directory in its entirety
max_output_length = 40; #characters
available_chars = max_output_length - prefix_string.length -  intermediate_directories.length - "#{final_directory}".length

# the remaining available characters are dispersed amongst the intermediate directories
# based on the desired function defined from [0,1]
# the amount of assigned characters is equal to the integral of the defined directory's range as a percentage of the whole
# for example, if there are two intermediate directories, then the first will span from [0,0.5) and the second will span from [0.5,1]
# if there are 20 remaining characters and the function is y=1, then the integral is y=x and the first directory gets 0.5x-0x=0.5x=0.5*20=10 chars
# and the second equation gets 1x-0.5x=0.5x=0.5*20=10 chars
# rounding is done after all characters have been assigned

# all of the following functions are integrals of the functions they define


definite_integral = lambda {|start_x, end_x, integral|
  integral.call(end_x)-integral.call(start_x)
}



# y = 1
# importance is constant throughout
constant_func_integral = lambda { |x| x}

# y = x + 0.05
# importance starts at 0.05 and climbs up to 1.05
linear_func_integral = lambda {|x| x**2/2.0 + 0.05*x}

#y = x^0.5 + 0.05
# importance starts at 0.05 and climbs to 1.05.  However, the importance is distributed more evenly than y=x
  sqrt_func_integral = lambda { |x|
    2*x**(1.5)/3 + 0.05*x
  }

# y = 4x^2-4x+1.05
# importance starts at 1.05, drops down to 0.05 in the middle and goes back up to 1.05 at the end.
parabolic_func_integral = lambda { |x|
  4*x**3/3 - 2*x**2 +1.05*x
}

# y = sin(2.5*πx)^2 + 0.05
# importance cycles between 0.05 and 1.05 5 times, ending with 1.05 importance
sin_func_integral = lambda {|x|
  π = Math::PI
 0.55*x - Math.sin(5*π*x)/(π*10)
}


distribution_function = lambda {|start_x, end_x|
  definite_integral.call(start_x,end_x,sin_func_integral)
}


intermediate_directories.each_with_index do |hash, x|
  start_x = x/intermediate_directories.length.to_f
  end_x  = (x+1)/intermediate_directories.length.to_f
  result = distribution_function.call(start_x,end_x)*available_chars
  hash[:weight] = result
end


# normalize resulting weights on to the available characters
total_characters_used = intermediate_directories.inject(0.0){|sum, hash|sum+hash[:weight]}

# avoid divide by 0 errors
if total_characters_used == 0
  total_characters_used = 1
end

intermediate_directories.each{|hash|hash[:weight] = hash[:weight]*(available_chars/total_characters_used.to_f)}
total_characters_used = intermediate_directories.inject(0.0){|sum, hash|sum+hash[:weight]}
unrounded_characters_used = intermediate_directories.inject(0.0){|sum,x|sum+x[:weight].floor}

remaining_rounding_characters = available_chars-unrounded_characters_used
intermediate_directories.sort_by{|hash|
  hash[:weight]-hash[:weight].floor
  }.reverse().each{|hash|
    weight = hash[:weight]
    if remaining_rounding_characters > 0 then
      remaining_rounding_characters -= 1
      weight = weight.ceil
    else
      weight = weight.floor
    end
    hash[:weight] = weight
  }

  #intermediate_directories.each{|hash|puts hash}

STDOUT.print  prefix_string+intermediate_directories.map{|hash|
  directory = hash[:directory];
  weight = hash[:weight];
  if directory.length < weight
    next directory;
  end
  abbreviated = directory[0]+directory[1..-1].gsub(/[aeiou]/i, '')
  if abbreviated.length < weight
    abbreviated = directory;
  end
  "#{abbreviated[0...weight]}"
  }.push(final_directory).compact().join("/")
  STDOUT.flush
