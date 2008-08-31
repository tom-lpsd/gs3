(use gauche.test)
(test-start "s3.bucket module")

(use srfi-1)
(use math.mt-random)

(use s3)
(use s3.bucket)
(use s3.account)

(test-module 's3.bucket)

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

(define name (make-random-string 10))

(s3:put-bucket account name)
(test* "PUT OK" name
       (car (member name (s3:get-bucket-names account))))

(s3:delete-bucket account name)
(test* "DELETE OK" #f
       (member name (s3:get-bucket-names account)))

(test-end)
