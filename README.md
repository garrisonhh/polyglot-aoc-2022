# polyglot aoc 2022

## self-imposed rules
- new language every day
- language choices are immutable -- no deleting old solutions to implement it in
  a harder language, so an easier language can be used for a harder problem
    - *I am going to regret this*
- language "dialects" must be written in the idiomatic versions of each dialect
    - no typescript that is just javascript, or cpp written in the common subset
      of cpp and c

## common project format
- solutions should provide a shell script or clear instructions to run the
  program
- executable/script should accept datafile(s) in argv
- output should be printed to stdout

## stuff I've learned so far

- I really dislike julia. Feels like an outdated, clunky compiled language while
  having all of the worst parts of dynamic scripting languages.
- strictly typed functional languages have had the lowest code footprint and
  feel the most easy to learn. I think this has to do with code composability,
  static typing, and compilers that are well enabled to help you.
- the biggest thing I gain from familiarity with a language is not speed of
  writing code (even though this is an obvious benefit), it's the speed of
  visualizing the eventual design. the less familiar I am with the language, the
  harder it is for me to understand what an idiomatic solution looks like, and
  the more time I spend refactoring when I figure out how to do things better.