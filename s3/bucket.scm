(define-module s3.bucket
  (use s3.http)
  (use s3.account)
  (use s3.constants)
  (use sxml.ssax)
  (use sxml.sxpath)
  (export s3:put-bucket s3:delete-bucket s3:get-object-names))
(select-module s3.bucket)

(define (s3:put-bucket account name)
  (receive (code header body)
      (s3:http-put (s3:access-key account)
		   (s3:secret-key account) "/" "" :bucketname name)
    (if (string=? code "200")
	header
	(error "s3:put-bucket: response code is not 200"
	       code header body))))

(define (s3:delete-bucket account name)
  (receive (code header body)
      (s3:http-delete (s3:access-key account)
		      (s3:secret-key account) "/" :bucketname name)
    (if (string=? code "204")
	header
	(error "s3:delete-bucket: response code is not 204"
	       code header body))))

(define (s3:get-object-names account name)
  (receive (code header body)
      (s3:http-get (s3:access-key account)
		   (s3:secret-key account) "/" :bucketname name)
    (if (string=? "200" code)
	((sxpath "//Contents/Key/text()")
	 (call-with-input-string body
	   (cut ssax:xml->sxml <> `[(#f . ,s3:namespace)])))
	(error "s3:get-object-names: response code is not 200"
	       code header body))))

(provide "s3/bucket")
