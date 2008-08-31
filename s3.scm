(define-module s3
  (use s3.http)
  (use s3.constants)
  (use sxml.ssax)
  (use sxml.sxpath)
  (extend s3.account s3.bucket)
  (export s3:get-bucket-names))
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

(provide "s3")
