#
#
#
#   rebex 
#
#
#
    # How do I use this ?
    # =begin
    #     As of right now,
    #     There is a string (@rebex_string) where you can write 
    #     rebex (a version of regular expressions)
    #     then if you run the this file it will convert that string
    #     into rubys version of regular expressions

    #     rebex is at version 0.9 (almost ready for release)
    #     but obviously this current setup (this file) could use 
    #     some structural work
    # =end
    # # How does the code itself work?
    # =begin
    #     The processing goes like this
    #     start the noContext function
    #         it looks at 1 character in the @rebex_string
    #         if the character needs to be escaped
    #             then send the escaped character to the output string (meaning @rubex_string)
    #             and move on to the next character in the rebex_string
    #         if the charater is a backslash 
    #             then start the backslash context (decides what an escaped thing is)
    #         if the character is a [
    #             then start the bracket context
    #         etc
            
    #         each of the contexts basically do the same thing as the noContext function
    #         they generally look at the @rebex_string charcter-by-character
    #         and if they see something they recognize 
    #             they add it to the output (@rubex_string) and move on to the next character
    #         when the bracket context sees the ] character, 
    #             it ends itself and goes back to noContext 
    #         contexts can also be recursive 
    #             often times the when the bracket context sees another [ within itself
    #             it will activate a second (recursive) bracket context
    #             when that inner bracket context finds a ] 
    #                 it will end itself and go back to first bracket context
    #         once there are no more characters to be parsed, the noContext function ends 
    # =end 

    
    # TODO
        # Get rid of globals, put everything into one big function
        # Add better error/warning messages!
        # add a [Literal:] group
        # missing
            # subroutines
            # atomic groups
            # conditionals 
            # inline modifiers
        # add ruby replace command 
            # when the function gets a dictonary of strings and lambdas 
                # assume the string is rebex, convert it to ruby regex 
                # then have it simultaniously replace each regex pattern with the output from the lambda
            # when the function gets a list of [string,string] or [regex,string] or [string,lambda] or [regex,lambda]
                # run each of the [find_this, replace_with_this] pair sequentially
            # when the function gets a list of dictionaries of strings and lambdas 
                # sequentially do each simultanious replacement



# debugging helper 
    $indent = ""
    def iput(string_input)
        puts $indent + string_input
    end 

# its putting everthing in a class so that 
# class instance variables can be used like 
# global variables inside MyOwnScope

    # create a class and an init function 
    # to allow class-instance variables to behave like global variables
    # FIXME, instead of doing this^ just use procs/lambdas 
    class MyOwnScope
    attr_accessor :output
    def initialize(input_rebex_string)
    # dont indent ^these because they wrap 99.9% of everything in RebexToRubex


    #
    # globals 
    #
        @rebex_string = input_rebex_string
        @rubex_string = ""
        @char_reader_index = 0
        @capture_group_names = []


    #
    # helpers
    #
        def next_char
            return @rebex_string[@char_reader_index]
        end#def

        def remaining_string
            return @rebex_string[@char_reader_index...@rebex_string.length]
        end#def

    #
    #
    # contexts 
    #
    #

        #no context
        def noContext
            while @char_reader_index < @rebex_string.length
            # if its a specific regex char, then escape it
            result = next_char.match(/[\.\/\^\$\?\(\)]/)
            if result # any of ./^$?
                result = result[0]
                puts "found a char that needs to be escaped:"+result
                @rubex_string += '\\'+result
                @char_reader_index += 1
            # if \ then startBackslashContext
            elsif next_char.match(/\\/)
                startBackslashContext
            # if [ then startBracketContext
            elsif next_char.match(/\[/)
                startBracketContext
            # if { then startSquigglyBracketContext
            elsif next_char.match(/\{/)
                startSquigglyBracketContext
            # under normal circumstances, rubex_string things as-is
            else
                puts "I think this is a normal char:" + next_char
                # TODO, if this is a ] } or \ the user is probably messing something up 
                @rubex_string += next_char
                @char_reader_index += 1
            end#if 
            end#while
        end#def

        # backslash context
        def startBackslashContext
            # start of function 
                iput  "Backslash start"
                $indent +=  '    '
            # special escapes
            result = remaining_string.match(/^\\[sw#TDlWvVxfFPoeaALR]/)
            if result
                result = result[0]
                iput "okay I think there is a special escape:" + result
                @char_reader_index += 2
                # FIXME, rubex_string special
                case result
                    when '\s' #Space
                        @rubex_string += ' '
                    when '\w' #Whitespace, ex: \t \n
                        @rubex_string += '\s'
                    when '\#' #Number, ex: 10.5
                        #FIXME, there is going to have to be a custom non-greedy version 
                        @rubex_string += '(?:(?<!\d)(?:\d*\.\d+\b|\d+)(?!\d))' #TODO, should this have bounds? should it non-greedily get whitespace?
                    when '\T' #Time, ex:10:20pm
                        #FIXME, clean up this regex
                        #FIXME, there is going to have to be a custom non-greedy version 
                        @rubex_string += '(?:(?<!\d)(?<Hour>[0-9]|0[0-9]|1[0-9]|2[0-3])(?::|\.)(?<Minute>[0-5][0-9](?!\d))(?:(?::|\.)(?<Second>[0-5][0-9])|) ?(?<AmOrPm>(?:[Aa]|[Pp])\.?[Mm]\.?(?!\w)|))'
                        #Hour
                        #Minute
                        #Second
                        #AmOrPM
                    when '\D' #Date, ex:12/31/2017
                        #FIXME, this needs a day-month-year and a year-month-day format
                        #FIXME, there is going to have to be a custom non-greedy version 
                                    # month       3-letter is only letter-based-one supported atm           also numerical
                        @rubex_string +=  '(?<Month>(?i)jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec(?-i)|(?:[1-9]|0[1-9]|1[0-2]))'+
                                    # seperator
                                    '(?:-|\/|\.| )'+
                                    # day
                                    '(?<Day>31|30|[0-2]?[0-9])'+
                                    # seperator, this one allows commas 
                                    '(?:-|\/|\.| ,)'+
                                    # year YY or YYYY
                                    '(?<Year>\d\d|\d\d\d\d)'
                        #Day
                        #Month
                        #Year
                    when '\l' # letter 
                        @rubex_string += '[a-zA-Z]'
                    when '\W' # word 
                        @rubex_string += '(?:(?<![a-zA-Z])[a-zA-Z]+(?![a-zA-Z]))'
                    when '\v' # character in a variable name
                        @rubex_string += '[a-zA-Z0-9_]'
                    when '\V' # a variable name
                        @rubex_string += '(?<![a-zA-Z0-9_])[a-zA-Z_][a-zA-Z0-9_]*(?![a-zA-Z0-9_])'
                    when '\x' # a symbol
                        @rubex_string += '[^\w\s]'
                    when '\f' # a file name
                        #FIXME, add this later
                        @rubex_string += '\f'
                    when '\F' # a folder name
                        #FIXME, add this later
                        @rubex_string += '\F'
                    when '\P' # a path/directory name 
                        #FIXME, add this later
                        @rubex_string += '\P'
                    when '\o' # other
                        #FIXME, add this later
                        @rubex_string += '\o'
                    when '\e' #emoji 
                        #FIXME, add this later
                        @rubex_string += '\e'
                    when '\a' # any 
                        @rubex_string += '.'
                    when '\A' # all 
                        @rubex_string += '[\s\S]'
                    when '\L' # the line
                        # FIXME, this needs a custom non-greedy version
                        @rubex_string += '(?:(?:\n|^).*)'
                    when '\R' # the remaining line
                        # FIXME, this needs a custom non-greedy version 
                        @rubex_string += '(?:.*(?=\n|$))'
                    when '\y' # vertical tab 
                        @rubex_string += '\v'
                    when '\B' # block of code
                        # FIXME, actually implement this
                        @rubex_string += '\B'
                end#case

                
            # regular escapes
            else
                @char_reader_index += 1
                iput "okay I think I found a regular escape:" + next_char
                @rubex_string += "\\"+next_char # dont change anything
                @char_reader_index += 1
                #end this context 
            end
            # end of function 
                $indent = $indent[4...$indent.length]
                iput "end Backslash"
        end#def

        # bracket context
        def startBracketContext
            # start of function 
                iput ($indent + "Bracket start")
                $indent +=  '    '

            
            # Backreference group
            result = remaining_string.match(/^\[G:[a-z0-9_]+?\]/) # find [G:name_of_group]
            if result #1
                result = result[0]
                iput "I think i found a backreference:" + result
                # rubex_string(correct_code)
                # end this context at end of match 
                @char_reader_index += result.length
            else#1


            # Recursive match
            result = remaining_string.match(/^\[R:[a-z0-9_]*?\]/) # find [R:name_of_group] or [R:] (no group)
            if result #2 
                result = result[0]
                iput "I think i found a Recursive match:"+result
                # rubex_string(correct_code)
                # end this context at end of match
                @char_reader_index += result.length
            else#2
            
            
            # Comment 
            result = remaining_string.match(/^\[[^\]]+?:\]/) # find [ stuff :]
            if result #3
                result = result[0]
                iput "I think i found a comment match:"+result
                # rubex_string nothing
                @char_reader_index += result.length
            else#3
            
            
            # lookahead/behind/neg lookahead/ neg lookbehind
            result = remaining_string.match(/^\[(\<\<|\>\>|x\<|x\>|\<x|\>x):/) # find [<<:
            if result #4
                result = result[0]
                iput "I think i found the start of a look match:"+result
                iput "i found that at:"+ @char_reader_index.to_s
                case result
                when "[>>:"
                    @rubex_string += '(?='
                when "[<<:"
                    @rubex_string += '(?<='
                when "[x>:","[>x:"
                    @rubex_string += '(?!'
                when "[x<:","[<x:"
                    @rubex_string += '(?<!'
                end#case 
                @char_reader_index += 4
                startLookContext
            else#4
            
            # TODO atomic groups
            # TODO character class / neg character class
            result = remaining_string.match(/^\[(A|xA):/) # find [A: stuff ] or [xA: stuff ]
            if result #4.1
                iput "i think i found a character class" + result[0]
                if result[1] == "A"
                    @rubex_string += "["
                else 
                    @rubex_string += "[^"
                end
                @char_reader_index += result[0].length
                startCharacterClassContext
            else#4.1

            # TODO conditional 

            # named capture groups
            result = remaining_string.match(/^\[([a-z0-9_]+):/) # find [name:
            if result #5
                iput "found a named capture group"
                @capture_group_names << result[1] 
                @rubex_string += "(?<"+result[1]+'>'
                @char_reader_index += result[0].length
                startGroupContext
            else#5

            # non-capture groups 
            result = remaining_string.match(/^[a-zA-z0-9_]*[^a-zA-z0-9_:]/) 
            if result #6
                iput "found a non-capture group"
                @rubex_string += '(?:'
                @char_reader_index += 1
                startGroupContext
            end#6 non-capture group
            end#5 named capture group
            end#4.1 Character Class
            end#4 looks
            end#3 Comment
            end#2 Recursive
            end#1 Backreference


            
            #end of function
                $indent = $indent[4...$indent.length]
                iput "Bracket end"
        end#def

            def startLookContext
                # start of function 
                    iput "Look start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 

                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?()
                        result = result[0]
                        iput "found a char that needs to be escaped:"+result[0]
                        # rubex_string special
                        @rubex_string += '\\'+result
                        @char_reader_index += 1
                    # if \ then startBackslashContext
                    elsif next_char.match(/\\/)
                        startBackslashContext
                    # if [ then startBracketContext (again)
                    elsif next_char.match(/\[/)
                        startBracketContext
                    # if { then startSquigglyBracketContext
                    elsif next_char.match(/\{/)
                        startSquigglyBracketContext
                    # if ] then stop the context and rubex_string the closing )
                    elsif next_char.match(/\]/)
                        iput "found the end of the look"
                        @rubex_string += ')'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, rubex_string things as-is
                    else
                        iput "finding normal stuff in a lookahead:"+next_char
                        @rubex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    iput "Look end"
            end#def

            def startGroupContext
                # start of function 
                    iput "group start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 
                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?
                        result = result[0]
                        iput "found a char that needs to be escaped:"+result[0]
                        # rubex_string special
                        @rubex_string += '\\'+result
                        @char_reader_index += 1
                    # if \ then startBackslashContext
                    elsif next_char.match(/\\/)
                        startBackslashContext
                    # if [ then startBracketContext (again)
                    elsif next_char.match(/\[/)
                        startBracketContext
                    # if { then startSquigglyBracketContext
                    elsif next_char.match(/\{/)
                        startSquigglyBracketContext
                    # if ] then stop the context and rubex_string the closing )
                    elsif next_char.match(/\]/)
                        iput "found the end of the capture group"
                        @rubex_string += ')'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, rubex_string things as-is
                    else
                        iput "finding normal stuff in a capture group:"+next_char
                        @rubex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    iput "CaptureGroup end"
            end#def

            def startCharacterClassContext
                # start of function 
                    iput "CharacterClass start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 
                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?
                        result = result[0]
                        iput "found a char that needs to be escaped:"+result[0]
                        # rubex_string special
                        @rubex_string += '\\'+result
                        @char_reader_index += 1
                    # if \ then startBackslashContext
                    elsif next_char.match(/\\/)
                        startBackslashCharacterClassContext
                    # TODO, probably should add a 'warning for including [ in the group'
                    # if ] then stop the context and rubex_string the closing )
                    elsif next_char.match(/\]/)
                        iput "found the end of the character class group"
                        @rubex_string += ']'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, rubex_string things as-is
                    else
                        iput "finding normal stuff in a character class group:"+next_char
                        @rubex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    iput "CharacterClass end"
            end#def

            def startBackslashCharacterClassContext
                    # start of function 
                    iput "CharBackslash start"
                    $indent +=  '    '
                # special escapes
                result = remaining_string.match(/^\\[swlvxoea]/)
                if result
                    result = result[0]
                    iput "okay I think there is a special escape:" + result
                    @char_reader_index += 2
                    # FIXME, rubex_string special
                    case result
                        when '\s' #Space
                            @rubex_string += ' '
                        when '\w' #Whitespace, ex: \t \n
                            @rubex_string += '\s'
                        when '\l' # letter 
                            @rubex_string += '[a-zA-Z]'
                        when '\v' # character in a variable name
                            @rubex_string += '[a-zA-Z0-9_]'
                        when '\x' # a symbol
                            @rubex_string += '[^\w\s]'
                        when '\o' # other
                            #FIXME, add this later
                            @rubex_string += '\o'
                        when '\e' #emoji 
                            #FIXME, add this later
                            @rubex_string += '\e'
                        when '\a' # any 
                            @rubex_string += '.'
                        when '\y' # vertical tab 
                            @rubex_string += '\v'
                    end#case
                # regular escapes
                else
                    @char_reader_index += 1
                    iput "okay I think I found a regular escape:" + next_char
                    @rubex_string += "\\"+next_char # dont change anything
                    @char_reader_index += 1
                    #end this context 
                end
                # end of function 
                    $indent = $indent[4...$indent.length]
                    iput "okay Backslash"
            end#def 

        def startSquigglyBracketContext
                # start of function 
                    iput "SquigglyBracket start"
                    $indent +=  '    '
                    
                # if its a bound or anchor
                result = remaining_string.match(/^\{(b|c|S|E|LS|LE)\}/) # any of {b} , {c}, {e} , etc 
                if result #1
                    iput "found a bound/anchor that needs to be interpreted:"+result[1]
                    # rubex_string special
                    case result[1]
                    when "b"
                        @rubex_string += '\\b'
                    when "c"
                        @rubex_string += '\\B'
                    when "S"
                        @rubex_string += '^'
                    when "E"
                        @rubex_string += '$'
                    when "LS"
                        @rubex_string += '(?:(?<=\\n)|^)'
                    when "LE"
                        @rubex_string += '(?:(?=\\n)|$)'
                    end#case
                    @char_reader_index += result[0].length
                # TODO if \ then there is probably a user error
                # TODO, probably should add a warning for including stuff that shouldn't be in the thing 
                # non-Greedy operator
                elsif remaining_string.match(/^\{Min\}/)
                    #FIXME, make sure there is a quanitfier before the {Min}
                    iput "i think i found the non-greedy operator"
                    @rubex_string += '?'
                    @char_reader_index += 5
                # under normal circumstances, rubex_string things as-is
                else#1

                # normal repetition
                result = remaining_string.match(/^\{(\d*,\d*|\d+)\}/) # any of {1} , {1,2} , {1,} , {,1}
                if  result #2
                    iput "i think i found the repetition {}'s"+result[0]
                    @rubex_string += result[0]
                    @char_reader_index += result[0].length
                else#2

                # non-greedy repetition
                result = remaining_string.match(/^\{(?:Min(?:,| )?|)(\d*,\d*|\d+)(?:(?:,| )?Min|)\}/) # any of {Min,1} , {Min,1,2} , {1,Min} , {,1,Min}, {1,,Min}
                if  result #3
                    iput "I think I found the repetition {}'s with Min: "+result[0]
                    @rubex_string += '{'+result[1]+'}?'
                    @char_reader_index += result[0].length
                else#3
                    iput "im pretty sure there is a user error"
                    #FIXME, put an actual response here 
                    @rubex_string += next_char
                    @char_reader_index+=1
                end#3 
                end#2 
                end#1
                
                #end of function
                    $indent = $indent[4...$indent.length]
                    iput "SquigglyBracket end"
        end#def 

    #
    # runing an example 
    #
        @output = noContext
        puts "@rubex_string:" + @rubex_string
        ruby_replacement = Regexp.new(@rubex_string)
        string_to_test = 'Screen Shot 2017-11-21 at 5.26.30 PM'
        rubex_matches = string_to_test.match(ruby_replacement)
        puts rubex_matches.inspect


    # ignore this next line
    end#init
    end#class:MyOwnScope 

        # its allowing everthing in the MyOwnScope class 
        # to use class instance variables like they were global variables
def rebexToRegex(input_)
    just_for_scoping = MyOwnScope.new(input_) #Ends the initilize function and then the MyOwnScope class
    return just_for_scoping.output
end#def:rebexToRegex

puts rebexToRegex('{S}Screen[ |]Shot[ |][year:\d+]-[month:\d+]-\d+[ at |]\T{E}')

