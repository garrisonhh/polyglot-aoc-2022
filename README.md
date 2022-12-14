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

- strictly typed functional languages have had the lowest code footprint and
  feel the most easy to learn. I think this has to do with code composability,
  static typing, and compilers that are well enabled to help you.
- the biggest thing I gain from familiarity with a language is not speed of
  writing code (even though this is an obvious benefit), it's the speed of
  visualizing the eventual design. the less familiar I am with the language, the
  harder it is for me to understand what an idiomatic solution looks like, and
  the more time I spend refactoring when I figure out how to do things better.

### thoughts on specific languages

1) **Python** - Familiar and comfortable.
2) **C** - Familiar and comfortable.
3) **x86_64** - I find assembly as easy as C to architect, because I'm writing
   practically the same code that I would in C. The main differences are
   speed of development, both from difficulty of writing basic constructs like
   functions and expressions, a new class of bugs involving breaking my own
   conventions and assumptions, and the added mental overhead of register/stack
   allocations
4) **OCaml** - My favorite language to tinker with at the moment. The strictness
   of the type system and helpfulness of the compiler errors, combined with the
   flexibility and composibility of the language meant that once I got a
   function compiling it basically just worked. Crazy good workflow.
5) **Javascript** - Functional JS is honestly really nice to work with. The
   contrast with OCaml really put into perspective how much you sacrifice with
   dynamic languages in terms of the helpfulness of the compiler. Debugging is
   a much more painful process, I spent most of the time just reading MDN.
6) **Clojure** - A nice medium of dynamic-ness, typing, and workflow. This was
   an easy problem, but the speed of development was still nuts. For JS, OCaml,
   C, etc. it took some time to figure out how to do basic tasks like read a
   file to a string, but Clojure just gives you `slurp`. It feels like it's
   actually written by programmers.
7) **Julia** - I really dislike julia. Feels like an outdated, clunky compiled
   language while having all of the worst parts of dynamic scripting languages.
8) **Scheme** - Writing scheme felt very alien at first. Prefix notation means
   you can't grep through IDE suggestions easily, so there was a frontloaded
   learning curve. However, once I learned how to think in Scheme better, and
   wrote my final solution, it was incredibly elegant. It's interesting to me
   how once I got over the hump of learning the environment, it just felt like
   the parts of Python I really like.
9) **Rust** - Have heard people talk about similarities between Rust and OCaml
   before, and the experience is honestly very similar in terms of the fantastic
   tooling. With Rust there is a lot more of a feeling of fighting the compiler
   rather than working with it, but the feeling of getting something compiling
   and usually having it work immediately is pretty incredible
10) **Lua** - cute lil scripting language.