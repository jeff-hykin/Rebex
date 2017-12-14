# Rebex
A more user friendly version of regular expressions, implemented in Ruby.
(This is a feature inside of the Resh repo, but it had enough merit also have its own repo.)

# Current State
The expressions themselves and the stability is at version 0.9.
But integration and code structure are still at the 0.2 level (should change soon).
The 1.0 vserion should be a refined Ruby function converting rebex into Regex.
I need to clean up the code and add good error messages before getting to the 1.0 version.
The 2.0 version should be a string find/replace/parse toolkit for Ruby.


# How to use
If you include this code at the top of a ruby script<br>
(Better integration coming soon)<br>
Then you cause use the rebexToRegex function to generate Ruby regular expressions.
For example:
```
# include rebex.rb code here
a_string = "hello good sir, today is Dec 12, 1972 and it is 8:00 am"
result = a_string.match(rebexToRegex('hello \a+ today is \D [and it is |]\T'))
puts result
puts result['Time']
puts result['Date']
```

# Syntax
The only special characters are:<br>
```
    \
    []
    {}
    *
    +
    :
    |
```
This means in your string you can use periods, dollar signs, parentheses, etc and they'll actually match/find those characters.
To match `i have escaped characters \ [] {}`
The rebex would have to be `"i have escaped characters \\ \[\] \{\}"`


## Characters
Rebex has a lot of escapes for matching special characters:
```
    \s # a space character
    \w # a whitespace character, ex: "\t" or "\n"
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
    \# # Number              ex: "3.1415" or "10000" or ".05"
    \T # Time                ex: "10:20pm" or "22:17" or "12:10.59" or "10:11:80 Am" (and more)
    \D # Date                ex: "12/31/2017" or "12.31.2017" or "Aug 13, 2017" or "MAY-1-99" (and more)
    \W # Word                ex: "Bob" or "hello" or "PlzDontTypeLikDis"
    \V # a variable name     ex: "a_var" or "A_var1" but wont match: "1var"
    \L # everything at the begining of a line (see explaination below)
    \R # everything left on a lines (see explaination below)
    And more to come!
        \f filenames
        \F folder names
        \P path/directories
        etc

    # explaination for \L and \R
    if you have a string with mutiple lines like:
        im_a_file_name.txt
        im_a_ruby_script.rb
        i_have_.rb_in_my_name
    the rebex "\L.rb" will match "im_a_ruby_script.rb" and "i_have_.rb"
    it simply matches from [start of the line] to [as many non-newline characters as possible]
    \R works the similarly but for the end
    the rebex ".rb\R" would only match ".rb" (from "im_a_ruby_script.rb") and ".rb_in_my_name"
```

## Repetition
Rebex uses + * and {} for repetition just like normal regular expressions
```
hello world
my name is jeff
my friends call me jeffffff
i know someone named jennifer
```
On the above string,
The rebex `"jef+"` would match "jeff" and "jeffffff"<br>
The rebex `"jef*"` would match "jeff", "jeffffff" but also "je" from "jennifer"<br>
The rebex `"jef{3}"` would match "jefff" (three f's)<br>
The rebex `"jef{0,3}"` would match "jeff" (2 f's work), "jefff" (3 f's) but also "je" from "jennifer" (0 f's)<br>
The rebex `"je\[\l+]"` (`\l` means any letter) would match "jeff", "jeffffff", and "jennifer"<br>
The rebex `"je\[\l+]f"` would match "jeff", "jeffffff" and "jennif" (because all are: je \[some letters] f)<br>
The rebex `"je\[\l+{Min}]f"` would match "jeff", "jeff" (from "jeffffff") and "jennif" 
(this because its: je \[as few letters as possible] f)<br>
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
    [123 ]+                 # matches "123 123 123 " (all together)
    123[this is a comment:] # matches the "123", "123", and "123" and ignores the comment 
    my [name|friends]       # matches both "my name" and "my friends"
    [<<:my name is ]jeff    # only matches "jeff" when "my name is " comes before it (called a lookbehind)
    jeff[x>:f]              # only matches "jeff" when there isn't an f after it (called a negative lookahead)
    [Any:0-9]+              # matches "123", "123", and "123"
    [xAny:0-9]+             # matches every thing thats not 0-9, "hello world\n" and "my name... etc
    [A:0-9]+                # same as [Any:] just less characters
    [xA:0-9]+               # same as [xAny:] just less characters
    my name is [a_name:\W]  # matches "my name is jeff" and puts "jeff" in a group called "a_name" 
                            # for small things, named groups dont do much, but for long rebex patterns
                            # groups like "hour" "minute" "second" allow you to pull out specific peices
                            # and that can be really helpful
    more groups on the way!
        conditional groups
        atomic groups
        recursive groups
        etc
```


