(define-module s3.account
  (export <s3:account> s3:access-key s3:secret-key))
(select-module s3.account)

(define-class <s3:account> ()
  ((access-key :init-keyword :access-key :getter s3:access-key)
   (secret-key :init-keyword :secret-key :getter s3:secret-key)))

(provide "s3/account")
