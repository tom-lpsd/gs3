(define-module s3.bucketlist
  (use s3.http)
  (use s3.constants)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use sxml.serializer)
  (export <s3:bucketlist> bucket-names))
(select-module s3.bucketlist)

(define-class <s3:bucketlist> ()
  (owner buckets))

(define (get-element-text element-name sxml)
  (car ((sxpath (list element-name '*text*)) sxml)))

(define (make-owner-alist sxml)
  (list (cons 'id (get-element-text 'ID sxml))
	(cons 'display-name (get-element-text 'DisplayName sxml))))

(define (make-bucket-alist sxml)
  (list (cons 'name (get-element-text 'Name sxml))
	(cons 'creation-date (get-element-text 'CreationDate sxml))))

(define (construct-bucketlist self sxml)
  (let ((owner (car ((sxpath "//ListAllMyBucketsResult/Owner") sxml)))
	(buckets ((sxpath "//Bucket") sxml)))
    (slot-set! self 'owner (make-owner-alist owner))
    (slot-set! self 'buckets
	       (map make-bucket-alist buckets))))

(define (get-bucketlist-sxml access-key secret-key)
  (receive (code header body)
      (s3:get access-key secret-key "/")
    (call-with-input-string body
      (cut ssax:xml->sxml <> `[(#f . ,s3:namespace)]))))

(define-method initialize ((self <s3:bucketlist>) args)
  (next-method)
  (let-keywords args ((access-key #f)
		      (secret-key #f))
    (if (and access-key secret-key)
	(construct-bucketlist self (get-bucketlist-sxml access-key secret-key))
	(error "s3.initialize: please specify accsess key and secret key"))))

(define (bucket-names self)
  (map (lambda (bucket)
	 (cdr (assq 'name bucket))) (slot-ref self 'buckets)))

(provide "s3/bucketlist")
