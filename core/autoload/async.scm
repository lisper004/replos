(use-modules (ice-9 threads))

(define *async-processes* '())
(define *async-id-counter* 0)

(define (async thunk)
  (set! *async-id-counter* (+ *async-id-counter* 1))
  (let ((id *async-id-counter*))
    (call-with-new-thread
     (lambda ()
       (catch #t
         (lambda () 
           (thunk)
           (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*)))
         (lambda (key . args)
           (format #t ">> Async job ~a error: ~a\n" id key)
           (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*))))))
    (set! *async-processes* (cons id *async-processes*))
    (format #t ">> Async job ~a started\n" id)
    id))

(define (async-command cmd)
  (set! *async-id-counter* (+ *async-id-counter* 1))
  (let ((id *async-id-counter*))
    (call-with-new-thread
     (lambda ()
       (system cmd)
       (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*))))
    (set! *async-processes* (cons id *async-processes*))
    (format #t ">> Async command ~a started: ~a\n" id cmd)
    id))

(define (async-list)
  (if (null? *async-processes*)
      (display ">> No async jobs running.\n")
      (begin
        (display "=== Async Jobs ===\n")
        (for-each (lambda (id) (format #t "Job ~a\n" id)) *async-processes*))))

(define (async-kill id)
  ;; Can work not good
  (format #t ">> Cannot kill thread ~a in Guile portably.\n" id))

(define (async-kill-all)
  (set! *async-processes* '())
  (display ">> All async jobs cleared (but threads may still run).\n"))

(define (async-wait id)
  (let loop ()
    (if (member id *async-processes*)
        (begin
          (sleep 0.1)
          (loop))
        (format #t ">> Async job ~a completed\n" id))))

(define (bg cmd) (async-command cmd))
(define (jobs) (async-list))
(define (kill id) (async-kill id))
