(use-modules (ice-9 regex)
             (ice-9 rdelim))

(define (run-cmd cmd)
  (let* ((port (open-input-pipe cmd))
         (output (read-string port))
         (status (close-pipe port)))
    (values output (zero? status))))

(define (run-cmd-display cmd)
  (system cmd))

(define (get-user-input prompt)
  (display prompt)
  (flush-all-ports)
  (string-trim-both (read-line)))

(define (yes-no? prompt)
  (let ((answer (get-user-input (string-append prompt " (y/n): "))))
    (or (string=? answer "y")
        (string=? answer "yes")
        (string=? answer "Y"))))

(define (ping host . args)
  (let ((cmd (string-append "ping " (string-join args " ") " " host)))
    (run-cmd-display cmd)))

(define (ping-loop host)
  (ping host "-i" "1"))

(define (wifi-list)
  (display ">> Scanning for networks...\n")
  (run-cmd-display "sudo iwctl station wlan0 scan")
  (sleep 2)
  (run-cmd-display "sudo iwctl station wlan0 get-networks"))

(define (wifi-connect ssid . password)
  (if (null? password)
      (begin
        (display ">> Open network detected.\n")
        (run-cmd-display (string-append "sudo iwctl station wlan0 connect \"" ssid "\"")))
      (begin
        (display ">> Connecting to secured network...\n")
        (run-cmd-display (string-append "sudo iwctl station wlan0 connect \"" ssid "\" --passphrase \"" (car password) "\"")))))

(define (wifi-status)
  (run-cmd-display "sudo iwctl station wlan0 show"))

(define (wifi-disconnect)
  (run-cmd-display "sudo iwctl station wlan0 disconnect"))

(define (ip-addr)
  (run-cmd-display "ip addr"))

(define (ip-link)
  (run-cmd-display "ip link"))

(define (netstat)
  (run-cmd-display "ss -tulpn"))

(define (user-list)
  (run-cmd-display "cut -d: -f1 /etc/passwd"))

(define (user-add username . groups)
  (let ((group-args (if (null? groups)
                        ""
                        (string-append " -G " (string-join groups ",")))))
    (run-cmd-display (string-append "sudo useradd -m -s /bin/guile" group-args " " username))
    (display (string-append ">> User " username " created.\n"))
    (display ">> Set password: ")
    (run-cmd-display (string-append "sudo passwd " username))))

(define (user-remove username)
  (if (yes-no? (string-append ">> Delete user " username "?"))
      (begin
        (run-cmd-display (string-append "sudo userdel -r " username))
        (display ">> User deleted.\n"))
      (display ">> Aborted.\n")))

(define (user-passwd username)
  (run-cmd-display (string-append "sudo passwd " username)))

(define (system-hostname . name)
  (if (null? name)
      (run-cmd-display "hostname")
      (let ((new-name (car name)))
        (run-cmd-display (string-append "sudo hostnamectl set-hostname " new-name))
        (display (string-append ">> Hostname set to: " new-name "\n")))))

(define (system-locale . locale)
  (if (null? locale)
      (run-cmd-display "localectl status")
      (let ((new-locale (car locale)))
        (run-cmd-display (string-append "sudo localectl set-locale LANG=" new-locale))
        (display (string-append ">> Locale set to: " new-locale "\n"))
        (display ">> Reboot to apply changes.\n"))))

(define (system-timezone . zone)
  (if (null? zone)
      (run-cmd-display "timedatectl show --property=Timezone --value")
      (let ((new-zone (car zone)))
        (run-cmd-display (string-append "sudo timedatectl set-timezone " new-zone))
        (display (string-append ">> Timezone set to: " new-zone "\n")))))

(define (system-date)
  (run-cmd-display "date"))

(define (sv-list)
  (run-cmd-display "systemctl list-units --type=service --state=running"))

(define (sv-start name)
  (run-cmd-display (string-append "sudo systemctl start " name)))

(define (sv-stop name)
  (run-cmd-display (string-append "sudo systemctl stop " name)))

(define (sv-restart name)
  (run-cmd-display (string-append "sudo systemctl restart " name)))

(define (sv-enable name)
  (run-cmd-display (string-append "sudo systemctl enable " name)))

(define (sv-disable name)
  (run-cmd-display (string-append "sudo systemctl disable " name)))

(define (ps . args)
  (if (null? args)
      (run-cmd-display "ps aux")
      (run-cmd-display (string-append "ps " (car args)))))

(define (kill pid)
  (run-cmd-display (string-append "sudo kill " (number->string pid))))

(define (kill-force pid)
  (run-cmd-display (string-append "sudo kill -9 " (number->string pid))))

(define (pidof name)
  (run-cmd-display (string-append "pidof " name)))
