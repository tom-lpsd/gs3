(define-module s3
  (use s3.http)
  (use s3.constants)
  (use sxml.ssax)
  (use sxml.sxpath)
  (extend s3.account s3.bucket s3.object)
  (export s3:get-bucket-names s3:put-file s3:get-file))
(select-module s3)

(define (get-bucketlist-sxml access-key secret-key)
  (receive (code header body)
      (s3:http-get access-key secret-key "/")
    (call-with-input-string body
      (cut ssax:xml->sxml <> `[(#f . ,s3:namespace)]))))

(define (s3:get-bucket-names account)
  (let ((sxml (get-bucketlist-sxml
	       (s3:access-key account) (s3:secret-key account))))
    ((sxpath "//Bucket/Name/text()") sxml)))

(define (slurp in)
  (with-output-to-string
    (lambda ()
      (let loop ((chunk (read-block 2000 in)))
	(unless (eof-object? chunk)
	    (display chunk)
	    (loop (read-block 2000 in)))))))

(define (s3:put-file account bucket-name file-name . opts)
  (let-keywords opts ((object-name file-name))
    (call-with-input-file file-name
      (lambda (in)
	(let ((body (slurp in)))
	  (s3:put-object account bucket-name object-name body))))))

(define (s3:get-file account bucket-name object-name . opts)
  (let-keywords opts ((file-name object-name))
    (with-output-to-file file-name
      (lambda ()
	(display (s3:get-object account bucket-name object-name))))))

(provide "s3")
