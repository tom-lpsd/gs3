(define account (make-account-from-file "s3.conf"))

(define (make-random-string n)
  (let ((alphas (list->vector
                 (map integer->char
                      (append (iota 26 (char->integer #\a))
                              (iota 10 (char->integer #\0))))))
        (m (make <mersenne-twister> :seed (sys-time))))
    (list->string
     (let loop ((count 0)
                (chars '())
                (index (mt-random-integer m 36)))
       (if (= count n)
           chars
           (loop (+ count 1)
                 (cons (vector-ref alphas index) chars)
                 (mt-random-integer m 36)))))))
