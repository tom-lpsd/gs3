(use gauche.test)
(use gauche.interactive)
(test-start "s3.bucketlist module")

(use s3.bucketlist)
(test-module 's3.bucketlist)

(define access-key #f)
(define secret-key #f)

(define bucketlist (make <s3:bucketlist> 
		     :access-key access-key
		     :secret-key secret-key))

(print (s3:get-bucket-names bucketlist))

(s3:get-bucket bucketlist "tom-lpsd-foo")

(test-end)
