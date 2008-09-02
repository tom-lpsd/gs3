(use gauche.test)
(test-start "s3 module test")

(use s3)
(use s3.account)
(test-module 's3)


(print (s3:get-bucket-names (make-account-from-file "s3.conf")))

(test-end)
