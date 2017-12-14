# Rebex
A more user friendly version of regular expressions, implemented in Ruby.

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
```
This means in your string you can use periods, dollar signs, parentheses, etc and they'll actually match/find those characters.

Rebex has a lot of escapes for matching special characters:
```
    \s # a space chatacter
    \w # a whitespace character, ex: "\t" or "\n"
    \l # letter ex: "A" or "a" or "b"
    \v # character in a variable name (letters, underscores, numbers) 
    \x # a symbol (ex: #$&%*) 
    \a # any character thats not a newline
    \A # absolutely any and every character 
    \y # vertical tab 
```

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

    # explaination for \L and \R
    if you have a string with mutiple lines like:
        im_a_file_name.txt
        im_a_ruby_script.rb
        i_have_.rb_in_my_name
    the rebex "\L.rb" will match "im_a_ruby_script.rb" and "i_have_.rb"
    it simply matches from the [start of the line] to [as many non-newlinw characters as it can]
    \R works the similarly but for the end
    the rebex ".rb\R" would only match ".rb" (from "im_a_ruby_script.rb") and ".rb_in_my_name"
```

Rebex uses + * and {} for repetition just like normal regular expressions
```
hello world
my is jeffffff
i know someone named jennifer
```
On the above string,
The rebex "jef+" would match "jeffffff"<br>
The rebex "jef*" would match "jeffffff" but it would also match the "je" from "jennifer"<br>
The rebex "jef{5}" would match "jefffff" (misses the last f)<br>
The rebex "jef{0,2}" would match "jeff" (only 2 f's) but would also match "je" from "jennifer"<br>
The rebex "je\[\l+]" (\l means any letter) would match "jeffffff" and "jennifer"<br>
The rebex "je\[\l+]f" would match "jeffffff" and "jennif" (because both are: je \[some letters] f)<br>
The rebex "je\[\l+{Min}]f" would match "jeff" and "jennif" (because its: je \[as few letters as possible] f)<br>



# Notes
This is a feature inside of the Resh repo, but it had enough merit also have its own repo.
