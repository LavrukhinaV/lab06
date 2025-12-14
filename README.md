# lab06
# Лабораторная работа № 6

**Автор:** *Лаврухина Виктория*

--- 
## Цель лабораторной работы
Данная лабораторная работа посвещена изучению аудита безопасности Docker при использовании Docker Bench Security.

---

### Структура репозитория лабораторной работы
```
lab06/
├── app/
│   └── app.py
│
├── backup/
│
├── config/
│   └── nginx.conf
│
├── db/
│   └── init.sql
│
├── audit.sh
│
├── docker-compose.yml
├── vulnerable-app.yml
├── vulnerable-app.macos.override.yml
│
├── audit_reports/
│   ├── json/
│   │   ├── docker-bench-security-trivy.json
│   │   ├── nginx-alpine-trivy.json
│   │   ├── python-3.11-alpine-trivy.json
│   │   └── postgres-16-alpine-trivy.json
│   │
│   ├── xlsx/
│   │   ├── docker-bench-security-trivy.xlsx
│   │   ├── nginx-alpine-trivy.xlsx
│   │   ├── python-3.11-alpine-trivy.xlsx
│   │   └── postgres-16-alpine-trivy.xlsx
│   │
│   ├── odt/
│   │   ├── docker-bench-security-trivy.odt
│   │   ├── nginx-alpine-trivy.odt
│   │   ├── python-3.11-alpine-trivy.odt
│   │   └── postgres-16-alpine-trivy.odt
│   │
│   └── text/
│
├── venv/
│
├── .gitignore
│
├── lab06.md
│
└── README.md
```
---

### Gist-отчет
https://gist.github.com/LavrukhinaV/c5dec5c8620e117b91092bb60d984a6c