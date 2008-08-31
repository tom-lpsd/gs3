(use gauche.test)
(test-start "s3 module test")

(use s3)
(use s3.account)
(test-module 's3)

(define (get-account)
  (with-input-from-file "s3.conf"
    (lambda ()
      (let* ((access-key (cadr (string-split (read-line) #/:\s*/)))
	     (secret-key (cadr (string-split (read-line) #/:\s*/))))
	(values access-key secret-key)))))

(receive (access-key secret-key) (get-account)
    #?=(s3:get-bucket-names (make-account-from-file "s3.conf")))

(test-end)
