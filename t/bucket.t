(use gauche.test)
(test-start "s3.bucket module")

(use srfi-1)
(use math.mt-random)

(use s3)
(use s3.bucket)
(use s3.account)

(test-module 's3.bucket)

(load "t/util")

(define name (make-random-string 10))

(s3:put-bucket account name)
(test* "PUT OK" name
       (car (member name (s3:get-bucket-names account))))

(s3:delete-bucket account name)
(test* "DELETE OK" #f
       (member name (s3:get-bucket-names account)))

(test-end)
