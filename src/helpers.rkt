#lang racket

(require (prefix-in c: "core.rkt"))

(provide pull
         take
         take-all
         reify)

(define (pull $) 
  (if (procedure? $) (pull ($)) $))

(define (take-all $)
  (let [($ (pull $))]
    (if (null? $) 
      '()
      (cons (car $) (take-all (cdr $)))))) 

(define (take n $)
  (if (zero? n) '()
    (let [($ (pull $))]
      (cond
        [(null? $) '()]
        [else (cons (car $) (take (- n 1) (cdr $)))]))))

(define (reify s/c*)
  (map reify-state/1st-var s/c*))

(define (reify-state/1st-var s/c)
  (let [(v (walk* (c:var 0) (car s/c)))]
    (walk* v (reify-s v '()))))

(define (reify-s v s)
  (let [(v (c:walk v s))]
    (cond
      [(c:var? v)
       (let [(n (reify-name (length s)))]
         (cons `(,v . ,n) s))]
      [(pair? v) (reify-s (cdr v) (reify-s (car v) s))]
      [else s])))

(define (reify-name n)
  (string->symbol
    (string-append "_" "." (number->string n))))

(define (walk* v s)
  (let [(v (c:walk v s))]
    (cond
      [(c:var? v) v]
      [(pair? v) (cons (walk* (car v) s)
                       (walk* (cdr v) s))]
      [else v])))

