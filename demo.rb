require File.dirname(__FILE__)+'/rebex.rb'




#
#  replaceAll
#
puts "I am a ___, yup just a ___".replaceAll(  -/___/,  with:"string"  )
# replaces each ___ with "string" and outputs: I am a string, yup just a string


#
#  findFirst
#
puts "What time is it?"
puts "hello it is 23:00, 11:00pm".findFirst(-/[\T]/)     # finds Time: 23:00
# the \T is a shortcut for finding a time, but shortcuts only work inside []'s
# there are two times in the above string (23:00 and 11:00pm), but the .findFirst function only gets the first one

#
#  findAll
# 
puts "\nThe times are:"
for each_match in "hello it is 23:00, 8:00am".findAll(-/[\T]/)
    puts "   "+each_match[0]
end
puts ""

#
#  individual groups
#
puts "The times also are:"
# the following finds both 23:00 and 8:00am
for each_match in "hello it is 23:00, 8:00am".findAll(-/[\T]/)
    puts "    the hour is:"   + each_match["Hour"]
    puts "    the minute is:" + each_match["Minute"]
    puts ""
end


#
#  Finding a block
#
puts "hello 
this is not and indented block

i have a block
    this is the block
    it has multiple lines

".match(-/[\B]/)["Block"]
puts "\n"
