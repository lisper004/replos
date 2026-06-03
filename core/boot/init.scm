;; Init REPLOS

;; BASE DIRECTORY
(define *replos-root* (string-append (getenv "HOME") "/.replos/"))
(define *replos-core* (string-append *replos-root* "core/"))
(define *replos-boot* (string-append *replos-core* "boot/"))
(define *replos-autoload* (string-append *replos-core* "autoload/"))

(add-to-load-path *replos-root*)
(add-to-load-path *replos-core*)
(add-to-load-path *replos-boot*)
(add-to-load-path *replos-autoload*)

;; Helper function
(define (load-if-exists file)
  (if (file-exists? file)
      (begin
        (load file)
        #t)
      #f))

;; 1. Loading replos.scm 
(display "[BOOT] Loading REPLOS core...\n")
(load-if-exists (string-append *replos-root* "replos.scm"))

;; 2. Loading all .scm files from core/autoload/
(let ((autoload-files (scandir *replos-autoload* 
                               (lambda (f) (string-suffix? ".scm" f)))))
  (if autoload-files
      (begin
        (display "[BOOT] Loading autoload modules:\n")
        (for-each (lambda (file)
                    (format #t "  → ~a\n" file)
                    (load (string-append *replos-autoload* file)))
                  (sort autoload-files string<?)))
      (display "[BOOT] No autoload modules found.\n")))

(display "[BOOT] REPLOS ready.\n")
