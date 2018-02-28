#!/usr/bin/ruby
require 'rebex.rb'

if ARGV.length == 0
    raise "When reb was used, it wasn't given any arguments to find/replace"
# if one argument, then act like grep
elsif ARGV.length == 1
    find = ARGV[0]
    # gotta clear ARGV before getting stdin 
    ARGV.clear
    input = $stdin.read
    # return all matching lines
    find = rebexToRegex("{LS}[\\a*]"+find+"[\\a*]{LE}")
    puts input.scan(find)
# if two arguments, then act like sed
elsif ARGV.length == 2
    # get arguments 
        find        = ARGV[0]
        replacement = ARGV[1]
    # get standard input 
        # gotta clear ARGV before getting stdin 
        ARGV.clear
        input = $stdin.read
    # escape the find and replacement
        find = rebexToRegex(find)
        replacement = replacement.gsub(/"/,'\\"')   # escape the "
        replacement = replacement.gsub(/\#{/,'\#{') # escape interpolation #{}
        replacement = eval '"' + replacement + '"' # evaluate the string
    # output result
        puts input.gsub(find,replacement)
# if three arguments, then act like sed for files
elsif ARGV.length == 3
    # get arguments 
        find        = ARGV[0]
        replacement = ARGV[1]
        filename    = ARGV[2]
    # escape the find and replacement
        find = rebexToRegex(find)
        replacement = replacement.gsub(/"/,'\\"')   # escape the "
        replacement = replacement.gsub(/\#{/,'\#{') # escape interpolation #{}
        replacement = eval '"' + replacement + '"' # evaluate the string
    # open the file
        the_file          = File.open(filename,"w+")
        file_content_copy = the_file.read
    # edit the file 
        file_content.gsub!(find,replacement)
        the_file.write(file_content_copy)
        the_file.close
end#if 
