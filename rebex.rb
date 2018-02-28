#
# helper tools 
#
    # debugging helper 
    $Debugging = false
    $indent = ""
    def dput(string_input)
        if $Debugging
            puts $indent + string_input
        end
    end 


#
#
#
#   rebex 
#
#
#
    # How does the code work internally?
        # The processing goes like this
        # start the noContext[] function
        #     it looks at 1 character in the rebex_string
        #     if the character needs to be escaped
        #         then send the escaped character to the output string (meaning regex_string)
        #         and move on to the next character in the rebex_string
        #     if the charater is a backslash 
        #         then start the backslash context (which decides what an escaped thing should be)
        #     if the character is a [
        #         then start the bracket context
        #     etc
            
        #     each of the contexts basically do the same thing as the noContext[] function
        #     they generally look at the rebex_string charcter-by-character
        #     and if they see something they recognize 
        #         they add it to the output (regex_string) and move on to the next character
        #     when the bracket context sees the ] character, 
        #         it ends itself and goes back to noContext[] 
        #     contexts can also be recursive 
        #         often times the when the bracket context sees another [ within itself
        #         it will activate a second (recursive) bracket context
        #         when that inner bracket context finds a ] 
        #             it will end itself and go back to first bracket context
        #     once there are no more characters to be parsed, the noContext[] function ends 

    
    # TODO
        # add case matching options
        # DONE, change all ^ and $ to \A and \z 
        # fix because of interpolation #{}, theres no way to do a raw literal #{}
        # for reby
            # DONE, create box-only syntax
            # add a [Literal:] group
            # add a [StartsWith:] group
            # add a [EndsWith:] group
            # create the group subsititution syntax (replace *stuff* with [Group1])
            # FIXME, what to do about unicode and hex
            # add specials:
                # folder name
                # file name
                # directory
                # emoji
            # warnings / errors
                # make warning checking that everything before a quanifier is a pattern
                # add a warning for infinite matches
                # add warning for bad {} anchors/bounds/quantifiers
                # add a warning for non-matching amount of []'s or {}'s
                # add warning for making a group with upper case letters
                # add a warning for variable-length lookbehinds
        # clean up the date \D regex
        # add the custom non-greedy forms of special escapes 
        # add named inserts ( [*number*] [*word*] [*block*])
        # make sure the \k<> doesnt accidently appear unescaped
        # add the 'Unescaped' regex function
        # add warning for referencing a group that doesn't exist
        # make warning checking if there is a quanitfier before the {Min}
        # maybe Create "regex functions" with block having title and body arguments
        # get rid of the result = stuff.match; if result
            # replace it with if stuff match; Regexp:last_match
        # create interactive warnings and errors
        
        # missing
            # subroutines
            # conditionals 
            # inline modifiers
            # flags 
        # add ruby replace command with features:
            # when the function gets a dictonary of strings and lambdas 
                # assume the string is rebex, convert it to ruby regex 
                # then have it simultaniously replace each regex pattern with the output from the lambda
            # when the function gets a list of [string,string] or [regex,string] or [string,lambda] or [regex,lambda]
                # run each of the [find_this, replace_with_this] pair sequentially
            # when the function gets a list of dictionaries of strings and lambdas 
                # sequentially do each simultanious replacement

# reference = 
#     {
#         ruby_escapes:
#             {
#                 Space:     '\s',
#                 Newline:   '\n',
#                 Tab:       '\t',
#                 Backslash: '\\\\'
#             },
#         rebex_escapes:
#             {
#                 Colon:              '\:',
#                 SquareBracketStart: '\[',
#                 SquareBracketEnd:   '\]',
#                 CurlyBracketStart:  '\{',
#                 CurlyBracketEnd:    '\}',
#                 Star:               '\*',
#                 Plus:               '\+',
#                 Bar:                '\|'
#             },
#         rebex_specials:
#             {
#                 Digit:             '\d',
#                 Whitespace:        '\w',
#                 Letter:            '\l',
#                 char_in_var_name:  '\v',
#                 Symbols:           '\x',
#                 Other:             '\o',
#                 Emoji:             '\e',
#                 Any:               '\a',
#                 AbsAny:            '\A',
#                 VertTab:           '\y'
#             },
#         rebex_super_specials:
#             {
#                 Number:    '\#',
#                 Time:      '\T',
#                 Date:      '\D',
#                 Word:      '\W',
#                 Variable:  '\V',
#                 File:      '\f',
#                 Folder:    '\F',
#                 Path:      '\P',
#                 LeftSide:  '\L',
#                 RightSide: '\R',
#                 Block:     '\B'
#             }
#     }



# ruby_escapes         = [ '\s', '\n', '\t', '\\\\' ]
# rebex_escapes        = [ '\:', '\[', '\]', '\{', '\}', '\*', '\+' , '\|']
# regex_extra_escapes  = [ '\.', '\/', '\^', '\$', '\?', '\(', '\)', '\<', '\>', '\=', '\!' ]
# rebex_specials       = [ '\d', '\w', '\l', '\v', '\x', '\o', '\e', '\a', '\A', '\y' ]
# rebex_super_specials = [ '\#', '\T', '\D', '\W', '\V', '\f', '\F', '\P', '\L', '\R', '\B' ]




# FIXME, escape all the occurances of unicode and hex and bells (\a) form feeds (\f) etc
# FIXME, fix all of the ^$ situations with \A and \z

# its putting everthing in a class so that 
# class instance variables can be used like 
# global variables inside MyOwnScope

# a function for converting rebex to rubex
def rebexToRegex(input_)
    #
    # main variables
    #
        rebex_string        = input_
        rebex_string_length = rebex_string.length
        char_reader_index   = 0
        regex_string        = ""
        capture_group_names = []
        last_pattern_was    = ""
        # regular character
        # ruby escape
        # rebex escape
        # regex escape
        # rebex special
        # rebex super special
        # NA (comment or none)

        #regular_characters_pat   = /\A[A-Za-z0-9~`@%&_;'",/]/
        ruby_escapes_pat             = /\A(\\s|\\n|\\t|\\\\)/
        rebex_escapes_pat            = /\A(\\:|\\\[|\\\]|\\\{|\\\}|\\\*|\\\+|\\\|)/
        regex_extra_escapes_pat      = /\A[\.\/\^\$\?\(\)\<\>\=\!]/
        rebex_specials_pat           = /\A(\\d|\\w|\\l|\\v|\\x|\\o|\\e|\\a|\\A|\\y)/
        bracket_quanifier_pattern    = /\A\{((?:Min(?:,| )?|)(\d*,\d*|\d+)(?:(?:,| )?Min|))\}/ # any of {Min,1} , {Min,1,2} , {1,Min} , {,1,Min}, {1,,Min}
    #
    # helper procs
    #
        next_char = Proc.new do
            rebex_string[char_reader_index]
        end#proc

        remaining_string = Proc.new do
            rebex_string[char_reader_index...rebex_string_length]
        end#proc

        there_are_atleast_2_chars_left = Proc.new do
            char_reader_index+1 < rebex_string_length
        end

    #
    #
    # contexts 
    #
    #

        # backslash context
        startBackslashContext = Proc.new do
            # start of function 
                dput  "Backslash start"
                $indent +=  '    '
            # special escapes
            result = remaining_string[].match(/\A\\[sw#TDlWvVxfFPoeaALRyB:]/)
            if result
                result = result[0]
                dput "okay I think there is a special escape:" + result
                char_reader_index += 2
                # FIXME, regex_string special
                case result
                    when '\:'
                        regex_string += ':'
                    when '\s' #Space
                        regex_string += ' '
                    when '\w' #Whitespace, ex: \t \n
                        regex_string += '\s'
                    when '\#' #Number, ex: 10.5
                        #FIXME, there is going to have to be a custom non-greedy version 
                        regex_string += '(?:(?<!\d)(?:\d*\.\d+\b|\d+)(?!\d))' #TODO, should this have bounds? should it non-greedily get whitespace?
                    when '\T' #Time, ex:10:20pm
                        #FIXME, clean up this regex
                        #FIXME, there is going to have to be a custom non-greedy version 
                        regex_string += '(?<Time>(?:(?<!\d)(?<Hour>[0-9]|0[0-9]|1[0-9]|2[0-3])(?::|\.)(?<Minute>[0-5][0-9](?!\d))(?:(?::|\.)(?<Second>[0-5][0-9])|) ?(?<AmOrPm>(?:[Aa]|[Pp])\.?[Mm]\.?(?!\w)|)))'
                        #Hour
                        #Minute
                        #Second
                        #AmOrPM
                    when '\D' #Date, ex:12/31/2017
                        #FIXME, this needs a day-month-year and a year-month-day format
                        #FIXME, there is going to have to be a custom non-greedy version 
                                    # month       3-letter is only letter-based-one supported atm           also numerical
                        regex_string +=  '(?<Date>(?<Month>(?i)jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec(?-i)|(?:[1-9]|0[1-9]|1[0-2]))'+
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
                        regex_string += '[a-zA-Z]'
                    when '\W' # word 
                        regex_string += '(?:(?<![a-zA-Z])[a-zA-Z]+(?![a-zA-Z]))'
                    when '\v' # character in a variable name
                        regex_string += '[a-zA-Z0-9_]'
                    when '\V' # a variable name
                        regex_string += '(?<![a-zA-Z0-9_])[a-zA-Z_][a-zA-Z0-9_]*(?![a-zA-Z0-9_])'
                    when '\x' # a symbol
                        regex_string += '[^\w\s]'
                    when '\f' # a file name
                        #FIXME, add this later
                        regex_string += '\\\\f'
                    when '\F' # a folder name
                        #FIXME, add this later
                        regex_string += '\\\\F'
                    when '\P' # a path/directory name 
                        #FIXME, add this later
                        regex_string += '\\\\P'
                    when '\o' # other
                        #FIXME, add this later
                        regex_string += '\\\\o'
                    when '\e' #emoji 
                        #FIXME, add this later
                        regex_string += '\\\\e'
                    when '\a' # any 
                        regex_string += '.'
                    when '\A' # all 
                        regex_string += '[\s\S]'
                    when '\L' # the left side of a line
                        # FIXME, this needs a custom non-greedy version
                        regex_string += '(?:(?:\n|\A).*)'
                    when '\R' # the right side of a line
                        # FIXME, this needs a custom non-greedy version 
                        regex_string += '(?:.*$)'
                    when '\y' # vertical tab 
                        regex_string += '\v'
                    when '\B' # block of code
                        # original_indent = /(?<OriginalIndent>(?: |\t)*)/
                        # title_          = /(?<Title>.+)/
                        # first_line      = /^#{original_indent}#{title_}/
                        # enuf_indent     = /(?<Indent>\k<OriginalIndent>(?: |\t)+)/
                        # content_line    = /\n#{enuf_indent}(?:.+)$/
                        # blank_line      = /\n[ \t]*$/
                        # any_line        = /(?:#{content_line}|#{blank_line})/
                        # block_          = /(?<Block>(?:#{any_line})*#{content_line})/
                        # final_pattern   = /#{first_line}#{block_}/
                        regex_string += '^(?<OriginalIndent>(?: |\t)*)(?<Title>.+)(?<Block>(?:(?:\n(?<Indent>\k<OriginalIndent>(?: |\t)+)(?:.+)$|\n[ \t]*$))*\n(?<Indent>\k<OriginalIndent>(?: |\t)+)(?:.+)$)'

                end#case

                
            # regex escapes that need to be extra escaped
            elsif remaining_string[].match(/\A\\[gk'&0-9]/)
                char_reader_index += 1
                dput "okay I think I found a regex escape that needs to be escaped again:" + next_char[]
                regex_string += "\\\\"+next_char[] # dont change anything
                char_reader_index += 1
            # regular/meaningless escapes
            else
                char_reader_index += 1
                dput "okay I think I found a regular/meaningless escape:" + next_char[]
                regex_string += "\\"+next_char[] # dont change anything
                char_reader_index += 1
                #end this context 
            end
            # end of function 
                $indent = $indent[4...$indent.length]
                dput "end Backslash"
        end#proc

        startCurlyBracketContext = Proc.new do
                # start of function 
                    dput "CurlyBracket start"
                    $indent +=  '    '
                    
                # if its a bound or anchor
                result = remaining_string[].match(/\A\{(b|c|S|E|LS|LE)\}/) # any of {b} , {c}, {e} , etc 
                if result #1
                    dput "found a bound/anchor that needs to be interpreted:"+result[1]
                    # regex_string special
                    case result[1]
                    when "b"
                        regex_string += '\\b'
                    when "c"
                        regex_string += '\\B'
                    when "S"
                        regex_string += '\A'
                    when "E"
                        regex_string += '\z'
                    when "LS"
                        regex_string += '^'
                    when "LE"
                        regex_string += '$'
                    end#case
                    char_reader_index += result[0].length
                # TODO if \ then there is probably a user error
                # TODO, probably should add a warning for including stuff that shouldn't be in the thing 
                # non-Greedy operator
                elsif remaining_string[].match(/\A\{Min\}/)
                    #FIXME, make sure there is a quanitfier before the {Min}
                    dput "i think i found the non-greedy operator"
                    regex_string += '?'
                    char_reader_index += 5
                else#1

                # normal repetition
                result = remaining_string[].match(/\A\{(\d*,\d*|\d+)\}/) # any of {1} , {1,2} , {1,} , {,1}
                if  result #2
                    dput "i think i found the repetition {}'s"+result[0]
                    regex_string += result[0]
                    char_reader_index += result[0].length
                else#2

                # non-greedy repetition
                result = remaining_string[] =~ bracket_quanifier_pattern # any of {Min,1} , {Min,1,2} , {1,Min} , {,1,Min}, {1,,Min}
                if  result #3
                    dput "I think I found the repetition {}'s with Min: "+result[0]
                    regex_string += '{'+result[1]+'}?'
                    char_reader_index += result[0].length
                else#3
                    dput "im pretty sure there is a user error"
                    #FIXME, put an actual response here 
                    regex_string += next_char[]
                    char_reader_index+=1
                end#3 
                end#2 
                end#1
                
                #end of function
                    $indent = $indent[4...$indent.length]
                    dput "CurlyBracket end"
        end#proc 

        # bracket context 
        # declare this here so that the Group,Character,and BackslashCharacterClass contexts
        # have a BracketContext to refer to
        startBracketContext  = Proc.new do        end#proc

        startLookContext = Proc.new do
            # start of function 
                dput "Look start"
                $indent +=  '    '
            
            while char_reader_index < rebex_string_length 

                result = next_char[].match(/[\.\/\^\$\?\(\)]/)            
                if result # any of ./^$?()
                    result = result[0]
                    dput "found a char that needs to be escaped:"+result[0]
                    # regex_string special
                    regex_string += '\\'+result
                    char_reader_index += 1
                # if \ then startBackslashContext[]
                elsif next_char[].match(/\\/)
                    startBackslashContext[]
                # if [ then startBracketContext[] (again)
                elsif next_char[].match(/\[/)
                    startBracketContext[]
                # if { then startCurlyBracketContext[]
                elsif next_char[].match(/\{/)
                    startCurlyBracketContext[]
                # if ] then stop the context and regex_string the closing )
                elsif next_char[].match(/\]/)
                    dput "found the end of the look"
                    regex_string += ')'
                    char_reader_index += 1
                    break
                # convert the ~ into * 
                elsif next_char[].match(/~/)
                    regex_string += "*"
                    char_reader_index += 1
                # convert the * into (?:.+)
                elsif next_char[].match(/\*/)
                    regex_string += "(?:.+)"
                    char_reader_index += 1
                # under normal circumstances, regex_string things as-is
                else
                    dput "finding normal stuff in a lookahead:"+next_char[]
                    regex_string += next_char[]
                    char_reader_index += 1
                end#if
                
            end#while
            #end of function
                $indent = $indent[4...$indent.length]
                dput "Look end"
        end#proc

        startGroupContext = Proc.new do
            # start of function 
                dput "group start"
                $indent +=  '    '
            
            while char_reader_index < rebex_string_length 
                if next_char[] =~ regex_extra_escapes_pat # any of ./^$?()
                    dput "found a char that needs to be escaped:"+Regexp.last_match[0]
                    # regex_string special
                    regex_string += '\\'+Regexp.last_match[0]
                    char_reader_index += 1
                # if \ then startBackslashContext[]
                elsif next_char[].match(/\\/)
                    startBackslashContext[]
                # if [ then startBracketContext[] (again/recursion)
                elsif next_char[].match(/\[/)
                    startBracketContext[]
                # if { then startCurlyBracketContext[]
                elsif next_char[].match(/\{/)
                    startCurlyBracketContext[]
                # if ] then stop the context and regex_string the closing )
                elsif next_char[].match(/\]/)
                    dput "found the end of the capture group"
                    regex_string += ')'
                    char_reader_index += 1
                    break
                # convert the ~ into * 
                elsif next_char[].match(/~/)
                    regex_string += "*"
                    char_reader_index += 1
                # convert the * into (?:.+)
                elsif next_char[].match(/\*/)
                    regex_string += "(?:.+)"
                    char_reader_index += 1
                # under normal circumstances, regex_string things as-is
                else
                    dput "finding normal stuff in a capture group:"+next_char[]
                    regex_string += next_char[]
                    char_reader_index += 1
                end#if
                
            end#while
            #end of function
                $indent = $indent[4...$indent.length]
                dput "CaptureGroup end"
        end#proc

        startLiteralContext = Proc.new do
            # start of function 
                dput "starting startLiteralContext"
                $indent +=  '    '
            
            
            result = remaining_string[].match(/\A([\s\S]*?)\]/)
            if result
                dput "contents of literal are:#{result[1]}"
                regex_string += Regexp.escape(result[1]) +")"
                char_reader_index += result[0].length
            end
                $indent = $indent[4...$indent.length]
                dput "CaptureGroup end"
        end#proc

        startCharacterClassContext = Proc.new do
            # start of function 
                dput "CharacterClass start"
                $indent +=  '    '
            
            while char_reader_index < rebex_string_length 
                result = next_char[].match(/[\.\/\^\$\?\(\)]/)            
                if result # any of ./^$?
                    result = result[0]
                    dput "found a char that needs to be escaped:"+result[0]
                    # regex_string special
                    regex_string += '\\'+result
                    char_reader_index += 1
                # if \ then startBackslashContext[]
                elsif next_char[].match(/\\/)
                    startBackslashCharacterClassContext[]
                # TODO, probably should add a 'warning for including [ in the group'
                # if ] then stop the context and regex_string the closing )
                elsif next_char[].match(/\]/)
                    dput "found the end of the character class group"
                    regex_string += ']'
                    char_reader_index += 1
                    break
                # under normal circumstances, regex_string things as-is
                else
                    dput "finding normal stuff in a character class group:"+next_char[]
                    regex_string += next_char[]
                    char_reader_index += 1
                end#if
                
            end#while
            #end of function
                $indent = $indent[4...$indent.length]
                dput "CharacterClass end"
        end#proc

        startBackslashCharacterClassContext = Proc.new do
            # start of function 
                dput "CharBackslash start"
                $indent +=  '    '
            # special escapes
            result = remaining_string[].match(/\A\\[swlvxoea]/)
            if result
                result = result[0]
                dput "okay I think there is a special escape:" + result
                char_reader_index += 2
                # FIXME, regex_string special
                case result
                    when '\s' #Space
                        regex_string += ' '
                    when '\w' #Whitespace, ex: \t \n
                        regex_string += '\s'
                    when '\l' # letter 
                        regex_string += '[a-zA-Z]'
                    when '\v' # character in a variable name
                        regex_string += '[a-zA-Z0-9_]'
                    when '\x' # a symbol
                        regex_string += '[^\w\s]'
                    when '\o' # other
                        #FIXME, add this later
                        regex_string += '\o'
                    when '\e' #emoji 
                        #FIXME, add this later
                        regex_string += '\e'
                    when '\a' # any 
                        regex_string += '.'
                    when '\y' # vertical tab 
                        regex_string += '\v'
                end#case
            # regular escapes
            else
                char_reader_index += 1
                dput "okay I think I found a regular escape:" + next_char[]
                regex_string += "\\"+next_char[] # dont change anything
                char_reader_index += 1
                #end this context 
            end
            # end of function 
                $indent = $indent[4...$indent.length]
                dput "okay Backslash"
        end#proc

        # bracket context 
        # declare this again here so that the Bracket context can refer to
        # the Group,Character,and BackslashCharacterClass contexts
        # (somehow this actually works even it it seems like it wouldn't)
        startBracketContext  = Proc.new do
            # start of function 
                dput ($indent + "Bracket start")
                $indent +=  '    '
            
            # Backreference group (not yet finished)
            result = remaining_string[].match(/\A\[G:[a-z0-9_]+?\]/) # find [G:name_of_group]
            if result #1
                result = result[0]
                dput "I think i found a backreference:" + result
                regex_string += "\\k<#{result}>"
                # end this context at end of match 
                char_reader_index += result.length
            else#1


            # Recursive match (not yet finished)
            result = remaining_string[].match(/\A\[R:[a-z0-9_]*?\]/) # find [R:name_of_group] or [R:] (no group)
            if result #2 
                result = result[0]
                dput "I think i found a Recursive match:"+result
                # FIXME, actually add the code for this
                # regex_string(correct_code)
                # end this context at end of match
                char_reader_index += result.length
            else#2
            
            
            # Comment 
            result = remaining_string[].match(/\A\[[^\]]+?((?<!\\)(\\\\)+:|(?<!\\):)\]/) # find [ stuff :]
            if result #3
                result = result[0]
                dput "I think i found a comment match:"+result
                escaped_comment = result.gsub(/((?<!\\)(\\\\)+\)|(?<!\\)\))/,"\\)")
                # regex_string nothing
                char_reader_index += result.length
                regex_string += "(?#"+escaped_comment+")"
            else#3
            
            
            # lookahead/behind/neg lookahead/ neg lookbehind
            result = remaining_string[].match(/\A\[(\<\<|\>\>|x\<|x\>|\<x|\>x):/) # find [<<:
            if result #4
                result = result[0]
                dput "I think i found the start of a look match:"+result
                dput "i found that at:"+ char_reader_index.to_s
                case result
                when "[>>:"
                    regex_string += '(?='
                when "[<<:"
                    regex_string += '(?<='
                when "[x>:","[>x:"
                    regex_string += '(?!'
                when "[x<:","[<x:"
                    regex_string += '(?<!'
                end#case 
                char_reader_index += 4
                startLookContext[]
            else#4
            
            # character class / neg character class
            result = remaining_string[].match(/\A\[(A|xA|Any|xAny):/) # find [A: stuff ] or [xA: stuff ]
            if result #4.1
                dput "i think i found a character class" + result[0]
                if result[1] == "A" or result[1] == "Any"
                    regex_string += "["
                else 
                    regex_string += "[^"
                end
                char_reader_index += result[0].length
                startCharacterClassContext[]
            else#4.1

            # TODO conditional 

            # named capture groups
            result = remaining_string[].match(/\A\[([a-z0-9_]+):/) # find [name: ]
            if result #5
                dput "found a named capture group"
                capture_group_names << result[1] 
                regex_string += "(?<"+result[1]+'>'
                char_reader_index += result[0].length
                startGroupContext[]
            else#5

            # Atomic 
            result = remaining_string[].match(/\A\[(Fixed|Atomic):/) # find [A: stuff ] or [xA: stuff ]
            if result #6
                dput "i think i found an atomic group" + result[0]
                regex_string += "(?>"
                char_reader_index += result[0].length
                startGroupContext[]
            else#6 

            # Literal 
            result = remaining_string[].match(/\A\[(Literal):/) # find [A: stuff ] or [xA: stuff ]
            if result #7
                dput "i think i found an atomic group" + result[0]
                regex_string += "(?:"
                char_reader_index += result[0].length
                startLiteralContext[]
            else#7

            # non-capture groups (assume everything else is a non-capture group)
            # FIXME, put a warning here for Capatalized-would-be named capture groups
            dput "found a non-capture group"
            regex_string += '(?:'
            char_reader_index += 1
            startGroupContext[]
            end#7 Literal
            end#6 atomic 
            end#5 named capture group
            end#4.1 Character Class
            end#4 looks
            end#3 Comment
            end#2 Recursive
            end#1 Backreference
        end#Proc

        #no context
        noContext = Proc.new do
            while char_reader_index < rebex_string_length
                # if  ().^$\ etc 
                if next_char[] =~ regex_extra_escapes_pat or next_char[] =~ /[*+|}\]]/
                    result = Regexp.last_match[0]
                    dput "found a regex_extra_escape"
                    regex_string += '\\'+result
                    char_reader_index += 1
                # if \ 
                elsif next_char[] == "\\"
                    # check if there are at least two characters left
                    if there_are_atleast_2_chars_left
                        next_2_chars = remaining_string[][0..1]
                        # if its any of []{} or \n \t \s \\ then thats fine, put their literal
                        if next_2_chars =~ /\\(\[|\{|\}|\])/ or next_2_chars =~ /\\(n|t|s|\\)/
                            char_reader_index +=2
                            regex_string << Regexp.last_match[0]
                        else
                            # this means there is an unnessary escape
                            # for now make this match the actual \\[WhateverCharacter]
                            # TODO, later maybe make a warning, or have an error with an auto fixer
                            char_reader_index += 2
                            regex_string << '\\\\' << next_2_chars[1]
                        end#if
                    else
                        # it shouldn't be possible to end on a backslash
                        # but if somehow the user does, just go ahead and
                        # output 1 \ 
                        char_reader_index += 1
                        regex_string << '\\\\'
                    end#if
                # if [ then startBracketContext[]
                elsif next_char[] =~ /\[/
                    startBracketContext[]
                # if { then startCurlyBracketContext[]
                elsif next_char[] =~ /\{/
                    dput "I found a {"
                    if remaining_string[] =~ bracket_quanifier_pattern
                        dput "I found a quantifier:#{Regexp.last_match[0]}"
                        if char_reader_index == 0
                            # FIXME, create interactive errors 
                            # ERROR, can't have quantifiers at the begining
                            raise <<-ERRMSG.gsub(/^                            /,'') #unindent
                                
                                
                                
                                In the rebex:
                                    #{rebex_string}
                                    #{(' '*char_reader_index)+"^"}
                                
                                If you just wanted to literally find: #{Regexp.last_match[0]}
                                    then use \\{ 
                                    instead of {

                                Why is there an error? 
                                    because there is a quantifier at the start (the #{Regexp.last_match[0]})
                                    but there are not any characters/patterns before the quantifier
                                    so there is nothing to quantify
                                ERRMSG
                        end#if 
                        # ERROR, cant have quanitifers in the no context
                        # FIXME, create interactive errors 
                        raise <<-ERRMSG.gsub(/^                        /,'') #unindent
                            
                            
                            
                            In the rebex:
                                #{rebex_string}
                                #{(' '*char_reader_index)+"^"}
                            
                            If you just wanted to literally find: #{Regexp.last_match[0]}
                                then use \\{ 
                                instead of {
                            
                            If you wanted to find #{Regexp.last_match[1]} of the previous character/pattern
                                ex: if you wanted to find five x's
                                change: x{5}
                                into: [x{5}]
                            
                            Why is there an error? 
                                because there is a quantifier (the #{Regexp.last_match[0]}) that isn't inside []'s
                        
                        
                        ERRMSG
                    elsif remaining_string[] =~ /\A\{\}/
                        dput "I found #{Regexp.last_match}"
                        raise <<-ERRMSG.gsub(/^                        /,'') #unindent
                            
                            
                            
                            In the rebex:
                                #{rebex_string}
                                #{(' '*char_reader_index)+"^"}
                            
                            If you wanted to find {}
                                then use \\{ 
                                instead of {
                        
                        
                        ERRMSG
                    else # should be an anchor/boundary otherwise
                        startCurlyBracketContext[]
                    end#if
                # under normal circumstances, regex_string things as-is
                else
                    dput "I think this is a normal char:" + next_char[]
                    # TODO, if this is a ] } or \ the user is probably messing something up 
                    regex_string += next_char[]
                    char_reader_index += 1
                end#if 
            end#while
            regex_string += "(?#Rebex)"
            dput 'regex was:'+regex_string
            return Regexp.new(regex_string)
        end#proc
        # call no context to get everything started
        noContext[]
end#def:rebexToRegex



# add a replace method 
class String
    def replaceAll(regex,with:nil)
        # get rid of regex escapes
            # \1 groups
            # the \k<> groups 
            # \' 
            # \&
        with.gsub!(/(\\\\)*\\(k|'|&|[0-9])/,"\\1\\\\\\\\\\2")
        # add rebex escapes
        with.gsub!(/(?:(?:\\\\)+|(?<!\\))\[G:([a-z0-9_]+?)\]/,"\\\\k<\\1>")
        self.gsub(regex,with)
    end
    def replaceAll!(regex,with:nil)
        # get rid of regex escapes
            # \1 groups
            # the \k<> groups 
            # \' 
            # \&
        with.gsub!(/(\\\\)*\\(k|'|&|[0-9])/,"\\1\\\\\\\\\\2")
        # add rebex escapes
        with.gsub!(/(?:(?:\\\\)+|(?<!\\))\[G:([a-z0-9_]+?)\]/,"\\\\k<\\1>")
        self.gsub!(regex,with)
    end
    def extractFirst!(regex)
        output = self.match(regex)
        self.sub!(regex,"")
        return output
    end
    def findFirst(regex)
        self.match(regex)
    end
    def findAll(regex)
        matches = []
        self.scan(regex){ matches << $~ }
        return matches
    end
end



class Regexp
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


if ARGV.length == 1
    puts rebexToRegex(ARGV[0])
end