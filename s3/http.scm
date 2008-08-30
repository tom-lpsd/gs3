(define-module s3.http
  (use rfc.http)
  (use srfi-19)
  (use s3.constants)
  (use s3.authorization)
  (export s3:http-get s3:http-put s3:http-post s3:http-delete))
(select-module s3.http)

(define (date->http-date-string date)
  (date->string
   (modified-julian-day->date (date->modified-julian-day date) 0)
   "~@a, ~d ~@b ~Y ~X GMT"))

(with-module rfc.http
  (export http-generic))

(define (append-header key value headers)
  (cons key (cons value headers)))

(define (s3:http-generic access-key secret-key method path body opts)
  (let-keywords opts ((bucketname #f)
		      (headers '())
		      . opts)
    (let* ((host (if bucketname #`",|bucketname|.,s3:host" s3:host))
	   (date (date->http-date-string (current-date)))
	   (headers (append-header "Date" date headers))
	   (sign (s3:signiture secret-key method host path headers))       
	   (auth-value #`"AWS ,|access-key|:,sign"))
      (http-generic method host path body
		    (append-header "Authorization" auth-value headers)))))

(define (s3:http-get access-key secret-key path . opts)
  (s3:http-generic access-key secret-key :GET path #f opts))

(define (s3:http-put access-key secret-key path body . opts)
  (s3:http-generic access-key secret-key :PUT path body opts))

(define (s3:http-post access-key secret-key path body . opts)
  (s3:http-generic access-key secret-key :POST path body opts))

(define (s3:http-delete access-key secret-key path . opts)
  (s3:http-generic access-key secret-key :DELETE path #f opts))

(provide "s3/http")
