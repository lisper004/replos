(use-modules (ice-9 readline)
             (ice-9 rdelim)
             (ice-9 ftw))

(define *replos-start-time* (current-time))

(define (ls . dir)
  (let ((target (if (null? dir) "." (car dir))))
    (if (file-exists? target)
        (let ((files (scandir-nodots target)))
          (if (null? files)
              (format #t "Directory ~a is empty.\n" target)
              (begin
                (format #t "Contents of ~a:\n" target)
                (for-each (lambda (f) 
                            (let ((full (string-append target "/" f)))
                              (format #t "  ~a~a\n" 
                                      f (if (file-is-directory? full) "/" ""))))
                          files))))
        (format #t "Directory ~a not found.\n" target))))

(define (cd dir)
  (if (file-exists? dir)
      (begin
        (chdir dir)
        (format #t "Now in: ~a\n" (getcwd)))
      (format #t "Directory ~a not found.\n" dir)))

(define (whereami)
  (format #t "~a\n" (getcwd)))

(define (make-dir dir)
  (if (file-exists? dir)
      (format #t "Directory ~a already exists.\n" dir)
      (begin
        (mkdir dir)
        (format #t "Created: ~a\n" dir))))

(define (remove-dir dir)
  (catch #t
    (lambda () 
      (rmdir dir)
      (format #t "Removed: ~a\n" dir))
    (lambda (key . args)
      (format #t "Cannot remove ~a\n" dir))))

(define (remove-dir-recursive dir)
  (define (delete-all files)
    (for-each (lambda (file)
                (let ((full (string-append dir "/" file)))
                  (if (file-is-directory? full)
                      (remove-dir-recursive full)
                      (delete-file full))))
              files))
  
  (let ((files (list-dir dir)))
    (delete-all files)
    (rmdir dir))
  (format #t "Removed: ~a\n" dir))

(define (cat file)
  (if (file-exists? file)
      (call-with-input-file file
        (lambda (port)
          (let loop ()
            (let ((line (read-line port)))
              (if (eof-object? line)
                  #t
                  (begin
                    (display line)
                    (newline)
                    (loop)))))))
      (format #t "File ~a not found.\n" file)))

(define (touch file)
  (call-with-output-file file (lambda (port) #t))
  (format #t "Touched: ~a\n" file))

(define (rm file)
  (if (file-exists? file)
      (begin
        (delete-file file)
        (format #t "Deleted: ~a\n" file))
      (format #t "File ~a not found.\n" file)))

(define (ed file)
  (system (string-append "emacs -nw " file)) ;; Make sure you have emacs installed.
  (format #t "Back in REPL. Reload? (y/n): ")
  (when (string=? (read-line) "y")
    (load file)))

(define (uptime)
  (let* ((now (current-time))
         (diff (- now *replos-start-time*))
         (hours (quotient diff 3600))
         (mins (quotient (remainder diff 3600) 60))
         (secs (remainder diff 60)))
    (format #t "REPLOS session uptime: ")
    (when (> hours 0) (format #t "~d hour~p " hours hours))
    (when (> mins 0) (format #t "~d minute~p " mins mins))
    (format #t "~d second~p\n" secs secs)
    (if (< diff 60)
        (display ">> Fresh session! Welcome.\n")
        (display ">> Still going strong!\n"))))
