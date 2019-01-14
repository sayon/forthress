 (progn
  (define # progn)
  (define nil (quote ())) 
  (define println (lambda (n) (progn (print n) (print "\n") )))

  (define fact (lambda (n) (if (< n 1) 1 (* n (fact (- n 1))))))

  (fact 4)

  )


