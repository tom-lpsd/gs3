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

(print (slot-ref bucketlist'raw))

(test-end)
