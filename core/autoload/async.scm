;;; async.scm — Асинхронные процессы для REPLOS (рабочая версия)

(use-modules (ice-9 threads))

;; ============================================================
;; Хранилище фоновых процессов
;; ============================================================
(define *async-processes* '())
(define *async-id-counter* 0)

;; ============================================================
;; Основные функции
;; ============================================================

(define (async thunk)
  "Запустить thunk в фоновом потоке"
  (set! *async-id-counter* (+ *async-id-counter* 1))
  (let ((id *async-id-counter*))
    (call-with-new-thread
     (lambda ()
       (catch #t
         (lambda () 
           (thunk)
           (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*)))
         (lambda (key . args)
           (format #t "Async job ~a error: ~a\n" id key)
           (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*))))))
    (set! *async-processes* (cons id *async-processes*))
    (format #t "Async job ~a started\n" id)
    id))

(define (async-command cmd)
  "Запустить shell-команду в фоне"
  (set! *async-id-counter* (+ *async-id-counter* 1))
  (let ((id *async-id-counter*))
    (call-with-new-thread
     (lambda ()
       (system cmd)
       (set! *async-processes* (filter (lambda (x) (not (equal? x id))) *async-processes*))))
    (set! *async-processes* (cons id *async-processes*))
    (format #t "Async command ~a started: ~a\n" id cmd)
    id))

(define (async-list)
  "Показать все фоновые задачи"
  (if (null? *async-processes*)
      (display "No async jobs running.\n")
      (begin
        (display "=== Async Jobs ===\n")
        (for-each (lambda (id) (format #t "Job ~a\n" id)) *async-processes*))))

(define (async-kill id)
  "Убить фоновую задачу по ID (не всегда возможно в Guile)"
  (format #t "Cannot kill thread ~a in Guile portably.\n" id))

(define (async-kill-all)
  "Убить ВСЕ фоновые задачи"
  (set! *async-processes* '())
  (display "All async jobs cleared (but threads may still run).\n"))

(define (async-wait id)
  "Дождаться завершения задачи"
  (let loop ()
    (if (member id *async-processes*)
        (begin
          (sleep 0.1)
          (loop))
        (format #t "Async job ~a completed\n" id))))

;; ============================================================
;; Упрощённые алиасы
;; ============================================================
(define (bg cmd) (async-command cmd))
(define (jobs) (async-list))
(define (kill id) (async-kill id))

;; ============================================================
;; Приветствие
;; ============================================================
(display "\n⚡ Async process manager loaded\n")
(display "  (async (lambda () (firefox)))\n")
(display "  (async-command \"sleep 10\")\n")
(display "  (jobs) - list tasks\n")
(display "  (async-kill-all) - clear list\n")
