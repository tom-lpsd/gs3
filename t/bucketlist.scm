(use gauche.test)
(use gauche.interactive)
(test-start "s3.bucketlist module")

(use s3.bucketlist)
(test-module 's3.bucketlist)

(define bucketlist (make <s3:bucketlist> 
		     :access-key "1S637VAGNG22EXKCB902"
		     :secret-key "ZnQLc4ra+Qs1hFMNBxYIkguS1JEAkjzFsQmTCcEa"))

(print (slot-ref bucketlist'raw))

(test-end)
