(use gauche.test)
(test-start "s3.bucket module")

(use s3.bucket)
(test-module 's3.bucket)

(define access-key #f)
(define secret-key #f)

(define bucket (make <s3:bucket>
		 :bucket-name bucket-name
		 :access-key access-key
		 :secret-key secret-key))
(s3:put bucket)
(s3:get bucket)
(s3:delete bucket)

(define bucketlist (make <s3:bucketlist> 
		     :access-key access-key
		     :secret-key secret-key))

(test-end)
