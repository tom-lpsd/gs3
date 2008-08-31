(define-module s3.bucket
  (use s3.http)
  (use s3.account)
  (export s3:put-bucket s3:delete-bucket))
(select-module s3.bucket)

(define (s3:put-bucket account name)
  (receive (code header body)
      (s3:http-put (s3:access-key account)
		   (s3:secret-key account) "/" #f :bucketname name)
    (if (= code 200)
	header
	(error "s3:put-bucket: response code is not 200"))))

(define (s3:delete-bucket account name)
  (receive (code header body)
      (s3:http-delete (s3:access-key account)
		      (s3:secret-key account) "/" :bucketname name)
    (if (= code 204)
	header
	(error "s3:delete-bucket: response code is not 204"))))

(provide "s3/bucket")