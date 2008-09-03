(define-module s3.object
  (use s3.http)
  (use s3.account)
  (use s3.constants)
  (export s3:get-object s3:put-object s3:delete-object))
(select-module s3.object)

(define (s3:put-object account bucket-name object-name object-body)
  (receive (code header body)
      (s3:http-put (s3:access-key account)
		   (s3:secret-key account) #`"/,object-name" object-body
		   :bucketname bucket-name)
    (if (string=? code "200")
	header
	(error "s3:put-object: response code is not 200"
	       code header body))))

(define (s3:get-object account bucket-name object-name)
  (receive (code header body)
      (s3:http-get (s3:access-key account)
		   (s3:secret-key account) #`"/,object-name"
		   :bucketname bucket-name)
    (if (string=? code "200")
	body
	(error "s3:get-object: response code is not 200"
	       code header body))))

(define (s3:delete-object account bucket-name object-name)
  (receive (code header body)
      (s3:http-delete (s3:access-key account)
		      (s3:secret-key account) #`"/,object-name"
		      :bucketname bucket-name)
    (if (string=? code "204")
	header
	(error "s3:delete-object: response code is not 200"
	       code header body))))

(provide "s3/object")
