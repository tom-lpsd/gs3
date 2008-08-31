(use gauche.test)
(test-start "s3 module test")

(use s3)
(test-module 's3)

(define (get-account)
  (with-input-from-file "s3.conf"
    (lambda ()
      (let* ((access-key (cadr (string-split (read-line) #/:\s*/)))
	     (secret-key (cadr (string-split (read-line) #/:\s*/))))
	(values access-key secret-key)))))

(receive (access-key secret-key) (get-account)
  (let ((account (make <s3:account>
		   :access-key access-key
		   :secret-key secret-key)))
    (s3:get-bucket-names account)))

(test-end)
