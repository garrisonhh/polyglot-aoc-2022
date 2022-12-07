(ns soln.core
  (:gen-class)
  (:require [clojure.string :as str]))

(defn eprintln
  [fmt & args]
  (binding [*out* *err*]
    (apply println fmt args)))

(defn identify-marker
  ([ndistinct trans] (identify-marker ndistinct trans 0 ""))
  ([ndistinct trans chars window]
   (if (and (= ndistinct (count window)) (= ndistinct (count (set window))))
     ; window is 'distinct' long and unique
     chars
     ; look at next window
     (let [trans' (subs trans 1)
           chars' (inc chars)
           window' (str
                    (if (= (count window) ndistinct) (subs window 1) window)
                    (get trans 0))]
       (recur ndistinct trans' chars' window')))))

(defn part1
  [line]
  (let [marker-pos (identify-marker 4 line)]
    (printf "part 1) marker position is %d\n" marker-pos)))

(defn part2
  [line]
  (let [marker-pos (identify-marker 14 line)]
    (printf "part 2) marker position is %d\n" marker-pos)))

(defn -main
  [& args]

  ; check args arity
  (when (not= (count args) 1)
    (eprintln "error: wrong number of args")
    (System/exit 1))

  ; solve for each line of input
  (let [[filename] args
        lines (str/split (slurp filename) #"\n")]
    (doseq [line lines]
      (part1 line)
      (part2 line))))
