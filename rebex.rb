#
#
#
#   rebex 
#
#
#
    # How does the code work internally?
        # The processing goes like this
        # start the noContext function
        #     it looks at 1 character in the @rebex_string
        #     if the character needs to be escaped
        #         then send the escaped character to the output string (meaning @regex_string)
        #         and move on to the next character in the rebex_string
        #     if the charater is a backslash 
        #         then start the backslash context (which decides what an escaped thing should be)
        #     if the character is a [
        #         then start the bracket context
        #     etc
            
        #     each of the contexts basically do the same thing as the noContext function
        #     they generally look at the @rebex_string charcter-by-character
        #     and if they see something they recognize 
        #         they add it to the output (@regex_string) and move on to the next character
        #     when the bracket context sees the ] character, 
        #         it ends itself and goes back to noContext 
        #     contexts can also be recursive 
        #         often times the when the bracket context sees another [ within itself
        #         it will activate a second (recursive) bracket context
        #         when that inner bracket context finds a ] 
        #             it will end itself and go back to first bracket context
        #     once there are no more characters to be parsed, the noContext function ends 

    
    # TODO
        # Get rid of scope thing, use procs instead
        # get rid of the result = stuff.match; if result
            # replace it with if stuff match; Regexp:last_match
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
    $Debugging = false
    $indent = ""
    def dput(string_input)
        if $Debugging
            puts $indent + string_input
        end
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
    # dont indent ^these because they wrap 99.9% of everything in rebexToRegex


    #
    # pesudo-globals (instance variables)
    #
        @rebex_string = input_rebex_string
        @regex_string = ""
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
                dput "found a char that needs to be escaped:"+result
                @regex_string += '\\'+result
                @char_reader_index += 1
            # if \ then startBackslashContext
            elsif next_char.match(/\\/)
                # @regex_string += '\\'+result
                # @char_reader_index += 1
                startBackslashContext
            # if [ then startBracketContext
            elsif next_char.match(/\[/)
                startBracketContext
            # if { then startSquigglyBracketContext
            elsif next_char.match(/\{/)
                startSquigglyBracketContext
            # under normal circumstances, regex_string things as-is
            else
                dput "I think this is a normal char:" + next_char
                # TODO, if this is a ] } or \ the user is probably messing something up 
                @regex_string += next_char
                @char_reader_index += 1
            end#if 
            end#while
        end#def

        # backslash context
        def startBackslashContext
            # start of function 
                dput  "Backslash start"
                $indent +=  '    '
            # special escapes
            result = remaining_string.match(/^\\[sw#TDlWvVxfFPoeaALR]/)
            if result
                result = result[0]
                dput "okay I think there is a special escape:" + result
                @char_reader_index += 2
                # FIXME, regex_string special
                case result
                    when '\s' #Space
                        @regex_string += ' '
                    when '\w' #Whitespace, ex: \t \n
                        @regex_string += '\s'
                    when '\#' #Number, ex: 10.5
                        #FIXME, there is going to have to be a custom non-greedy version 
                        @regex_string += '(?:(?<!\d)(?:\d*\.\d+\b|\d+)(?!\d))' #TODO, should this have bounds? should it non-greedily get whitespace?
                    when '\T' #Time, ex:10:20pm
                        #FIXME, clean up this regex
                        #FIXME, there is going to have to be a custom non-greedy version 
                        @regex_string += '(?<Time>(?:(?<!\d)(?<Hour>[0-9]|0[0-9]|1[0-9]|2[0-3])(?::|\.)(?<Minute>[0-5][0-9](?!\d))(?:(?::|\.)(?<Second>[0-5][0-9])|) ?(?<AmOrPm>(?:[Aa]|[Pp])\.?[Mm]\.?(?!\w)|)))'
                        #Hour
                        #Minute
                        #Second
                        #AmOrPM
                    when '\D' #Date, ex:12/31/2017
                        #FIXME, this needs a day-month-year and a year-month-day format
                        #FIXME, there is going to have to be a custom non-greedy version 
                                    # month       3-letter is only letter-based-one supported atm           also numerical
                        @regex_string +=  '(?<Date>(?<Month>(?i)jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec(?-i)|(?:[1-9]|0[1-9]|1[0-2]))'+
                                    # seperator
                                    '(?:-|\/|\.| )'+
                                    # day
                                    '(?<Day>31|30|[0-2]?[0-9])'+
                                    # seperator, this one allows commas 
                                    '(?:-|\/|\.| |, ?)'+
                                    # year YY or YYYY
                                    '(?<Year>\d\d\d\d|\d\d))'
                        #Day
                        #Month
                        #Year
                    when '\l' # letter 
                        @regex_string += '[a-zA-Z]'
                    when '\W' # word 
                        @regex_string += '(?:(?<![a-zA-Z])[a-zA-Z]+(?![a-zA-Z]))'
                    when '\v' # character in a variable name
                        @regex_string += '[a-zA-Z0-9_]'
                    when '\V' # a variable name
                        @regex_string += '(?<![a-zA-Z0-9_])[a-zA-Z_][a-zA-Z0-9_]*(?![a-zA-Z0-9_])'
                    when '\x' # a symbol
                        @regex_string += '[^\w\s]'
                    when '\f' # a file name
                        #FIXME, add this later
                        @regex_string += '\f'
                    when '\F' # a folder name
                        #FIXME, add this later
                        @regex_string += '\F'
                    when '\P' # a path/directory name 
                        #FIXME, add this later
                        @regex_string += '\P'
                    when '\o' # other
                        #FIXME, add this later
                        @regex_string += '\o'
                    when '\e' #emoji 
                        #FIXME, add this later
                        @regex_string += '\e'
                    when '\a' # any 
                        @regex_string += '.'
                    when '\A' # all 
                        @regex_string += '[\s\S]'
                    when '\L' # the line
                        # FIXME, this needs a custom non-greedy version
                        @regex_string += '(?:(?:\n|^).*)'
                    when '\R' # the remaining line
                        # FIXME, this needs a custom non-greedy version 
                        @regex_string += '(?:.*(?=\n|$))'
                    when '\y' # vertical tab 
                        @regex_string += '\v'
                    when '\B' # block of code
                        # FIXME, actually implement this
                        @regex_string += '\B'
                end#case

                
            # regular escapes
            else
                @char_reader_index += 1
                dput "okay I think I found a regular escape:" + next_char
                @regex_string += "\\"+next_char # dont change anything
                @char_reader_index += 1
                #end this context 
            end
            # end of function 
                $indent = $indent[4...$indent.length]
                dput "end Backslash"
        end#def

        # bracket context
        def startBracketContext
            # start of function 
                dput ($indent + "Bracket start")
                $indent +=  '    '

            
            # Backreference group
            result = remaining_string.match(/^\[G:[a-z0-9_]+?\]/) # find [G:name_of_group]
            if result #1
                result = result[0]
                dput "I think i found a backreference:" + result
                # regex_string(correct_code)
                # end this context at end of match 
                @char_reader_index += result.length
            else#1


            # Recursive match
            result = remaining_string.match(/^\[R:[a-z0-9_]*?\]/) # find [R:name_of_group] or [R:] (no group)
            if result #2 
                result = result[0]
                dput "I think i found a Recursive match:"+result
                # regex_string(correct_code)
                # end this context at end of match
                @char_reader_index += result.length
            else#2
            
            
            # Comment 
            result = remaining_string.match(/^\[[^\]]+?:\]/) # find [ stuff :]
            if result #3
                result = result[0]
                dput "I think i found a comment match:"+result
                # regex_string nothing
                @char_reader_index += result.length
            else#3
            
            
            # lookahead/behind/neg lookahead/ neg lookbehind
            result = remaining_string.match(/^\[(\<\<|\>\>|x\<|x\>|\<x|\>x):/) # find [<<:
            if result #4
                result = result[0]
                dput "I think i found the start of a look match:"+result
                dput "i found that at:"+ @char_reader_index.to_s
                case result
                when "[>>:"
                    @regex_string += '(?='
                when "[<<:"
                    @regex_string += '(?<='
                when "[x>:","[>x:"
                    @regex_string += '(?!'
                when "[x<:","[<x:"
                    @regex_string += '(?<!'
                end#case 
                @char_reader_index += 4
                startLookContext
            else#4
            
            # TODO atomic groups
            # TODO character class / neg character class
            result = remaining_string.match(/^\[(A|xA|Any|xAny):/) # find [A: stuff ] or [xA: stuff ]
            if result #4.1
                dput "i think i found a character class" + result[0]
                if result[1] == "A" or result[1] == "Any"
                    @regex_string += "["
                else 
                    @regex_string += "[^"
                end
                @char_reader_index += result[0].length
                startCharacterClassContext
            else#4.1

            # TODO conditional 

            # named capture groups
            result = remaining_string.match(/^\[([a-z0-9_]+):/) # find [name:
            if result #5
                dput "found a named capture group"
                @capture_group_names << result[1] 
                @regex_string += "(?<"+result[1]+'>'
                @char_reader_index += result[0].length
                startGroupContext
            else#5

            # non-capture groups 
            result = remaining_string.match(/^[a-zA-z0-9_]*[^a-zA-z0-9_:]/) 
            if result #6
                dput "found a non-capture group"
                @regex_string += '(?:'
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
                dput "Bracket end"
        end#def

            def startLookContext
                # start of function 
                    dput "Look start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 

                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?()
                        result = result[0]
                        dput "found a char that needs to be escaped:"+result[0]
                        # regex_string special
                        @regex_string += '\\'+result
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
                    # if ] then stop the context and regex_string the closing )
                    elsif next_char.match(/\]/)
                        dput "found the end of the look"
                        @regex_string += ')'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, regex_string things as-is
                    else
                        dput "finding normal stuff in a lookahead:"+next_char
                        @regex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    dput "Look end"
            end#def

            def startGroupContext
                # start of function 
                    dput "group start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 
                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?
                        result = result[0]
                        dput "found a char that needs to be escaped:"+result[0]
                        # regex_string special
                        @regex_string += '\\'+result
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
                    # if ] then stop the context and regex_string the closing )
                    elsif next_char.match(/\]/)
                        dput "found the end of the capture group"
                        @regex_string += ')'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, regex_string things as-is
                    else
                        dput "finding normal stuff in a capture group:"+next_char
                        @regex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    dput "CaptureGroup end"
            end#def

            def startCharacterClassContext
                # start of function 
                    dput "CharacterClass start"
                    $indent +=  '    '
                
                while @char_reader_index < @rebex_string.length 
                    result = next_char.match(/[\.\/\^\$\?\(\)]/)            
                    if result # any of ./^$?
                        result = result[0]
                        dput "found a char that needs to be escaped:"+result[0]
                        # regex_string special
                        @regex_string += '\\'+result
                        @char_reader_index += 1
                    # if \ then startBackslashContext
                    elsif next_char.match(/\\/)
                        startBackslashCharacterClassContext
                    # TODO, probably should add a 'warning for including [ in the group'
                    # if ] then stop the context and regex_string the closing )
                    elsif next_char.match(/\]/)
                        dput "found the end of the character class group"
                        @regex_string += ']'
                        @char_reader_index += 1
                        break
                    # under normal circumstances, regex_string things as-is
                    else
                        dput "finding normal stuff in a character class group:"+next_char
                        @regex_string += next_char
                        @char_reader_index += 1
                    end#if
                    
                end#while
                #end of function
                    $indent = $indent[4...$indent.length]
                    dput "CharacterClass end"
            end#def

            def startBackslashCharacterClassContext
                    # start of function 
                    dput "CharBackslash start"
                    $indent +=  '    '
                # special escapes
                result = remaining_string.match(/^\\[swlvxoea]/)
                if result
                    result = result[0]
                    dput "okay I think there is a special escape:" + result
                    @char_reader_index += 2
                    # FIXME, regex_string special
                    case result
                        when '\s' #Space
                            @regex_string += ' '
                        when '\w' #Whitespace, ex: \t \n
                            @regex_string += '\s'
                        when '\l' # letter 
                            @regex_string += '[a-zA-Z]'
                        when '\v' # character in a variable name
                            @regex_string += '[a-zA-Z0-9_]'
                        when '\x' # a symbol
                            @regex_string += '[^\w\s]'
                        when '\o' # other
                            #FIXME, add this later
                            @regex_string += '\o'
                        when '\e' #emoji 
                            #FIXME, add this later
                            @regex_string += '\e'
                        when '\a' # any 
                            @regex_string += '.'
                        when '\y' # vertical tab 
                            @regex_string += '\v'
                    end#case
                # regular escapes
                else
                    @char_reader_index += 1
                    dput "okay I think I found a regular escape:" + next_char
                    @regex_string += "\\"+next_char # dont change anything
                    @char_reader_index += 1
                    #end this context 
                end
                # end of function 
                    $indent = $indent[4...$indent.length]
                    dput "okay Backslash"
            end#def 

        def startSquigglyBracketContext
                # start of function 
                    dput "SquigglyBracket start"
                    $indent +=  '    '
                    
                # if its a bound or anchor
                result = remaining_string.match(/^\{(b|c|S|E|LS|LE)\}/) # any of {b} , {c}, {e} , etc 
                if result #1
                    dput "found a bound/anchor that needs to be interpreted:"+result[1]
                    # regex_string special
                    case result[1]
                    when "b"
                        @regex_string += '\\b'
                    when "c"
                        @regex_string += '\\B'
                    when "S"
                        @regex_string += '^'
                    when "E"
                        @regex_string += '$'
                    when "LS"
                        @regex_string += '(?:(?<=\\n)|^)'
                    when "LE"
                        @regex_string += '(?:(?=\\n)|$)'
                    end#case
                    @char_reader_index += result[0].length
                # TODO if \ then there is probably a user error
                # TODO, probably should add a warning for including stuff that shouldn't be in the thing 
                # non-Greedy operator
                elsif remaining_string.match(/^\{Min\}/)
                    #FIXME, make sure there is a quanitfier before the {Min}
                    dput "i think i found the non-greedy operator"
                    @regex_string += '?'
                    @char_reader_index += 5
                # under normal circumstances, regex_string things as-is
                else#1

                # normal repetition
                result = remaining_string.match(/^\{(\d*,\d*|\d+)\}/) # any of {1} , {1,2} , {1,} , {,1}
                if  result #2
                    dput "i think i found the repetition {}'s"+result[0]
                    @regex_string += result[0]
                    @char_reader_index += result[0].length
                else#2

                # non-greedy repetition
                result = remaining_string.match(/^\{(?:Min(?:,| )?|)(\d*,\d*|\d+)(?:(?:,| )?Min|)\}/) # any of {Min,1} , {Min,1,2} , {1,Min} , {,1,Min}, {1,,Min}
                if  result #3
                    dput "I think I found the repetition {}'s with Min: "+result[0]
                    @regex_string += '{'+result[1]+'}?'
                    @char_reader_index += result[0].length
                else#3
                    dput "im pretty sure there is a user error"
                    #FIXME, put an actual response here 
                    @regex_string += next_char
                    @char_reader_index+=1
                end#3 
                end#2 
                end#1
                
                #end of function
                    $indent = $indent[4...$indent.length]
                    dput "SquigglyBracket end"
        end#def 

        # set the output 
        # FIXME, this will be changed to a regular return 
        # once all of this code gets taken out o
        noContext
        @output = @regex_string

    # End the using-class-as-scope
    end#init
    end#class:MyOwnScope 

        # its allowing everthing in the MyOwnScope class 
        # to use class instance variables like they were global variables
    def rebexToRegex(input_)
        just_for_scoping = MyOwnScope.new(input_) #Ends the initilize function and then ends the MyOwnScope class
        return Regexp.new(just_for_scoping.output)
    end#def:rebexToRegex


# add a replace method 
class String
    def replace(regex,with:nil)
        self.gsub(regex,with)
    end
    def replace!(regex,with:nil)
        self.gsub!(regex,with)
    end
    def extract!(regex)
        output = self.match(regex)
        self.gsub!(regex,"")
        return output
    end
    def findfirst(regex)
        self.match(regex)
    end
    def findeach(regex)
        matches = []
        self.scan(regex){ matches << $~ }
        return matches
    end
    #TODO make find
end



class Regexp

    # create an effective raw string in Ruby
    def ~
        return (self.inspect[1,self.inspect.length-2])
    end


    # add the regex syntax into the regex method
    def -@
        escaped_string = self.inspect[1,self.inspect.length-2]
        return rebexToRegex(escaped_string)
    end

    # add a conversion method
    def to_reb
        escaped_string = self.inspect[1,self.inspect.length-2]
        return rebexToRegex(escaped_string)
    end
end


