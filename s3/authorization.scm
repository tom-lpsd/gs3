(define-module s3.authorization
  (use rfc.sha1)
  (use rfc.hmac)
  (use rfc.base64)
  (use srfi-1)
  (use srfi-13)
  (export s3:signiture s3:canonicalize))
(select-module s3.authorization)

(define (s3:signiture key method host path headers . opts)
  (let ((string-to-sign (s3:canonicalize method host path headers opts)))
    (base64-encode-string
     (hmac-digest-string string-to-sign
			 :key key
			 :hasher <sha1>))))

(define (extract-certain-header headers)
  (let loop ((md5 "") (type "") (date "")
	     (amz-date #f) (amz '()) (headers headers))
    (if (null? headers)
	(values md5 type (if amz-date "" date) amz)
	(let ((header (string-downcase (car headers)))
	      (value (string-trim-both (x->string (cadr headers))))
	      (next (cddr headers)))
	  (cond [(string=? "content-type" header)
		 (loop md5 value date amz-date amz next)]
		[(string=? "content-md5" header)
		 (loop value type date amz-date amz next)]
		[(string=? "date" header)
		 (loop md5 type value amz-date amz next)]
		[(string=? "x-amz-date" header)
		 (loop md5 type date #t
		       (cons (cons header value) amz) next)]
		[(string-prefix? "x-amz-" header)
		 (loop md5 type date amz-date
		       (cons (cons header value) amz) next)]
		[else (loop md5 type date amz-date amz next)])))))

(define (extract-bucketname host)
  (if (not host)
      ""
      (rxmatch-case host
	[#/(.*)\.s3\.amazonaws\.com/ (#f bucket)
	   (string-append "/" (string-downcase bucket))]
	[#/^s3\.amazonaws\.com$/ (#f) ""]
	[#/([^:]*)(:\d+)?/ (#f bucket #f)
	   (string-append "/" (string-downcase bucket))]
	[else ""])))

(define (merge-headers headers)
  (cons (caar headers)
	(string-join (map cdr headers) ",")))

(define (merge-amz-headers headers)
  (let loop ((headers headers)
	     (result '()))
    (if (null? headers)
	result
	(receive (l r)
	    (partition (lambda (v) (equal? (car v) (caar headers))) headers)
	  (loop r (cons (merge-headers (reverse l)) result))))))

(define (s3:canonicalize method host path headers args)
  (let-keywords args ((expires #f))
    (let ((path (string-append (extract-bucketname host) path)))
      (receive (md5 type date amz) (extract-certain-header headers)
	(with-output-to-string
	  (lambda ()
	    (print (string-upcase
		    (if (keyword? method)
			(keyword->string method) method)))
	    (for-each print (list md5 type date))
	    (for-each (lambda (pair)
			(print (car pair) ":" (cdr pair)))
		      (sort (merge-amz-headers amz)
			    (lambda (x y)
			      (string<? (car x) (car y)))))
	    (let ((m (#/([^?]*)(\??.*)/ path)))
	      (display (m 1))
	      (rxmatch-case (m 2)
		[#/(\?|&)(acl|location|logging|torrent)(&|=|$)/
		   (#f #f resourse #f)
		   (display #`"?,resourse")]))))))))

(provide "s3/authorization")
