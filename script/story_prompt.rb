require 'optparse'
require 'json'

options = {}

OptionParser.new do |opts|
  opts.on('-r', '--run', 'Execute script') do |v|
    options[:run] = v
  end

  opts.on('-s', '--stats', 'Show stats') do |v|
    options[:stats] = v
  end
end.parse!

def valid_input?(json)
  !!JSON.parse(json)
rescue
  puts "Error occurred while processing input"
  nil
end

def validated?(json_input)
  return false unless valid_input?(json_input)

  errors = []
  data = JSON.parse(json_input)

  %w[UNIT_OF_MEASURE PLACE ADJECTIVE NUMBER NOUN].each do |key|
    errors << "Error: \'#{key}\' is missing!" if !data.key?(key)
  end

  data.each do |key, value|
    if key.eql?('NUMBER') && value.to_i.negative?
      errors << 'NUMBER value must be positive!'
    elsif value.length >= 30
      errors << "\'#{key}\' value must be less than 30"
    end
  end
  puts errors if errors.length > 0
  errors.empty?
end

def write_output_to_file(output)
  file = File.open('input_data.txt', 'a')
  file.write("#{output}\n")
  file.close
end

def execute_main
  if validated?(ARGV[0])
    data = JSON.parse(ARGV[0])
    output = "One day Anna was walking her #{data['NUMBER']} #{data['UNIT_OF_MEASURE']} commute to #{data['PLACE']} and found a #{data['ADJECTIVE']} #{data['NOUN']} on the ground."
    puts output
    write_output_to_file(ARGV[0])
  end
end

def items_frequency(list, key)
  frequencies = list.map { |item| item[key] }
  frequencies.max_by { |item| frequencies.count(item) }
end

def display_stats(file)
  numeric_data = []
  text_data = []
  file.readlines.each do |line|
    data = JSON.parse line
    numeric_data << data['NUMBER'].to_f
    text_data << data.to_a[1...5].to_h
  end

  message = "****************STATISTICS****************
  * Most Common Unit of Measure: #{items_frequency(text_data, 'UNIT_OF_MEASURE')}
  * Most Common Place: #{items_frequency(text_data, 'PLACE')}
  * Most Common Adjective: #{items_frequency(text_data, 'ADJECTIVE')}
  * Most Common Noun: #{items_frequency(text_data, 'NOUN')}
  * Max Numeric Input: #{numeric_data.max}
  * Min Numeric Input: #{numeric_data.min}
  * Avg Numeric Input: #{(numeric_data.inject(0.0) { |sum, el| sum + el } / numeric_data.size).round(2)}
  ****************************************"
  puts message
end

def calculate_stats
  file = File.open('input_data.txt', 'r')
  if File.zero? file
    puts "Stories not found!!"
  else
    display_stats(file)
  end
  file.close
end

if options[:run]
  execute_main
elsif options[:stats]
  calculate_stats
end
