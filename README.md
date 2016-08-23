# What is currently supported:
- Repetition with *,+,?, {} and {,}
- Atomic Grouping with ()
- Character groups \l, \u, \w, \s, \d
- match anything with .
- escape special characters with \
- setting of custom escape characters
- custom character groups with []

# What will be supported once (if) I have time:
- Negating character sets with ^
- Named Capture Groups
- Noncapturing groups
- Or operator: |

# Why you might want to use my regular expression engine:

Regular expressions like this `(a+a+)+b` will result in exponential time complexity due to backtracking when it doesn't find a match (in this case called catastrophic backtracking). A regular expression engine built with automaton theory on the other hand has superlinear time complexity.

Try the above regular expression on a string of a few 'a' characters to test if your regular expression engine is prone to catastrophic backtracking:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Be prepared to terminate the process.

Try the above regular expression on the same string with a regular expression engine that uses automaton theory and it will report non-match in seconds.

Why might you care? Especially since this is a contrived example? Well, [ReDoS](https://www.owasp.org/index.php/Regular_expression_Denial_of_Service_-_ReDoS) is a denial of service attack using regular expressions that will result in catastrophic backtracking. If there is any way that a user might be able to execute a custom regular expression on your server, you have to worry about this. But even without malicious intent, sometimes innocent looking regular expressions can result in catastrophic backtracking

# Disclaimer
Please be advised, I have done only a limited amount of testing on this project (see test files). There are probably bugs. I created this as an exercise to better understand how nondeterministic automatons work and I have not used it in production code. If you find any bug, please let me know!

# Other regular expression engines built with automaton theory:
- [Re2](https://github.com/google/re2) (C++ with wrappers for Python and others. Built by google)