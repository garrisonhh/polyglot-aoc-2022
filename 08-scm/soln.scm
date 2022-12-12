(library (soln)
  (export solve)
  (import (rnrs))

  ; helpers ====================================================================

  (define (display-all . args)
    (for-each display args))

  (define (range start stop)
    (letrec ([range-aux (lambda [ls start stop]
                                (if (= start stop)
                                    ls
                                    (let* ([stopp (- stop 1)]
                                           [lsp (cons stopp ls)])
                                      (range-aux lsp start stopp))))])
      (range-aux '() start stop)))

  (define (vector-concat . args)
    (list->vector (apply append (map vector->list args))))

  (define (vector-filter f v)
    (list->vector (filter f (vector->list v))))

  ; types ======================================================================

  (define-record-type vec2 (fields x y))

  (define (vec2->list v)
    (list (vec2-x v) (vec2-y v)))

  (define (list->vec2 ls)
    (apply make-vec2 ls))

  (define (vec2-map f . vec2s)
    (list->vec2 (apply map (cons f (map vec2->list vec2s)))))

  (define (vec2-index width pos)
    (+ (* (vec2-y pos) width) (vec2-x pos)))

  (define (vec2-add v1 v2)
    (vec2-map + v1 v2))

  (define (vec2-display v)
    (display-all "(" (vec2-x v) ", " (vec2-y v) ")"))

  (define (vec2-vector-display msg v)
    (display msg)
    (display ": [")
    (vector-for-each
      (lambda [p] (vec2-display p) (display ", "))
      v)
    (display "]\n"))

  (define (vector-vec2-ref v width pos)
    (vector-ref v (vec2-index width pos)))

  (define (vector-vec2-set! v width pos obj)
    (vector-set! v (vec2-index width pos) obj))

  (define-record-type grid
    (fields
      grid ; int vector
      size ; vec2
    ))

  (define (grid-ref grid pos)
    (vector-vec2-ref (grid-grid grid) (vec2-x (grid-size grid)) pos))

  (define (show-grid grid)
    (let ([size (grid-size grid)])
      (display-all "grid " (vec2-x size) "x" (vec2-y size) ":")
      (let ([width (vec2-x size)]
            [total-len (* (vec2-x size) (vec2-y size))])
        (vector-for-each
          (lambda [i e]
                  (when (= 0 (mod i width)) (newline))
                  (display (integer->char (+ e (char->integer #\0)))))
          (list->vector (range 0 total-len))
          (grid-grid grid))))
    (newline))

  ; solution ===================================================================

  ; whether a vec2 is inside of a rect of this size
  (define (inbounds size pos)
    (let ([x (vec2-x pos)] [y (vec2-y pos)])
      (and
        (>= x 0)
        (>= y 0)
        (< x (vec2-x size))
        (< y (vec2-y size)))))

  ; returns a `(visible: bool) * (score: int)`
  (define (view-cast grid pos dir)
    (let ([tree (grid-ref grid pos)])
      (letrec ([aux (lambda [cur n]
                            ; (display-all "aux: " tree " " cur " " n "\n")
                            (let ([size (grid-size grid)]
                                  [next (vec2-add cur dir)]
                                  [np (+ n 1)])
                              (if (inbounds size next)
                                  (if (> tree (grid-ref grid next))
                                      (aux next np)
                                      (cons #f np))
                                  (cons #t n))))])
        (aux pos 0))))

  ; returns a `((visible: bool) * (score: int)) vector` the same size as grid
  (define (cast-all grid)
    (define dirs
      (map
        (lambda [e] (apply make-vec2 e))
        '((1 0) (0 1) (-1 0) (0 -1))))

    (let* ([size (grid-size grid)] [width (vec2-x size)])
      (list->vector
        (map
          (lambda [idx]
            (let* ([pos (make-vec2 (div idx width) (mod idx width))]
                   [dir-scores (map
                                 (lambda [dir] (view-cast grid pos dir))
                                 dirs)]
                   [combined (fold-left
                               (lambda [ctx pair]
                                       (cons (or (car pair) (car ctx))
                                             (* (cdr pair) (cdr ctx))))
                               (cons #f 1)
                               dir-scores)])
              combined))
          (range 0 (* (vec2-x size) (vec2-y size)))))))

  ; returns a `bool vector` the same size as the grid
  (define (visibility-grid grid)
    (vector-map car (cast-all grid)))

  ; returns an `int vector` the same size as the grid
  (define (score-grid grid)
    (vector-map cdr (cast-all grid)))

  (define (part1 grid)
    (let* ([visible (visibility-grid grid)]
           [total (fold-left
                    (lambda [s e] (+ s (if e 1 0)))
                    0
                    (vector->list visible))])
      (display-all "part 1) total trees visible: " total "\n")))

  (define (part2 grid)
    (let* ([scores (score-grid grid)]
           [best (fold-left max 0 (vector->list scores))])
      (display-all "part 2) best score: " best "\n")))

  ; input stuff ================================================================

  ; same as clojure
  (define (slurp filepath)
    (get-string-all (open-input-file filepath)))

  ; split a string on a character
  (define (string-split c str)
    (letrec
      ([split-aux (lambda [subs prev s]
                          (let ([len (string-length s)])
                            (if (zero? len)
                                ; string is finished
                                (list->vector (cons prev subs))
                                ; continue walking down string
                                (let* ([nc (string-ref s 0)]
                                       [prevp (string-append prev (string nc))]
                                       [sp (substring s 1 len)])
                                  ; if next char is c, add prevp to list
                                  (if (char=? c nc)
                                     (split-aux (cons prev subs) "" sp)
                                     (split-aux subs prevp sp))))))])
      (split-aux '() "" str)))

  (define (digit->integer ch)
    (assert (char-numeric? ch))
    (- (char->integer ch) (char->integer #\0)))

  (define (string->vector s) (list->vector (string->list s)))

  ; returns a grid
  (define (parse-input str)
    (let* ([lines (vector-filter
                    (lambda [s] (> (string-length s) 0))
                    (string-split (integer->char 10) str))]
           [parse-line (lambda [line]
                               (vector-map digit->integer
                                 (string->vector line)))]
           [line-digits (vector-map parse-line lines)]
           [grid (fold-left vector-concat (make-vector 0)
                   (reverse (vector->list line-digits)))]
           [grid-len (vector-length grid)]
           [size (make-vec2 (string-length (vector-ref lines 0))
                            (vector-length lines))])
      (make-grid grid size)))

  (define (solve filename)
    (let ([tree-grid (parse-input (slurp filename))])
      (show-grid tree-grid)
      (part1 tree-grid)
      (part2 tree-grid))))