(use gauche.test)
(test-start "s3 object")

(use s3.account)
(use s3.bucket)
(use s3.object)

(load "t/util")

(test-module 's3.object)

(define bucket-name "tom-lpsd")
(define object-name (make-random-string 10))
(define object-body (make-random-string 100))

(test* "s3:put-object" #t
       (list? (s3:put-object account bucket-name object-name object-body)))

(test* "check object has uploaded" object-name
       (car (member object-name (s3:get-object-names account bucket-name))))

(test* "s3:get-object" object-body
       (s3:get-object account bucket-name object-name))

(test* "s3:delete-object" #t
       (list? (s3:delete-object account bucket-name object-name)))

(test* "check object has deleted" #f
       (member object-name (s3:get-object-names account bucket-name)))

(test-end)
