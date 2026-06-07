;; More Utils

(define (why)
  (simple-format #t "why?\n")
  (simple-format #t "idk bro\n"))

(define (helloworld)
  (display "hello world!")
  (newline))

(define (cmd arg)
  (system arg))

(define (runsc scmfile)
  (system (string-append "guile " scmfile)))

(define (git-status)
  (cmd "git status"))

(define (git-add-all)
  (cmd "git add ."))

(define (git-commit-m aboutcommit)
  (cmd (simple-format #f "git commit -m \"~a\"" aboutcommit)))

(define (git-pull-r)
  (cmd "git pull --rebase"))

(define (git-push)
  (cmd "git push"))

(define (git-update-all aboutcommit)
  (git-add-all)
  (git-commit-m aboutcommit)
  (git-push))

;; For Arch Linux Pacman Scripts

(define (pm-update)
  (cmd "sudo pacman -Syu"))

(define (pm-install . packages)
  (if (null? packages)
      (display ">> Usage: (pm-install package1 package2 ...)\n")
      (cmd (simple-format #f "sudo pacman -S ~a" (string-join packages " ")))))

(define (pm-remove . packages)
  (if (null? packages)
      (display ">> Usage: (pm-remove package1 package2 ...)\n")
      (cmd (simple-format #f "sudo pacman -Rns ~a" (string-join packages " ")))))

(define (pm-pacstrap . packages)
  (if (null? packages)
      (display ">> Usage: (pm-pacstrap package1 package2 ...)\n")
      (cmd (simple-format #f "pacstrap -i /mnt ~a" (string-join packages " ")))))

(define (pm-search keyword)
  (cmd (simple-format #f "pacman -Ss ~a" keyword)))

(define (pm-info package)
  (cmd (simple-format #f "pacman -Qi ~a" package)))

(define (pm-clean)
  (cmd "sudo pacman -Sc"))

(define (pm-orphans)
  (cmd "pacman -Qdt"))

(define (pm-remove-orphans)
  (cmd "sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null || echo 'No orphans found'"))

;; For install ISO

(define (cfdisk devsdd)
  (cmd (simple-format #f "cfdisk ~a" devsdd)))
