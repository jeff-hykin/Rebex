# Rebex
A more user friendly version of regular expressions, implemented in Ruby.
(This is a feature inside of the Resh repo, but it had enough merit also have its own repo.)

# Current State
Ready for everyday use, but it is possible there are a select few edge cases that have been missed.<br>
I need to clean up the code and more imformative error messages before getting to the 1.0 version.<br>


# How to use
1. Put the rebex.rb file in the same folder as your ruby script.
2. Include `require File.dirname(__FILE__)+'/rebex.rb'` at the top of your script.
3. Wherever you would normally write a regular expression, just include a - right before the //
For example:
```
require File.dirname(__FILE__)+'/rebex.rb'
a_string = "hello good sir, today is Dec 12, 1972 and it is 8:00 am"
puts a_string.match(-/[\T]/) # will find the time: 8:00 am
```
Some additional functions have also been added to the string class
(See the demo file for more examples)
```
puts "The times also are:"
# the following finds both 23:00 and 8:00am
for each_match in "hello it is 23:00, 8:00am".findeach(-/\T/)
    puts "    the hour is:" + each_match["Hour"]
    puts "    the minute is:" + each_match["Minute"]
    puts ""
end
```


# Syntax
The only special characters are:<br>
```
    \
    []
    {}
    *
    ~
    +
    :
    |
```
This means in your string you can use periods, dollar signs, parentheses, etc and they'll actually match/find those characters.
But to match `i have escaped characters \ [] {}`
The rebex would have to be `"i have escaped characters \\ \[\] \{\}"`


## Characters
Rebex has a lot of escapes for matching special characters:
```
    \s # a space character
    \w # a whitespace character, ex: tab, "\t" or newline, "\n"
    \l # letter ex: "A" or "a" or "b"
    \v # character in a variable name (letters, underscores, numbers) 
    \x # a symbol (ex: #$&%*) 
    \a # any character thats not a newline
    \A # absolutely any character 
    \y # vertical tab 
```

## Special escapes
Where Rebex stands out is the escapes for matching things longer than a character:
```
    *    Wildcard, everything accept newlines
    \#   Number              ex: "3.1415" or "10000" or ".05"
    \T   Time                ex: "10:20pm" or "22:17" or "12:10.59" or "10:11:80 Am" (and more)
    \D   Date                ex: "12/31/2017" or "12.31.2017" or "Aug 13, 2017" or "MAY-1-99" (and more)
    \W   Word                ex: "Bob" or "hello" or "PlzDontTypeLikDis"
    \V   a variable name     ex: "a_var" or "A_var1" but wont match: "1var"
    \L   everything to the left  (example below)
    \R   everything to the right (example below)
    And more to come!
        \f filenames
        \F folder names
        \P path/directories
        etc

    # explaination for \L and \R
    if you have a string with mutiple lines like:
    """    
        im_a_file_name.txt
        im_a_ruby_script.rb
        i_have_.rb_in_my_name
    """
    
    searching that string with the rebex-pattern "[\L.rb]" will return 2 matches: 
        "im_a_ruby_script.rb" and "i_have_.rb"
    \L simply matches from *start_of_the_line* to *as_many_non-newline_characters_as_possible*
    \R works the similarly but at the end rather than the start
    searching that string with the rebex-pattern "[.rb\R]" would return 2 matches:
        ".rb_in_my_name" and ".rb" (the ".rb" is from "im_a_ruby_script.rb")
```

## Repetition
Rebex uses + ~ and {} for repetition just like normal regular expressions
```
hello world
my name is jeff
my friends call me jeffffff
i know someone named jennifer
```
On the above string,
The rebex `[jef+]` would match "jeff" and "jeffffff"<br>
The rebex `[jef~]` would match "jeff", "jeffffff" but also "je" from "jennifer"<br>
The rebex `[jef{3}]` would match "jefff" (three f's)<br>
The rebex `[jef{0,3}]` would match "jeff" (2 f's work), "jefff" (3 f's) but also "je" from "jennifer" (0 f's)<br>
The rebex `[je[\l+]]` (`\l` means any letter) would match "jeff", "jeffffff", and "jennifer"<br>
The rebex `[je[\l+]f]` would match "jeff", "jeffffff" and "jennif" (because all are: je \[some letters] f)<br>
The rebex `[je[\l+{Min}]f]` would match "jeff", "jeff" (from "jeffffff") and "jennif" <br>
(this because its: je \[as few letters as possible] f)<br>
`{Min}` is just the minimum number that will still match. This is also known as being non-greedy.
`{0,}` is the same as * <br>
`{1,}` is the same as + <br>

## Anchors/Boundaries
```
    {S}  # matches the start of the whole string 
    {E}  # matches end of the whole string
    {LS} # matches the start of a line
    {LE} # matches the end of line
    {b}  # matches a boundary 
           (either [whitespace][HERE][non_whitespace] or [non_whitespace][HERE][whitespace])
    {c}  # matches a contiuation 
           (either [whitespace][HERE][more_whitespace] or [non_whitespace][HERE][more_non_whitespace])
    more to come!
        {l} letter boundaries
        {#} number boundaries
        {Case} case (upper vs lower case) boundaries
        etc
```

## Groups and Group Tools
```
    for the string:
        hello world
        123 123 123 321
        my name is jeff
        my friends call me jeffffff
        i know someone named jennifer

    [123]                   # matches "123", "123", and "123" but not "321"
    [[123 ]+]               # matches "123 123 123 " (all together)
    123[this is a comment:] # matches the "123", "123", and "123" and ignores the comment 
    my [name|friends]       # matches both "my name" and "my friends"
    [<<:my name is ]jeff    # only matches "jeff" when "my name is " comes before it (called a lookbehind)
    jeff[x>:f]              # only matches "jeff" when there isn't an f after it (called a negative lookahead)
    [Any:0-9]+              # matches "321", and "123"
    [xAny:0-9]+             # matches every thing thats not 0-9, "hello world\n" and "my name... etc
    [A:0-9]+                # same as [Any:0-9]+
    [xA:0-9]+               # same as [xAny:0-9]+
    my name is [a_name:\W]  # matches "my name is jeff" and puts "jeff" in a group called "a_name" 
                            # for small things, named groups dont do much, but for long rebex patterns
                            # groups like "hour" "minute" "second" allow you to pull out specific peices
                            # and that can be really helpful
    there are also 
        [Literal:]
        [Fixed:]
        and other groups with even more on the way:
            conditional groups
            recursive groups
            etc
```


