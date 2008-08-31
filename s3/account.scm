(define-module s3.account
  (export <s3:account> s3:access-key s3:secret-key  make-account-from-file))
(select-module s3.account)

(define-class <s3:account> ()
  ((access-key :init-keyword :access-key :getter s3:access-key)
   (secret-key :init-keyword :secret-key :getter s3:secret-key)))

(define (make-account-from-file filename)
  (with-input-from-file filename
    (lambda ()
      (let* ((access-key (cadr (string-split (read-line) #/:\s*/)))
	     (secret-key (cadr (string-split (read-line) #/:\s*/))))
	(make <s3:account> :access-key access-key
                           :secret-key secret-key)))))

(provide "s3/account")
