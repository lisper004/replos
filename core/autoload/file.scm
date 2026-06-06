;; More Utils

(define (why)
  (simple-format #t "why?\n")
  (simple-format #t "idk bro\n"))

(define (helloworld)
  (display "hello world!")
  (newline))

(define (cmd arg)
  (system arg))

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
