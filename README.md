# REPLOS - Living System Environment

**REPLOS** (REPL Operating System) is a living environment for Lisp hackers, where the REPL becomes an interface to the operating system. No difference between just a shell and a Scheme's define. No reboots. Just a living system that you can modify while you work.

# Philosophy

REPLOS is more than just a set of commands. It's an attempt to restore the paradigm that existed in the Lisp machines of the 1980s:

* **Unified syntax** — everything from navigation to package management is done using S-expressions.

* **A living system** — code changes without reboots or recompilations.

* **Introspection** — you see and can change any aspect of the system.

* **The REPL as a center** — not a "development environment," but a "habitat".

# Install

```bash
git clone https://github.com/lisper004/replos.git ~/.replos && cd ~/.replos
cp guile ~/
guile
```
**Done!~**

# Project structure
```text
~/.replos/
├── replos.scm          # Main file REPLOS
├── core/
│   ├── boot/
│   │   └── init.scm        # Loader
│   ├── autoload/           # Automatically loaded modules
│   │   ├── core.scm        # Base commands
│   │   ├── pkg.scm         # Package manager
│   │   └── *.scm           # Your modules
│   ├── bin/                # Compiled files (.go)
│   └── lib/                # Package sources (.lisp)
└── state.scm               # Saved session state
```

# Requirements

* Guile Scheme 3.0+

* Linux (should work on any POSIX platform)

Optional:

* Emacs (for (ed) - can be replaced with any editor)

* Curl or Wget (for (package-install) - can be replaced)

* guile-colorized for .guile config file (you can comment out the line)

* fibers for core/autoload/test-pipeline.scm (u can delete file from autoload)
 
# License

GPLv3 — free software, as Richard Stallman intended.

# Inspiration

* Lisp machines (Symbolics, Xerox PARC)

* Medley Interlisp

* Movitz

* Monolithic BSD systems

* Hackers from the song "Join us now and share the Free Software"

[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub stars](https://img.shields.io/github/stars/lisper004/replos?style=flat)](https://github.com/lisper004/replos/stargazers)
[![Language](https://img.shields.io/badge/language-Scheme-%230066cc.svg)](https://www.gnu.org/software/guile/)
[![Guile](https://img.shields.io/badge/Guile-3.0+-1793d1.svg)](https://www.gnu.org/software/guile/)
[![GNU](https://img.shields.io/badge/GNU-Project-red.svg)](https://www.gnu.org/)
