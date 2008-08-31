(use gauche.test)
(test-start "s3.account")
(use s3.account)
(test-module 's3.account)

(define account (make <s3:account>
		  :access-key "xxx"
		  :secret-key "yyy"))

(test* "access-key" "xxx" (s3:access-key account))
(test* "secret-key" "yyy" (s3:secret-key account))

(test-end)
