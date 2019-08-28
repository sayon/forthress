 (progn
   (define not (lambda (b) (if b #f #t)))

   (define println (lambda (n) (progn (print n) (print "\n") )))
   (define # progn)

   (define snd (lambda (s) (car (cdr s))))
   (define fst car)
    
   (define cond (lambda (s) 
                   (if (cons? s) 
                     (if (eval (fst (fst s)))
                       (eval (snd (fst s)))
                       (cond (cdr s))
                       )
                     (progn))
                   ))
   (define else #t) 
   (cond (quote (
                 ((< 1 0) (print "0<1"))
                 ((< 2 2) (print "2<3"))
                 ((< 5 5) (print "5<3"))
                 ( #t (print "else!")) 
                 )))

   
   )

(if (fst (fst s)) (snd (fst s)) (cond (cdr s)))

(cond (quote ((1 < 2) (print "1<2"))))
(define fact (lambda (n) (if (< n 1) 1 (* n (fact (- n 1))))))

