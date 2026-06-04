(use-modules (ice-9 rdelim)
             (ice-9 ftw)
             (ice-9 popen))

(define repo "https://raw.githubusercontent.com/lisper004/replos-repository/main/")
(define autoload-dir (string-append (getenv "HOME") "/.replos/core/autoload/"))

(define (download-file url target-path)
  (let ((wget-cmd (string-append "wget -q -O " target-path " " url))
        (curl-cmd (string-append "curl -s -o " target-path " " url)))
    (format #t ">> Downloading ~a ...\n" url)
    (cond
     ((zero? (system wget-cmd)) #t)
     ((zero? (system curl-cmd)) #t)
     (else
      (format #t "[ERROR]: Neither wget nor curl succeeded.\n")
      #f))))

(define (ensure-autoload-dir)
  (unless (file-exists? autoload-dir)
    (mkdir autoload-dir)))

(define (yes-no-prompt question)
  (display question)
  (display " (y/n): ")
  (flush-all-ports)
  (let ((answer (read-line)))
    (or (string=? answer "y")
        (string=? answer "yes"))))

(define (reload-repl)
  (load (string-append (getenv "HOME") "/.replos/core/boot/init.scm"))
  (display ">> REPL reloaded.\n"))

(define (strip-suffix str suffix)
  (if (string-suffix? suffix str)
      (substring str 0 (- (string-length str) (string-length suffix)))
      str))

(define (list-installed-packages)
  (if (file-exists? autoload-dir)
      (let ((files (scandir autoload-dir 
                            (lambda (f) (string-suffix? ".scm" f)))))
        (if files
            (map (lambda (f) (strip-suffix f ".scm")) files)
            '()))
      '()))

(define (package-install)
  (ensure-autoload-dir)
  (display ">> Name of Package: ")
  (let ((pkg-name (string-trim-both (read-line))))
    (if (string-null? pkg-name)
        (display ">> Canceled.\n")
        (let ((filename (string-append pkg-name ".scm"))
              (target-file (string-append autoload-dir pkg-name ".scm"))
              (url (string-append repo pkg-name ".scm")))
          (if (download-file url target-file)
              (begin
                (format #t ">> Installed to core/autoload/~a\n" filename)
                (when (yes-no-prompt "Do you want autoload")
                  (display ">> Will be loaded on next REPL start.\n"))
                (when (yes-no-prompt "Do you want reload REPL now")
                  (reload-repl)))
              (format #t "[ERROR]: Failed to install ~a\n" pkg-name))))))

(define (package-list)
  (let ((packages (list-installed-packages)))
    (if (null? packages)
        (display ">> No packages installed.\n")
        (begin
          (display ">> Installed packages:\n")
          (for-each (lambda (pkg) (display pkg) (newline)) packages)))))

(define (package-remove)
  (display ">> Name of Package to remove: ")
  (let ((pkg-name (string-trim-both (read-line))))
    (if (string-null? pkg-name)
        (display ">> Canceled.\n")
        (let ((target-file (string-append autoload-dir pkg-name ".scm")))
          (if (file-exists? target-file)
              (begin
                (delete-file target-file)
                (format #t ">> Removed ~a\n" pkg-name)
                (when (yes-no-prompt ">> Do you want reload REPL now")
                  (reload-repl)))
              (format #t ">> Package ~a not found.\n" pkg-name))))))

(ensure-autoload-dir)

(display "\n Package Manager loaded.\n")
(display "  (package-install) - install new package\n")
(display "  (package-list)    - list installed packages\n")
(display "  (package-remove)  - remove package\n")
