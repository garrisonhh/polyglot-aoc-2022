#!/usr/bin/env -S scheme --program
(import (rnrs) (soln))

(let ([args (cdr (command-line))])
  ; check args
  (when (not (= 1 (length args)))
        (display "usage: soln.scm $input_file$\n")
        (exit 1))

  ; run solution
  (solve (car args)))