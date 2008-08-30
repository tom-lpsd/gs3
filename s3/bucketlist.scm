(define-module s3.bucketlist
  (use s3.http)
  (use s3.constants)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use sxml.serializer)
  (use gauche.parameter)
  (export <s3:bucketlist>
	  s3:put-bucket
	  s3:get-bucket
	  s3:delete-bucket
	  s3:get-bucket-names))
(select-module s3.bucketlist)

(define-class <s3:bucketlist> ()
  ((access-key :init-keyword :access-key)
   (secret-key :init-keyword :secret-key)))

(define (get-bucketlist-sxml access-key secret-key)
  (receive (code header body)
      (s3:http-get access-key secret-key "/")
    (call-with-input-string body
      (cut ssax:xml->sxml <> `[(#f . ,s3:namespace)]))))

(define-method initialize ((self <s3:bucketlist>) args)
  (next-method)
  (unless (and (slot-ref self'access-key)
	       (slot-ref self'secret-key))
    (error "s3:bucketlist initialize: please specify accsess key and secret key")))

(define (bucket-names self)
  (map (lambda (bucket)
	 (cdr (assq 'name bucket))) (slot-ref self 'buckets)))

(define (s3:get-bucket-names bucketlist)
  (let ((sxml (get-bucketlist-sxml (slot-ref bucketlist'access-key)
				   (slot-ref bucketlist'secret-key))))
    ((sxpath "//Bucket/Name/text()") sxml)))

(define (s3:put-bucket bucketlist name)
  (s3:http-put (slot-ref bucketlist'access-key)
	       (slot-ref bucketlist'secret-key)
	       "/" #f :bucketname name))

(define (s3:delete-bucket bucketlist name)
  (s3:http-delete (slot-ref bucketlist'access-key)
		  (slot-ref bucketlist'secret-key)
		  "/" :bucketname name))

(define (s3:get-bucket bucketlist name))

(provide "s3/bucketlist")
