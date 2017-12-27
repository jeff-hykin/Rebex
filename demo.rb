require File.dirname(__FILE__)+'/rebex.rb'


puts "hello 
this is not and indented block

i have a block
    this is the block
    it has multiple lines

".match(-/[\B]/)["Block"]
puts "\n"

puts "I am a ...".replace(  -/.../,  with:"string"  ) # outputs: I am a string
puts "hello it is 23:00, 8:00am".findfirst(-/[\T]/)     # finds Time: 23:00

# the following finds both 23:00 and 8:00am
puts "The times are:"
for each_match in "hello it is 23:00, 8:00am".findeach(-/[\T]/)
    puts "   "+each_match[0]
end
puts ""

puts "The times also are:"
# the following finds both 23:00 and 8:00am
for each_match in "hello it is 23:00, 8:00am".findeach(-/[\T]/)
    puts "    the hour is:" + each_match["Hour"]
    puts "    the minute is:" + each_match["Minute"]
    puts ""
end
