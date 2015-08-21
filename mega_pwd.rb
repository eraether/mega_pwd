require 'pathname';

class Runner
  def self.main()
    weight_functions = WeightFunctions.new

    max_output_length = 30
    color_output = :full #:full, :partial, :off
     weight_function = lambda do |start_x, end_x|
      weight_functions.definite_integral.call(start_x,end_x,weight_functions.sqrt_func_integral)
    end

    decoration = {
      :first_dir_prefix=>"",
      :last_dir_prefix=>"",
      :last_dir_suffix=>"",
      :printable_chars=>0, # sum of visible first_dir_prefix, last_dir_prefix, and last_dir_suffix strings
      :skip_dir_separator=>["/"],
      :dir_separator=>"/",
      :dir_separator_chars=>1}

    case color_output
    when :full # 256 colors
      intermediate_dir_color = "\\[\\e[38;5;111m\\]"
      decoration[:first_dir_prefix] = "\\[\\e[1;34m\\]"
      decoration[:last_dir_prefix] =  "\\[\\e[38;5;195m\\]"
      decoration[:last_dir_suffix] = "\\[\\e[0m\\]"
      decoration[:dir_separator] = "\\[\\e[38;5;75m\\]⥋ #{intermediate_dir_color}"
      decoration[:skip_dir_separator] =  [46, 76,106,136,166,196].map.with_index{|color, index| Array.new((index+1)**1.5, "\\[\\e[38;5;#{color}m\\]⥋ #{intermediate_dir_color}")}.flatten
      decoration[:dir_separator_chars] = 2
      decoration[:printable_chars] = 2
    when :partial # 8 colors
      decoration[:first_dir_prefix] = "\\[\\e[0;34m\\]"
      decoration[:last_dir_prefix] = "\\[\\e[1;34m\\]"
      decoration[:last_dir_suffix] = "\\[\\e[0m\\]"
      decoration[:dir_separator] = "/"
      decoration[:dir_separator_chars] = 1
      decoration[:printable_chars] = 0
    when :off # no colors
      decoration[:first_dir_prefix] = ""
      decoration[:last_dir_prefix] = "["
      decoration[:last_dir_suffix] = "]"
      decoration[:dir_separator] = "/"
      decoration[:dir_separator_chars] = 1
      decoration[:printable_chars] = 2
    end



    mega_pwd = MegaPwd.new(max_output_length, weight_function, decoration)
    mega_pwd.main();
  end
end


class WeightFunctions
  attr_reader :definite_integral, :constant_func_integral, :linear_func_integral, :sqrt_func_integral, :parabolic_func_integral, :cubic_func_integral,
  :sin_func_integral

  def initialize()

  @definite_integral = lambda {|start_x, end_x, integral|
    integral.call(end_x)-integral.call(start_x)
  }

  # y = 1
  # importance is constant throughout
  @constant_func_integral = lambda { |x| x}

  # y = x + 0.05
  # importance starts at 0.05 and climbs up to 1.05
  @linear_func_integral = lambda {|x| x**2/2.0 + 0.05*x}

  #y = x^0.5 + 0.05
  # importance starts at 0.05 and climbs to 1.05.  However, the importance is distributed more evenly than y=x
  @sqrt_func_integral = lambda { |x|  2*x**(1.5)/3 + 0.05*x }

  # y = 4x^2-4x+1.05
  # importance starts at 1.05, drops down to 0.05 in the middle and goes back up to 1.05 at the end.
  @parabolic_func_integral = lambda { |x|4*x**3/3 - 2*x**2 +1.05*x}

      # y = x^3
      # importance hovers at 0 until it shoots to 1.  Almost nothing has importance except the last view items
      @cubic_func_integral = lambda {|x|x**4}

      # y = sin(2.5*px)^2 + 0.05
      # importance cycles between 0.05 and 1.05 5 times, ending with 1.05 importance
      @sin_func_integral = lambda {|x|
        p = Math::PI
        0.55*x - Math.sin(5*p*x)/(p*10)
  }
  end
end


class MegaPwd
  def initialize(max_output_length, weight_function, decoration)
    @max_output_length = max_output_length
    @weight_function = weight_function
    @decoration = decoration
  end

  def main()
    prefix_string, current_path = compute_path_string()
    intermediate_directories, final_directory = split_directories(current_path)
    available_chars = compute_available_chars(@max_output_length, prefix_string, intermediate_directories, final_directory, @decoration)
    compute_initial_weights(intermediate_directories, @weight_function, available_chars)
    intermediate_directories = normalize_weights(intermediate_directories, available_chars, @decoration[:dir_separator_chars])
    print_final_output(prefix_string, intermediate_directories, final_directory, @decoration)
  end

  def compute_available_chars(max_output_length, prefix_string, intermediate_directories, final_directory, decoration)
    arr = []
    available_chars = max_output_length
    arr.push(available_chars)
    available_chars -= prefix_string.length # count '~/'
    arr.push(available_chars)
    available_chars -= final_directory.to_s.length # current directory always printed in full
    arr.push(available_chars)
    available_chars -= decoration[:printable_chars] # count decoration around the current directory
    arr.push(available_chars)
    available_chars = [0, available_chars].max
    return available_chars
  end

  def compute_path_string()

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
      prefix_string = ""
      #if the current path is relative to the home directory, prefix the string with a "~/"
    elsif current_directory_string.start_with?(home_directory_string) then
      prefix_string = "~"
      current_path=current_directory.relative_path_from(home_directory).to_s
      #otherwise, print the whole path
    else
      current_path=current_directory.to_s
    end

    return prefix_string, current_path
  end

  def split_directories(current_path)
    directories = current_path.strip.split("/")-[""]
    final_directory = directories[-1]
    final_directory ||= ""
    intermediate_directories = directories[0...-1].map do |directory|
      {:directory=>directory,:weight=>0, :enabled=>true}
    end
    return intermediate_directories, final_directory
end


    # the available characters are dispersed amongst the intermediate directories
    # based on the desired weight function defined from [0,1]
    # the amount of assigned characters is equal to the integral of the defined directory's range as a percentage of the whole
    # for example, if there are two intermediate directories, then the first will span from [0,0.5) and the second will span from [0.5,1]
    # if there are 20 remaining characters and the function is y=1, then the integral is y=x and the first directory gets 0.5x-0x=0.5x=0.5*20=10 chars
    # and the second equation gets 1x-0.5x=0.5x=0.5*20=10 chars
    # rounding is done after all characters have been assigned

    # all of the following functions are integrals of the functions they define
  def compute_initial_weights(intermediate_directories, weight_function, available_chars)
    intermediate_directories.each_with_index do |hash, x|
      start_x = x/intermediate_directories.length.to_f
      end_x  = (x+1)/intermediate_directories.length.to_f
    result = weight_function.call(start_x,end_x)*available_chars
    hash[:weight] = result
  end
end

# maps resulting weights to the available characters
def scale_weight_sum(intermediate_directories,available_chars)

  # normalize resulting weights on to the available characters
  total_characters_used = intermediate_directories.inject(0.0){|sum, hash|sum+hash[:weight]}

  # avoid divide by 0 errors when normalizing
  if total_characters_used == 0
    total_characters_used = 1
  end
  intermediate_directories.each{|hash|hash[:weight] = hash[:weight]*(available_chars/total_characters_used.to_f)}
end

def redistribute_weight_from_item(item, extra_weight, unprocessed_directories)
  current_unprocessed_weight = unprocessed_directories.inject(0.0){|sum,hash|sum+hash[:weight]}
  new_unprocessed_weight = current_unprocessed_weight+extra_weight;
  multiplier = new_unprocessed_weight/current_unprocessed_weight;
  item[:weight] -= extra_weight
  unprocessed_directories.delete(item)
  unprocessed_directories.each{|hash|hash[:weight]=hash[:weight]*multiplier}
end

# redistributes any weight longer than the directory name to remaining directories
def redistribute_unused_weight(intermediate_directories, dir_separator_chars)
  unprocessed_directories = Array.new(intermediate_directories)
  while not unprocessed_directories.empty?
    unprocessed_directories = unprocessed_directories.sort_by {|hash|hash[:weight]-hash[:directory].length.to_f}.reverse()
    first = unprocessed_directories[0]
    first_target_weight = first[:directory].length+dir_separator_chars
    last = unprocessed_directories[-1]


    # extra weight can be redistributed
    if first[:weight] > first_target_weight
      redistribute_weight_from_item(first, first[:weight]-first_target_weight, unprocessed_directories)
    # cannibalize dirs that don't have enough weight to be printed
    elsif last[:weight] < dir_separator_chars
      extra = last[:weight]
      redistribute_weight_from_item(last, last[:weight], unprocessed_directories)
    else
      break
    end
  end

  intermediate_directories.each do |hash|
    if hash[:weight] < dir_separator_chars
      hash[:enabled] = false
    end
  end
end

# maps floating point weights to an integer value
def clamp_weights(intermediate_directories, available_chars)
 total_characters_used = intermediate_directories.inject(0.0){|sum, hash|sum+hash[:weight]}
      unrounded_characters_used = intermediate_directories.inject(0.0){|sum,x|sum+x[:weight].floor}

      remaining_rounding_characters = available_chars-unrounded_characters_used
      intermediate_directories.sort_by{|hash|
        hash[:weight]-hash[:weight].floor
      }.reverse().each{|hash|
        weight = hash[:weight]
        if remaining_rounding_characters > 0 and hash[:enabled] then
          remaining_rounding_characters -= 1
          weight = weight.ceil
        else
          weight = weight.floor
        end
        hash[:weight] = weight
      }
end

# def clamp_total_dirs(intermediate_directories, dirs_over_capacity)
#   new_dirs = intermediate_directories.map.with_index.sort_by{|hash, index|hash[:weight]}.drop(dirs_over_capacity).sort_by(&:last).map(&:first)
#   return new_dirs
# end

def normalize_weights(intermediate_directories, available_chars, dir_separator_chars)
  scale_weight_sum(intermediate_directories,available_chars)
  redistribute_unused_weight(intermediate_directories, dir_separator_chars)
  clamp_weights(intermediate_directories, available_chars)
  intermediate_directories.each do |item| item[:weight] -= dir_separator_chars end
  return intermediate_directories
end

  def decorate_prefix_directory(prefix_directory, decoration)
    if not prefix_directory.to_s.empty?
      prefix_directory = "#{decoration[:first_dir_prefix]}#{prefix_directory}"
    end
    return {:directory=>prefix_directory,:weight=>prefix_directory.length, :enabled=>true}
  end

  def decorate_final_directory(final_directory, decoration)
    if not final_directory.to_s.empty?
      final_directory = "#{decoration[:last_dir_prefix]}#{final_directory}#{decoration[:last_dir_suffix]}"
    end
    return {:directory=>final_directory,:weight=>final_directory.length, :enabled=>true}
  end


  def generate_weighted_directory_output(intermediate_directory)
        directory = intermediate_directory[:directory];
        weight = intermediate_directory[:weight];
        if directory.length <= weight
          return directory;
        end
        abbreviated = directory[0]+directory[1..-1].gsub(/[aeiou]/i, '')
        if abbreviated.length < weight
          abbreviated = directory;
        end
        "#{abbreviated[0...weight]}"
    end


    def print_final_output(prefix_string, intermediate_directories, final_directory, decoration)
      decorated_prefix_dir = decorate_prefix_directory(prefix_string, decoration)
      decorated_final_dir = decorate_final_directory(final_directory, decoration)
      final_output_segments = [decorated_prefix_dir, *intermediate_directories, decorated_final_dir]

      final_output = ""
      dir_separators = [decoration[:dir_separator], *decoration[:skip_dir_separator]]
      disabled_segments = 0
      final_output_segments.each_with_index do |item, index|
        if not item[:enabled]
          disabled_segments+=1
          next
        end

        prefix = ""
        if index != 0
          prefix = dir_separators[disabled_segments]
          prefix ||= dir_separators.last
        end
        weighted_output = generate_weighted_directory_output(item)

        final_output += "#{prefix}#{weighted_output}"
        disabled_segments= 0
      end

      directory_output = final_output.strip
      STDOUT.print directory_output
      STDOUT.flush
    end
  end

Runner.main()
