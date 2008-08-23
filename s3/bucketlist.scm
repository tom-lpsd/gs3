(define-module s3.bucketlist
  (use s3.http)
  (export <s3:bucketlist>))
(select-module s3.bucketlist)

(define-class <s3:bucketlist> ()
  (raw))

(define (get-bucketlist access-key secret-key)
  (s3:get access-key secret-key "/"))

(define-method initialize ((self <s3:bucketlist>) args)
  (next-method)
  (let-keywords args ((access-key #f)
		      (secret-key #f))
    (if (and access-key secret-key)
	(slot-set! self 'raw (get-bucketlist access-key secret-key))
	(error "s3.initialize: please specify accsess key and secret key"))))

(provide "s3/bucketlist")
