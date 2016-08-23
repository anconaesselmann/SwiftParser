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
- Or operator: |

# Why you might want to use my regular expression engine:

Regular expressions like this `(a+a+)+b` will result in exponential time complexity due to backtracking when it doesn't find a matching (in this case called catastrophic backtracking). A regular expression engine built with automaton theory on the other hand has superlinear time complexity.

Try the above regular expression on a string of a few 'a' characters to test if your regular expression engine is prone to catastrophic backtracking:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

Be prepared to terminate the process.

Try the above regular expression on the same string with a regular expression engine that uses automaton theory and it will report non-match in seconds.


# Other regular expression engines built with automaton theory:
- [Re2](https://github.com/google/re2) (C++ with wrappers for Python and others. Built by google)