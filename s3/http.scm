(define-module s3.http
  (use rfc.http)
  (use srfi-19)
  (use s3.constants)
  (use s3.authorization)
  (export s3:get))
(select-module s3.http)

(define (date->http-date-string date)
  (date->string
   (modified-julian-day->date (date->modified-julian-day date) 0)
   "~@a, ~d ~@b ~Y ~X GMT"))

(with-module rfc.http
  (export http-generic))

(define (append-header key value headers)
  (cons key (cons value headers)))

(define (s3:get access-key secret-key path . opts)
  (let-keywords* opts ((bucketname "")
		       (headers '()))
    (let* ((host (string-append bucketname s3:host))
	   (date (date->http-date-string (current-date)))
	   (headers (append-header "Date" date headers))
	   (sign (s3:signiture secret-key :GET path headers))       
	   (auth-value #`"AWS ,|access-key|:,sign"))
      (http-generic 'GET host path #f
		    (append-header "Authorization" auth-value headers)))))

(provide "s3/http")
