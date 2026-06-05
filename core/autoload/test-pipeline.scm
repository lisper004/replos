;; so... it doesn't work perfectly yet, or rather it doesn't work at all (but it compiles), so if you understand this, try to correct my mistakes and errors.


(use-modules (fibers)
             (fibers channels)
             (ice-9 match)
             (srfi srfi-1))

(define (make-pipeline source . steps)
  
  (let ((in-ch (make-channel))
        (out-ch (make-channel)))

    ;; source
    (spawn-fiber
     (lambda ()
       (let loop ()
         (let ((val (source)))
           (if (eq? val #f)  ; end signal
               (put-message in-ch 'eof)
               (begin
                 (put-message in-ch val)
                 (loop)))))))
    
    (let loop-steps ((remaining steps)
                     (current-ch in-ch)
                     (next-ch out-ch))
      (match remaining
        (() #f)
        ((step . rest)
         (if (null? rest)
             (spawn-fiber
              (lambda ()
                (let process ()
                  (let ((msg (get-message current-ch)))
                    (if (eq? msg 'eof)
                        (put-message next-ch 'eof)
                        (begin
                          (step msg (lambda (out) (put-message next-ch out)))
                          (process)))))))
             (let ((mid-ch (make-channel)))
               (spawn-fiber
                (lambda ()
                  (let process ()
                    (let ((msg (get-message current-ch)))
                      (if (eq? msg 'eof)
                          (put-message mid-ch 'eof)
                          (begin
                            (step msg (lambda (out) (put-message mid-ch out)))
                            (process)))))))
               (loop-steps rest mid-ch next-ch))))))
    
    (lambda ()
      (let ((msg (get-message out-ch)))
        (if (eq? msg 'eof)
            #f
            msg)))))

;; ============================================================
;; Functions-steps
;; ============================================================

(define (grep pattern)
  (lambda (input send)
    (when (string-contains? input pattern)
      (send input))))

(define (wc-lines)
  (let ((count 0))
    (lambda (input send)
      (if (eq? input 'eof)
          (send count)
          (set! count (+ count 1))))))

(define (collect-all)
  (let ((acc '()))
    (lambda (input send)
      (if (eq? input 'eof)
          (send (reverse acc))
          (set! acc (cons input acc))))))

(define (map-step proc)
  (lambda (input send)
    (send (proc input))))

(define (filter-step pred)
  (lambda (input send)
    (when (pred input)
      (send input))))

;; ============================================================
;; Utils to make source
;; ============================================================

(define (source-from-list lst)
  (let ((remaining lst))
    (lambda ()
      (if (null? remaining)
          #f
          (let ((val (car remaining)))
            (set! remaining (cdr remaining))
            val)))))

(define (source-from-file filename)
  (let ((port (open-input-file filename)))
    (lambda ()
      (let ((line (read-line port)))
        (if (eof-object? line)
            (begin
              (close-port port)
              #f)
            line)))))

(define (source-from-port port)
  (lambda ()
    (let ((line (read-line port)))
      (if (eof-object? line)
          #f
          line))))

(define (example-for-pipeline)
  (run-fibers
   (lambda ()
     (let* ((src (source-from-list '(1 2 3 4 5 6 7 8 9 10)))
            (pipeline (make-pipeline src
                                     (filter-step odd?)
                                     (map-step (lambda (x) (* x x)))
                                     (collect-all))))
       (let ((result (pipeline)))
         (format #t "Pipeline result: ~a\n" result)))))
   #:drain? #t)

;;Out: (1 9 25 49 81)
