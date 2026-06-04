(use-modules (ice-9 readline)
             (ice-9 rdelim)
             (ice-9 ftw))

;; ============================================================
;; 1. BASE VARIABLES
;; ============================================================

(define *replos-version* "0.6")
(define *replos-home* (string-append (getenv "HOME") "/.replos/"))
(define *replos-lib* (string-append *replos-home* "core/lib/"))
(define *replos-state* (string-append *replos-home* "state.scm"))

(define *loaded-packages* '())

;; ============================================================
;; 2. AUXILIARY FUNCTIONS
;; ============================================================

(define (ensure-directories)
  (for-each (lambda (d) 
              (unless (file-exists? d)
                (mkdir d)
                (format #t "[REPLOS] Created: ~a\n" d)))
            (list *replos-home* *replos-lib*)))

(define (basename path)
  (let ((last-slash (string-rindex path #\/)))
    (if last-slash
        (substring path (+ last-slash 1))
        path)))

(define (file-is-directory? path)
  (and (file-exists? path)
       (eq? (stat:type (stat path)) 'directory)))

(define (scandir-nodots dir)
  (if (file-exists? dir)
      (let ((files (scandir dir)))
        (if files
            (filter (lambda (f) (not (or (string=? f ".") (string=? f "..")))) files)
            '()))
      '()))

;; ============================================================
;; 3. LOADING AND SAVING STATE
;; ============================================================

(define (save-state)
  (call-with-output-file *replos-state*
    (lambda (port)
      (write `(set! *loaded-packages* ',*loaded-packages*) port)))
  (format #t "[REPLOS] State saved.\n"))

(define (load-state)
  (if (file-exists? *replos-state*)
      (begin
        (load *replos-state*)
        (format #t "[REPLOS] State loaded.\n"))
      (format #t "[REPLOS] No saved state.\n")))

;; ============================================================
;; 4. LOADING PACKAGES
;; ============================================================

(define (load-lisp-file filepath)
  (catch #t
    (lambda () 
      (load filepath)
      (format #t "[OK] Loaded ~a\n" (basename filepath)))
    (lambda (key . args)
      (format #t "[ERROR] ~a\n" (basename filepath)))))

(define (load-all-packages)
  (set! *loaded-packages* '())
  (if (file-exists? *replos-lib*)
      (let ((files (scandir-nodots *replos-lib*)))
        (set! files (filter (lambda (f) (string-suffix? ".lisp" f)) files))
        (if (null? files)
            (format #t "[REPLOS] No packages found.\n")
            (begin
              (format #t "[REPLOS] Loading packages:\n")
              (for-each (lambda (file)
                          (let ((full (string-append *replos-lib* file)))
                            (load-lisp-file full)
                            (set! *loaded-packages* (cons file *loaded-packages*))))
                        (sort files string<?))
              (format #t "[REPLOS] Loaded ~a packages.\n" (length *loaded-packages*)))))
      (format #t "[REPLOS] No packages directory.\n")))

;; NOT IN USE YET

;; (define (package-install)
;;   (ensure-directories)
;;   (display "Package name: ")
;;   (let ((pkg (string-trim-both (read-line))))
;;     (if (string-null? pkg)
;;         (format #t "Aborted.\n")
;;         (let ((target-file (string-append *replos-lib* pkg ".lisp")))
;;           (if (file-exists? target-file)
;;               (format #t "Package ~a already installed.\n" pkg)
;;               (begin
;;                 (format #t "Creating template for ~a.lisp...\n" pkg)
;;                 (call-with-output-file target-file
;;                   (lambda (port)
;;                     (format port ";; Package: ~a\n" pkg)
;;                     (format port "(define (~a)\n" pkg)
;;                     (format port "  (display \"Hello from ~a!\\n\"))\n" pkg)))
;;                 (load-lisp-file target-file)
;;                 (set! *loaded-packages* (cons (string-append pkg ".lisp") *loaded-packages*))
;;                 (format #t "[REPLOS] Package ~a created.\n" pkg)
;;                 (format #t "  Usage: (~a)\n" pkg)
;;                 (format #t "  Edit:  (edit '~a)\n" pkg)))))))

;; (define (package-remove pkg)
;;   (let ((file (string-append *replos-lib* pkg ".lisp")))
;;     (if (file-exists? file)
;;         (begin
;;           (delete-file file)
;;           (set! *loaded-packages* (delete (string-append pkg ".lisp") *loaded-packages*))
;;           (format #t "[REPLOS] Package ~a removed.\n" pkg))
;;         (format #t "Package ~a not found.\n" pkg))))

;; (define (packages)
;;   (if (null? *loaded-packages*)
;;       (format #t "No packages installed.\n")
;;       (begin
;;         (format #t "Installed packages (~a):\n" (length *loaded-packages*))
;;         (for-each (lambda (pkg) (format #t "  ~a\n" pkg))
;;                   (sort *loaded-packages* string<?)))))

;; (define (edit pkg)
;;   (let ((file (string-append *replos-lib* pkg ".lisp")))
;;     (if (file-exists? file)
;;         (let ((editor (or (getenv "EDITOR") "nano")))
;;           (system (string-append editor " " file))
;;           (format #t "Reload ~a? (y/n): " pkg)
;;           (let ((answer (read-line)))
;;             (when (or (string=? answer "y") (string=? answer "yes"))
;;               (load-lisp-file file)
;;               (format #t "[REPLOS] ~a reloaded.\n" pkg))))
;;         (format #t "Package ~a not found. Install it first.\n" pkg))))

;; (define (reload)
;;   (format #t "Reloading all packages...\n")
;;   (load-all-packages))

;; ============================================================
;; 7. SYSTEM FUNCTIONS
;; ============================================================

(define (help)
  (display "
+-----------------------------------------------------------------+
|                         REPLOS HELP                            |
+-----------------------------------------------------------------+
| FILESYSTEM                                                     |
|   (ls \"dir\")        - list directory                         |
|   (cd \"dir\")       - change directory                        |
|   (whereami)             - print working directory             |
|   (make-dir \"dir\")    - create directory                     |
|   (remove-dir \"dir\")    - remove empty directory             |
|   (cat \"file\")     - display file content                    |
|   (touch \"file\")   - create/update file                      |
|   (rm \"file\")      - delete file                             |
|                                                                |
|                                                                |
| SYSTEM                                                         |
|   (save)            - save session state                       |
|   (help)            - this message                             |
|   (quit)            - exit REPLOS                              |
|                                                                |
| You can also write any Scheme expression!                      |
+-----------------------------------------------------------------+
"))
  (format #t "REPLOS version ~a\n" *replos-version*)

(define (quit)
  (format #t ">> Are u sure? (y/n): ")
  (let ((answer (read-line)))
    (when (or (string=? answer "y") (string=? answer "yes"))
      (format #t ">> Uh, Fine. But you'll be back.\n")
      (save-state)
      (exit))))

(define (clear)
  (system "clear"))

(define (save)
  (save-state))

;; ============================================================
;; 8. START
;; ============================================================

(define (main)
  (display "\n")
  (display "+-------------------------------------+\n")
  (display "|            REPLOS                   |\n")
  (display "|   Living System Environment         |\n")
  (display "|   All commands in parentheses       |\n")
  (display "|   by Lisper004                      |\n")
  (display "+-------------------------------------+\n")
  (display "\n")
  
  (ensure-directories)
  (activate-readline)
  (load-state)
  (load-all-packages)
  
  (display "\n")
  (help))

(main)
