(define-module s3.http
  (use rfc.http)
  (use srfi-19)
  (use sxml.ssax)
  (use sxml.serializer)
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

(define (s3:get access-key secret-key path)
  (let* ((date (date->http-date-string (current-date)))
	 (headers `("Date" ,date))
	 (sign (s3:signiture secret-key :GET path headers))
	 (auth-value #`"AWS ,|access-key|:,sign"))
    (receive (code headers body)
	(http-generic 'GET s3:host path #f
		      (cons "Authorization" (cons auth-value headers)))
      (call-with-input-string body
	(lambda (in)
	    (ssax:xml->sxml in `[(#f . ,s3:namespace)]))))))

(provide "s3/http")
