(use gauche.test)
(test-start "s3.authorization module")

(use s3.authorization)
(test-module 's3.authorization)

(define test-access-key "0PN5J17HBGZHT7JJ3X82")
(define test-secret-key "uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o")

(define test-cases
  '(((name "Basic GET")
     (method . GET)
     (path . "/photos/puppy.jpg")
     (headers . ("Host" "johnsmith.s3.amazonaws.com"
		 "Date" "Tue, 27 Mar 2007 19:36:42 +0000"))
     (canon . "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg")
     (sign . "xXjDGYUmKxnwqr5KXNPGldn5LbA="))
    ((name "PUT with image/jpeg")
     (method . PUT)
     (path . "/johnsmith/photos/puppy.jpg")
     (headers . ("Host" "s3.amazonaws.com"
		 "Content-Type" "image/jpeg"
		 "Content-Length" 94328
		 "Date" "Tue, 27 Mar 2007 21:15:45 +0000"))
     (canon . "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg")
     (sign . "hcicpDDvL9SsO6AkvxqmIWkmOuQ="))
    ((name "GET with query string")
     (method . GET)
     (path . "/johnsmith/?prefix=photos&max-keys=50&marker=puppy")
     (headers . ("Host" "s3.amazonaws.com"
		 "User-Agent" "Mozilla/5.0"
		 "Date" "Tue, 27 Mar 2007 19:42:41 +0000"))
     (canon . "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/")
     (sign . "jsRt/rhG+Vtp88HrYL706QhE4w4="))
    ((name "GET with acl control")
     (method . GET)
     (path . "/johnsmith/?acl")
     (headers . ("Host" "s3.amazonaws.com"
		 "Date" "Tue, 27 Mar 2007 19:44:46 +0000"))
     (canon . "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl")
     (sign . "thdUi9VAkzhkniLj96JIrOPGi0g="))
    ((name "DELETE with x-amz-date header")
     (method . DELETE)
     (path . "/johnsmith/photos/puppy.jpg")
     (headers . ("User-Agent" "dotnet"
		 "Host" "s3.amazonaws.com"
		 "Date" "Tue, 27 Mar 2007 21:20:27 +0000"
		 "x-amz-date" "Tue, 27 Mar 2007 21:20:26 +0000"))
     (canon . "DELETE\n\n\n\nx-amz-date:Tue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg")
     (sign . "k3nL7gH3+PadhTEVn5Ip83xlYzk="))
    ((name "PUT with several extended headers")
     (method . PUT)
     (path . "/db-backup.dat.gz")
     (headers . ("User-Agent" "curl/7.15.5"
		 "Host" "static.johnsmith.net:8080"
		 "Date" "Tue, 27 Mar 2007 21:06:08 +0000"
		 "x-amz-acl" "public-read"
		 "content-type" "application/x-download"
		 "Content-MD5" "4gJE4saaMU4BqNR0kLY+lw=="
		 "X-Amz-Meta-ReviewedBy" "joe@johnsmith.net"
		 "X-Amz-Meta-ReviewedBy" "jane@johnsmith.net"
		 "X-Amz-Meta-FileChecksum" "0x02661779"
		 "X-Amz-Meta-ChecksumAlgorithm" "crc32"
		 "Content-Disposition" "attachment; filename=database.dat"
		 "Content-Encoding" "gzip"
		 "Content-Length" "5913339"))
     (canon . "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\nx-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\nx-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz")
     (sign . "C0FlOtU8Ylb9KDTpZqYkZPX91iI="))
    ((name "Basic request for bucket listing")
     (method . GET)
     (path . "/")
     (headers . ("Host" "s3.amazonaws.com"
		 "Date" "Wed, 28 Mar 2007 01:29:59 +0000"))
     (canon . "GET\n\n\nWed, 28 Mar 2007 01:29:59 +0000\n/")
     (sign . "Db+gepJSUbZKwpx1FR0DLtEYoZA="))
    ((name "GET with utf-8 encoded path")
     (method . GET)
     (path . "/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re")
     (headers . ("Host" "s3.amazonaws.com"
		 "Date" "Wed, 28 Mar 2007 01:49:49 +0000"))
     (canon . "GET\n\n\nWed, 28 Mar 2007 01:49:49 +0000\n/dictionary/fran%C3%A7ais/pr%c3%a9f%c3%a8re")
     (sign . "dxhSBHoI6eVSPcXJqEghlUzZMnY="))))

(define (search-host headers)
  (if (null? headers)
      #f
      (if (string=? "Host" (car headers))
	  (cadr headers)
	  (search-host (cddr headers)))))

(for-each (lambda (case)
	    (let* ((assq-cdr (compose cdr assq))
		   (name (assq-cdr 'name case))
		   (path (assq-cdr 'path case))
		   (method (assq-cdr 'method case))
		   (headers (assq-cdr 'headers case))
		   (canon (assq-cdr 'canon case))
		   (sign (assq-cdr 'sign case))
		   (host (search-host headers)))
	      (test* name
		     canon
		     (s3:canonicalize method host path headers '()))
	      (test* name
		     sign
		     (s3:signiture test-secret-key method host path headers))))
	  test-cases)
     
(test-end)
