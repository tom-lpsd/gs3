(use gauche.test)
(test-start "s3.http module")
(use srfi-19)
(use s3.http)
(test-module 's3.http)

(print (date->http-date-string (current-date)))
(test-end)
