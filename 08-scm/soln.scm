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

  (define (vec2-index p width)
    (+ (* (vec2-y p) width) (vec2-x p)))

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
    (vector-ref v (vec2-index pos width)))

  (define (vector-vec2-set! v width pos obj)
    (vector-set! v (vec2-index pos width) obj))

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

  ; given a ray, generates list of positions within grid
  (define (gen-ray-vector size pos dir)
    (letrec ([grv-aux (lambda [ls pos]
                              (if (not (inbounds size pos))
                                  ls
                                  (grv-aux (cons pos ls) (vec2-add pos dir))))])
      (list->vector (reverse (grv-aux '() pos)))))

  ; returns a `(vec2 * bool) vector`
  (define (visible-in-dir grid pos dir)
    (let* ([size (grid-size grid)]
           [positions (gen-ray-vector size pos dir)]
           [visible (list->vector
                      (reverse (car (fold-left
                        (lambda [ctx pos]
                          (let* ([visible (car ctx)]
                                 [height (cdr ctx)]
                                 [tree (grid-ref grid pos)])
                            (if (> tree height)
                                (cons (cons #t visible) tree)
                                (cons (cons #f visible) height))))
                        (cons '() -1)
                        (vector->list positions)))))])
      (let ([visibilities (vector-map list positions visible)])
        ; (display "visibilities for ")
        ; (vec2-display pos)
        ; (display " ")
        ; (vec2-display dir)
        ; (display ": ")
        ; (vector-for-each
          ; (lambda [p]
            ; (vec2-display (car p))
            ; (display-all " " (cadr p) ", "))
          ; visibilities)
        ; (newline)

        visibilities)))

  ; returns a `bool vector` the same size as the grid
  (define (visible-in-grid grid)
    (let ([size (grid-size grid)])
      (define side-rays
        (let ([origin (make-vec2 0 0)]
              [diag (make-vec2 (- (vec2-x size) 1) (- (vec2-y size) 1))])
          (list (cons origin (make-vec2 1 0))
                (cons origin (make-vec2 0 1))
                (cons diag (make-vec2 0 -1))
                (cons diag (make-vec2 -1 0)))))

      (let* ([rays (apply vector-concat
                     (map
                       (lambda [ray]
                         (let* ([pos (car ray)] [dir (cdr ray)]
                                [cast-dir (make-vec2 (vec2-y dir)
                                                     (vec2-x dir))])
                           (vector-map
                             (lambda [p] (cons p cast-dir))
                             (gen-ray-vector size pos dir))))
                       side-rays))]
             [vis-casts (apply vector-concat
                          (vector->list
                            (vector-map
                              (lambda [r]
                                      (visible-in-dir grid (car r) (cdr r)))
                              rays)))]
             [visibilities (make-vector (vector-length vis-casts) #f)]
             [width (vec2-x size)])
        (vector-for-each
          (lambda [e]
            (let ([pos (car e)] [is-vis (cadr e)])
              (vector-vec2-set! visibilities width pos
                (or (vector-vec2-ref visibilities width pos) is-vis))))
          vis-casts)
        visibilities)))

  (define (part1 grid)
    (let* ([visible (visible-in-grid grid)]
           [total-vis (fold-left
                        (lambda [total e] (+ total (if e 1 0)))
                        0
                        (vector->list visible))])
      (display-all "total visible trees: " total-vis "\n")))

  (define (part2 grid)
    0)

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
                   (vector->list line-digits))]
           [grid-len (vector-length grid)]
           [size (make-vec2 (string-length (vector-ref lines 0))
                            (vector-length lines))])
      (make-grid grid size)))

  (define (solve filename)
    (let ([tree-grid (parse-input (slurp filename))])
      (show-grid tree-grid)
      (part1 tree-grid)
      (part2 tree-grid))))