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

### Задания

- ✔ 1. Поставьте `Docker` и `buildkit`

```bash
$ sudo apt-get update
$ sudo apt-get install -y docker.io
$ sudo usermod -aG docker "$USER"

$ sudo systemctl start docker
$ docker pull docker/docker-bench-security
```

- ✔ 2. Проверьте работу докера и сделать скрипт `audit.sh` исполняемым

- ✔ 3. Развернуть уязвимое приложение как отдельные стенды

```bash
$ docker compose up -d # основной web, app, postgres
$ docker-compose -f dvulnerable-app.yml up -d # поверх для vulnerable-web, debug-shell
    -f # file
    up # создает и поднимает файлы из compose
    -d # фоновый режим
```

- ✔ 4. Запустите скрипт из `venv` и проанализируйте то, что вывело на терминале и что вывело при конвертировании

```bash
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install openpyxl odfpy
$ ./audit.sh
$ deactivate # или $ deactivate 2>/dev/null || true
```
 
- ✔ 5. Проведите анализ уязвимостей, опишите их причину возникновения
- ✔ 6. Опишите влияния уязвимостей, их сценарий атаки
- ✔ 7. Оцените риски ИБ и предложите меры для их снижения: 
> - Следует разобрать `.yaml` описав, что в них считается не безопасным и почему
> - Опишите сценарии реализации рисков CR, DL
> - Предложили исправленные `.yaml`
- ✔ 8. Сделайте анализ уязвимостей из сгенерированных файлов .odt, .xslx и опишите их в отчете. Файлы конвертируются в эти директории

```bash
"├── json/          (Trivy JSON outputs)"
"├── text/          (CIS audit text outputs)"
"├── xlsx/          (Excel spreadsheets)"
"└── odt/           (OpenDocument Text files)"
```

- ✔ 9. Подготовьте отчет `gist`.
- ✔ 10. Почистите кеш от `venv` и остановите уязвимостей приложение, почистите контейнера

```bash
$ rm -rf venv
$ docker-compose -f demo-vulnerable-app.yml down
$ docker system prune -f
```
 
---

### Подготовительный этап (перед выполнением)

1. Создать директорию проекта и зайти в нее:
```
mkdir lab06
cd lab06
```

2. Инициализировать git и сделать первый коммит:
```
git init
echo "# lab06" > README.md
git add .
git commit -m "Initial commit"

```

3. Создать и переключиться на ветку dev
```
git checkout -b dev
```

4. Создать удалённый репозиторий на GitHub и привязать origin
```
gh repo create lab06 --private --source=. --remote=origin --push
```
---

### Процесс выполнения заданий
- ✔ 1. Поставьте `Docker` и `buildkit`
```bash
docker version # Проверка корректности установки docker
Client:
 Version:           28.0.1
 API version:       1.48
 Go version:        go1.23.6
 Git commit:        068a01e
 Built:             Wed Feb 26 10:38:16 2025
 OS/Arch:           darwin/arm64
 Context:           desktop-linux

Server: Docker Desktop 4.39.0 (184744)
 Engine:
  Version:          28.0.1
  API version:      1.48 (minimum version 1.24)
  Go version:       go1.23.6
  Git commit:       bbd0a17
  Built:            Wed Feb 26 10:40:57 2025
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          1.7.25
  GitCommit:        bcc810d6b9066471b0b6fa75f557a15a1cbf31bb
 runc:
  Version:          1.2.4
  GitCommit:        v1.2.4-0-g6c52b3f
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

buildkit version # Проверка корректности установки buildkit
buildctl github.com/moby/buildkit 0.26.2 be1f38efe73c6a93cc429a0488ad6e1db663398c
```

- ✔ 2. Проверьте работу докера и сделать скрипт `audit.sh` исполняемым
```bash
brew install trivy # установить trivy
✔︎ JSON API formula.jws.json                                                                                                           [Downloaded   32.2MB/ 32.2MB]
✔︎ JSON API cask.jws.json                                                                                                              [Downloaded   15.1MB/ 15.1MB]
==> Fetching downloads for: trivy
✔︎ Bottle Manifest trivy (0.68.1)                                                                                                      [Downloaded    7.5KB/  7.5KB]
✔︎ Bottle trivy (0.68.1)                                                                                                               [Downloaded   59.0MB/ 59.0MB]
==> Pouring trivy--0.68.1.sonoma.bottle.tar.gz
🍺  /usr/local/Cellar/trivy/0.68.1: 16 files, 212.6MB
==> Running `brew cleanup trivy`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
==> Caveats
zsh completions have been installed to:
  /usr/local/share/zsh/site-functions
```
```bash
chmod +x audit.sh # Сделать audit.sh исполняемым
./audit.sh # запустить
Starting Docker CIS & Image Security Audit
==========================================
Detected platform: macOS
Using docker-bench-security image: docker/docker-bench-security:latest
Reports will be saved to: ./audit_reports/

Running Trivy scan for docker/docker-bench-security:latest...
2025-12-14T10:02:54+03:00	INFO	[vulndb] Need to update DB
2025-12-14T10:02:54+03:00	INFO	[vulndb] Downloading vulnerability DB...
2025-12-14T10:02:54+03:00	INFO	[vulndb] Downloading artifact...	repo="mirror.gcr.io/aquasec/trivy-db:2"
77.82 MiB / 77.82 MiB [------------------------------------------------------------------------------------------------------------------] 100.00% 1.44 MiB p/s 54s
2025-12-14T10:03:50+03:00	INFO	[vulndb] Artifact successfully downloaded	repo="mirror.gcr.io/aquasec/trivy-db:2"
2025-12-14T10:03:50+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:03:50+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:03:50+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:03:50+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:03:51+03:00	INFO	Detected OS	family="alpine" version="3.8.2"
2025-12-14T10:03:51+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.8" repository="3.8" pkg_num=25
2025-12-14T10:03:51+03:00	INFO	Number of language-specific files	num=0
2025-12-14T10:03:51+03:00	WARN	This OS version is no longer supported by the distribution	family="alpine" version="3.8.2"
2025-12-14T10:03:51+03:00	WARN	The vulnerability detection may be insufficient because security updates are not provided
Saved to: ./audit_reports/json/docker-bench-security-trivy.json

Scanning lab images for vulnerabilities...

=== Trivy scan for nginx:alpine ===
2025-12-14T10:03:51+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:03:51+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:03:51+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:03:51+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:03:58+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:03:58+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:03:58+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=71
2025-12-14T10:03:58+03:00	INFO	Number of language-specific files	num=0
2025-12-14T10:03:58+03:00	WARN	Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.68/guide/scanner/vulnerability#severity-selection for details.
Saved to: ./audit_reports/json/nginx-alpine-trivy.json

=== Trivy scan for python:3.11-alpine ===
2025-12-14T10:03:58+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:03:58+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:03:58+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:03:58+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:04:03+03:00	INFO	[python] Licenses acquired from one or more METADATA files may be subject to additional terms. Use `--debug` flag to see all affected packages.
2025-12-14T10:04:03+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:04:03+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:04:03+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=38
2025-12-14T10:04:03+03:00	INFO	Number of language-specific files	num=1
2025-12-14T10:04:03+03:00	INFO	[python-pkg] Detecting vulnerabilities...
Saved to: ./audit_reports/json/python-3.11-alpine-trivy.json

=== Trivy scan for postgres:16-alpine ===
2025-12-14T10:04:04+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:04:04+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:04:04+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:04:04+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:04:17+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:04:17+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:04:17+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=45
2025-12-14T10:04:17+03:00	INFO	Number of language-specific files	num=1
2025-12-14T10:04:17+03:00	INFO	[gobinary] Detecting vulnerabilities...
2025-12-14T10:04:17+03:00	WARN	Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.68/guide/scanner/vulnerability#severity-selection for details.
Saved to: ./audit_reports/json/postgres-16-alpine-trivy.json

macOS detected – Docker Desktop (Apple Silicon) environment
Due to Docker Desktop limitations, docker-bench-security may fail to start CIS host audit.
Use the Trivy image scans above for lab purposes and run full CIS Docker Benchmark on a Linux VM/WSL host.


Converting Trivy JSON reports to XLSX/ODT formats...
WARNING: openpyxl or odfpy not installed. Skipping XLSX/ODT conversion.
Install with: pip install openpyxl odfpy

==========================================
Audit complete!
Reports directory structure:
   ./audit_reports/
   ├── json/          (Trivy JSON outputs)
   ├── text/          (CIS audit text outputs)
   ├── xlsx/          (Excel spreadsheets)
   └── odt/           (OpenDocument Text files)

For CIS Docker Benchmark details, see:
https://www.cisecurity.org/benchmark/docker
```
**Результат:** Trivy сформировал JSON-отчёты в `audit_reports/json`
- ✔ 3. Развернуть уязвимое приложение как отдельные стенды
**Основной стенд**
```bash
lab06$ docker compose -p lab06-main down
docker compose -p lab06-main up -d # поднять основной стэнд

[+] Running 4/4
 ✔ Container vulnerable-nginx  Removed                                                                                                                        0.0s 
 ✔ Container vulnerable-app    Removed                                                                                                                        0.0s 
 ✔ Container insecure-db       Removed                                                                                                                        0.0s 
 ✔ Network lab06-main_default  Removed                                                                                                                        0.2s 
WARN[0000] /Users/aleksandrlavruhin/phystech/AppSec/lab06/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 4/4
 ✔ Network lab06-main_default  Created                                                                                                                        0.0s 
 ✔ Container insecure-db       Started                                                                                                                        0.1s 
 ✔ Container vulnerable-app    Started                                                                                                                        0.2s 
 ✔ Container vulnerable-nginx  Started   
```
```bash
docker compose -p lab06-main ps # статус серверов
NAME               IMAGE                COMMAND                  SERVICE          CREATED              STATUS              PORTS
insecure-db        postgres:16-alpine   "docker-entrypoint.s…"   insecure-db      3 minutes ago        Up 3 minutes        5432/tcp
vulnerable-app     python:3.11-alpine   "sh -c 'pip install …"   app              3 minutes ago        Up 2 minutes        0.0.0.0:5001->5000/tcp
vulnerable-nginx   nginx:alpine         "/docker-entrypoint.…"   vulnerable-web   About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp
```
```bash
curl -i http://localhost:8080/ # статус доступности
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sun, 14 Dec 2025 07:24:42 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 30
Connection: keep-alive

OK: vulnerable-app is running
``` 
**Результат:**
* Все сервисы в состоянии Up
* Проброшенный порт 8080 → 80
* HTTP-ответ 200 OK

**Уязвимый стенд**
```bash
docker compose -p lab06-vuln \
  -f vulnerable-app.yml \
  -f vulnerable-app.macos.override.yml \
  up -d

docker compose -p lab06-vuln \
  -f vulnerable-app.yml \
  -f vulnerable-app.macos.override.yml \
  ps

WARN[0000] /Users/aleksandrlavruhin/phystech/AppSec/lab06/vulnerable-app.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 2/2
 ✔ Container vulnerable-web  Running                                                                                                                          0.0s 
 ✔ Container debug-shell     Running                                                                                                                          0.0s 
WARN[0000] /Users/aleksandrlavruhin/phystech/AppSec/lab06/vulnerable-app.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
NAME             IMAGE           COMMAND                  SERVICE          CREATED         STATUS         PORTS
debug-shell      alpine:latest   "/bin/sh -c 'apk add…"   debug-shell      6 minutes ago   Up 6 minutes   0.0.0.0:2222->22/tcp
vulnerable-web   nginx:latest    "/docker-entrypoint.…"   vulnerable-web   8 minutes ago   Up 8 minutes   
```
**Результат:**
* Контейнеры vulnerable-web и debug-shell в состоянии Up

**Вывод по заданию 3:**
В рамках задания 3 были развёрнуты два изолированных стенда Docker Compose:

Основной стенд (lab06-main) включает сервисы `nginx`, `python-приложение` и `postgres` и развёрнут с применением базовых мер безопасности:

* отказ от privileged-режима,

* отсутствие проброса порта базы данных наружу,

* запуск веб-приложения за nginx,

* использование внутренней Docker-сети.

Доступность стенда подтверждена HTTP-запросом к `http://localhost:8080`, который возвращает код `200 OK`.

Уязвимый стенд (lab06-vuln) развёрнут отдельно и содержит намеренно небезопасные конфигурации:

* запуск контейнеров в `privileged`-режиме,

* монтирование корневой файловой системы хоста и `docker.sock`,

* отключённые профили безопасности (`seccomp`, `apparmor`),

* использование секретов в переменных окружения,

* запуск SSH-сервера под пользователем `root`.

Для корректной работы на macOS параметры, специфичные для Linux (`network_mode: host, pid: host`, проброс порта 22), были вынесены в override-файл, что позволило сохранить уязвимости, но обеспечить запуск контейнеров в среде Docker Desktop.

- ✔ 4. Запустите скрипт из `venv` и проанализируйте то, что вывело на терминале и что вывело при конвертировании

```bash
lab06$ python3 -m venv venv # Создание виртуального окружения Python
source venv/bin/activate # Активация виртуального окружения Python
pip install openpyxl odfpy # Установка зависимостей
./audit.sh # Запуск аудита
deactivate # деактивация окружения

Collecting openpyxl
  Using cached openpyxl-3.1.5-py2.py3-none-any.whl.metadata (2.5 kB)
Collecting odfpy
  Downloading odfpy-1.4.1.tar.gz (717 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 717.0/717.0 kB 6.4 MB/s eta 0:00:00
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Collecting et-xmlfile (from openpyxl)
  Using cached et_xmlfile-2.0.0-py3-none-any.whl.metadata (2.7 kB)
Collecting defusedxml (from odfpy)
  Downloading defusedxml-0.7.1-py2.py3-none-any.whl.metadata (32 kB)
Using cached openpyxl-3.1.5-py2.py3-none-any.whl (250 kB)
Downloading defusedxml-0.7.1-py2.py3-none-any.whl (25 kB)
Using cached et_xmlfile-2.0.0-py3-none-any.whl (18 kB)
Building wheels for collected packages: odfpy
  Building wheel for odfpy (pyproject.toml) ... done
  Created wheel for odfpy: filename=odfpy-1.4.1-py2.py3-none-any.whl size=137364 sha256=df84939e153b6bf1e34af351ca8458193040a22ae78f5849ede25c0d6add0290
  Stored in directory: /Users/aleksandrlavruhin/Library/Caches/pip/wheels/36/5d/63/8243a7ee78fff0f944d638fd0e66d7278888f5e2285d7346b6
Successfully built odfpy
Installing collected packages: et-xmlfile, defusedxml, openpyxl, odfpy
Successfully installed defusedxml-0.7.1 et-xmlfile-2.0.0 odfpy-1.4.1 openpyxl-3.1.5

[notice] A new release of pip is available: 24.2 -> 25.3
[notice] To update, run: pip install --upgrade pip
Starting Docker CIS & Image Security Audit
==========================================
Detected platform: macOS
Using docker-bench-security image: docker/docker-bench-security:latest
Reports will be saved to: ./audit_reports/

Running Trivy scan for docker/docker-bench-security:latest...
2025-12-14T10:51:58+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:51:58+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:51:58+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:51:58+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:51:58+03:00	INFO	Detected OS	family="alpine" version="3.8.2"
2025-12-14T10:51:58+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.8" repository="3.8" pkg_num=25
2025-12-14T10:51:58+03:00	INFO	Number of language-specific files	num=0
2025-12-14T10:51:58+03:00	WARN	This OS version is no longer supported by the distribution	family="alpine" version="3.8.2"
2025-12-14T10:51:58+03:00	WARN	The vulnerability detection may be insufficient because security updates are not provided
Saved to: ./audit_reports/json/docker-bench-security-trivy.json

Scanning lab images for vulnerabilities...

=== Trivy scan for nginx:alpine ===
2025-12-14T10:51:58+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:51:58+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:51:58+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:51:58+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:51:59+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:51:59+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:51:59+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=71
2025-12-14T10:51:59+03:00	INFO	Number of language-specific files	num=0
2025-12-14T10:51:59+03:00	WARN	Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.68/guide/scanner/vulnerability#severity-selection for details.
Saved to: ./audit_reports/json/nginx-alpine-trivy.json

=== Trivy scan for python:3.11-alpine ===
2025-12-14T10:51:59+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:51:59+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:51:59+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:51:59+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:52:00+03:00	INFO	[python] Licenses acquired from one or more METADATA files may be subject to additional terms. Use `--debug` flag to see all affected packages.
2025-12-14T10:52:00+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:52:00+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:52:00+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=38
2025-12-14T10:52:00+03:00	INFO	Number of language-specific files	num=1
2025-12-14T10:52:00+03:00	INFO	[python-pkg] Detecting vulnerabilities...
Saved to: ./audit_reports/json/python-3.11-alpine-trivy.json

=== Trivy scan for postgres:16-alpine ===
2025-12-14T10:52:00+03:00	INFO	[vuln] Vulnerability scanning is enabled
2025-12-14T10:52:00+03:00	INFO	[secret] Secret scanning is enabled
2025-12-14T10:52:00+03:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-12-14T10:52:00+03:00	INFO	[secret] Please see https://trivy.dev/docs/v0.68/guide/scanner/secret#recommendation for faster secret detection
2025-12-14T10:52:02+03:00	INFO	Detected OS	family="alpine" version="3.23.0"
2025-12-14T10:52:02+03:00	WARN	This OS version is not on the EOL list	family="alpine" version="3.23"
2025-12-14T10:52:02+03:00	INFO	[alpine] Detecting vulnerabilities...	os_version="3.23" repository="3.23" pkg_num=45
2025-12-14T10:52:02+03:00	INFO	Number of language-specific files	num=1
2025-12-14T10:52:02+03:00	INFO	[gobinary] Detecting vulnerabilities...
2025-12-14T10:52:02+03:00	WARN	Using severities from other vendors for some vulnerabilities. Read https://trivy.dev/docs/v0.68/guide/scanner/vulnerability#severity-selection for details.
Saved to: ./audit_reports/json/postgres-16-alpine-trivy.json

macOS detected – Docker Desktop (Apple Silicon) environment
Due to Docker Desktop limitations, docker-bench-security may fail to start CIS host audit.
Use the Trivy image scans above for lab purposes and run full CIS Docker Benchmark on a Linux VM/WSL host.


Converting Trivy JSON reports to XLSX/ODT formats...
✓ Saved to XLSX: ./audit_reports/xlsx/postgres-16-alpine-trivy.xlsx
✓ Saved to ODT: ./audit_reports/odt/postgres-16-alpine-trivy.odt
✓ Saved to XLSX: ./audit_reports/xlsx/nginx-alpine-trivy.xlsx
✓ Saved to ODT: ./audit_reports/odt/nginx-alpine-trivy.odt
✓ Saved to XLSX: ./audit_reports/xlsx/python-3.11-alpine-trivy.xlsx
✓ Saved to ODT: ./audit_reports/odt/python-3.11-alpine-trivy.odt
✓ Saved to XLSX: ./audit_reports/xlsx/docker-bench-security-trivy.xlsx
✓ Saved to ODT: ./audit_reports/odt/docker-bench-security-trivy.odt

==========================================
Audit complete!
Reports directory structure:
   ./audit_reports/
   ├── json/          (Trivy JSON outputs)
   ├── text/          (CIS audit text outputs)
   ├── xlsx/          (Excel spreadsheets)
   └── odt/           (OpenDocument Text files)

For CIS Docker Benchmark details, see:
https://www.cisecurity.org/benchmark/docker
```

- ✔ 5. Проведите анализ уязвимостей, опишите их причину возникновения
Анализ уязвимостей выполнен на основе:
    * вывода утилиты Trivy при запуске скрипта `audit.sh`;
    * конфигурационных файлов `docker-compose.yml` и `vulnerable-app.yml`.

**Уязвимости, связанные с базовыми образами контейнеров** - использование устаревших и неподдерживаемых версий базовых образов контейнеров (Alpine Linux).
```text
Detected OS family="alpine" version="3.8.2"
WARN This OS version is no longer supported by the distribution
WARN The vulnerability detection may be insufficient because security updates are not provided
```

**Уязвимости, связанные с зависимостями приложений** - наличие уязвимостей в сторонних библиотеках и зависимостях приложений (Python-пакеты и системные библиотеки).
```text
INFO [python-pkg] Detecting vulnerabilities...
WARN Using severities from other vendors for some vulnerabilities
INFO Number of language-specific files num=1
```

**Критические уязвимости конфигурации контейнеров** - контейнеры в уязвимом стенде запущены с избыточными привилегиями и отключёнными механизмами безопасности.
```yaml
privileged: true
cap_add:
  - ALL
network_mode: host
pid: host
security_opt:
  - apparmor:unconfined
  - seccomp:unconfined
volumes:
  - /:/hostroot:rw
  - /var/run/docker.sock:/var/run/docker.sock
user: "0:0"
```

**Уязвимости, связанные с управлением секретами** - преднамеренное нарушение рекомендаций CIS Docker Benchmark и использование небезопасных конфигураций контейнеров для демонстрации анти-паттернов безопасности.
```yaml
environment:
  - ADMIN_USERNAME=admin
  - ADMIN_PASSWORD=admin123
  - DB_USER=root
  - DB_PASSWORD=root
  - FLAG=FLAG{HARDCODED_SECRET_IN_ENV}
```

- ✔ 6. Опишите влияния уязвимостей, их сценарий атаки
Анализ влияния уязвимостей выполнен на основе конфигураций `docker-compose.yml` и `vulnerable-app.yml`, а также результатов сканирования `Trivy`.

**1. Уязвимость:  запуск контейнеров в privileged-режиме**
**Влияние:** контейнер получает почти неограниченный доступ к возможностям ядра хост-системы, что фактически устраняет изоляцию между контейнером и хостом.
**Сценарий атаки:**
1. Атакующий получает доступ к процессу внутри контейнера (через RCE, SSH или уязвимость приложения).
2. Используя расширенные capabilities, выполняет системные вызовы хоста.
3. Получает контроль над хост-системой и всеми контейнерами.

**2. Влияние монтирования файловой системы хоста** - контейнер получает доступ на чтение и запись ко всей файловой системе хоста.
**Сценарий атаки:**
1. Атакующий получает доступ к контейнеру debug-shell.
2. Читает файлы хоста через `/hostroot`.
3. Извлекает конфигурационные файлы, ключи, базы данных, пользовательские данные.
**Результат:** утечка конфиденциальной информации и персональных данных.

**3. Влияние монтирования docker.sock** - контейнер может управлять Docker-демоном хоста.
**Сценарий атаки:**
1. Атакующий запускает новый контейнер с флагами `--privileged`.
2. Монтирует файловую систему хоста.
3. Получает полный контроль над системой.
**Результат:** компрометация всей Docker-инфраструктуры.

**4. Влияние небезопасного управления секретами**
**Сценарий атаки:**
1. Атакующий получает доступ к контейнеру.
2. Считывает переменные окружения.
3. Использует полученные учётные данные для доступа к БД.
**Результат:** утечка данных и компрометация БД.

- ✔ 7. Оцените риски ИБ и предложите меры для их снижения: 

**Анализ .yaml: что небезопасно и почему:**
`privileged: true` - Снимает изоляцию контейнера
`cap_add: ALL` - Расширяет поверхность атаки
`network_mode: host` - Отсутствует сетевая изоляция
`pid: host` - Доступ к процессам хоста
`seccomp: unconfined` - Нет фильтрации syscalls
`apparmor: unconfined` - Отключена LSM-защита
`/ смонтирован` - Полный доступ к хосту
`docker.sock` - Управление Docker
`Secrets в env` - Утечки данных
`SSH + root` - Brute-force, lateral movement

**Сценарии реализации рисков:**
**Комбинация:** `privileged + docker.sock + root`- компрометация одного контейнера → полный контроль над хостом → компрометация всех сервисов.
**Комбинация:** `/:/hostroot + secrets в env` - доступ к контейнеру → чтение файлов хоста и env → утечка БД и конфигураций.

**Предложенные меры по снижению рисков**
* Запрет privileged-режима
* Минимизация capabilities
* Изоляция сети
* Запуск от non-root
* Использование read-only FS
* Управление секретами через Vault / Docker Secrets
* Обновление базовых образов
* Включение seccomp, apparmor

**Исправленный docker-compose.yml**
```yml
services:
  web:
    image: nginx:alpine
    user: nginx
    ports:
      - "8080:80"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    volumes:
      - ./config/nginx.conf:/etc/nginx/nginx.conf:ro
...
  app:
    image: python:3.11-alpine
    user: "1000:1000"
    read_only: true
    cap_drop:
      - ALL
    environment:
      - DB_HOST=insecure-db
    secrets:
      - db_password
```
- ✔ 8. Сделайте анализ уязвимостей из сгенерированных файлов .odt, .xslx и опишите их в отчете. Файлы конвертируются в эти директории
Анализ уязвимостей выполнен на основе автоматически сгенерированных отчётов Trivy, конвертированных в форматы XLSX:
* `audit_reports/xlsx/docker-bench-security-trivy.xlsx`
* `audit_reports/xlsx/nginx-alpine-trivy.xlsx`
* `audit_reports/xlsx/python-3.11-alpine-trivy.xlsx`
* `audit_reports/xlsx/postgres-16-alpine-trivy.xlsx`

Во всех `.xlsx` файлах уязвимости представлены со следующими полями:
* Target — компонент или слой образа
* Type — тип проверки (OS packages / application dependencies / misconfiguration)
* Vulnerability ID — идентификатор уязвимости (CVE или internal ID)
* Severity — уровень критичности (LOW / MEDIUM / HIGH / CRITICAL)
* Title / Description — краткое описание уязвимости

**Анализ docker-bench-security-trivy.xlsx**
В отчёте присутствуют уязвимости CVE-2019-9893 и CVE-2019-14697, связанные с:
* устаревшей версией Alpine Linux.
* Зафиксированы уязвимости уровня MEDIUM / HIGH в системных библиотеках.
* Отмечено использование Alpine Linux версии 3.8, для которой прекращена поддержка безопасности.

**nginx-alpine-trivy.xlsx**
* CVE-2025-62408 — уязвимость в библиотеке c-ares, которая используется для асинхронного DNS-резолвинга.
* Уязвимость позволяет вызвать отказ в обслуживании за счёт некорректной обработки DNS-запросов. В
* Уязвимость имеет статус fixed, что указывает на необходимость регулярного обновления базовых образов для устранения подобных рисков. 

**python-3.11-alpine-trivy.xlsx**
* CVE-2025-8869 — уязвимость в менеджере пакетов pip, связанная с некорректной обработкой символических ссылок при извлечении tar-архивов.
* Эксплуатация уязвимости может привести к записи файлов за пределами каталога установки и нарушению целостности контейнера.
* Уязвимость имеет статус fixed и устраняется обновлением pip и используемых зависимостей.

**postgres-16-alpine-trivy.xlsx**
* CVE-2025-58183 — Отсутствие ограничения на количество sparse-блоков в tar-архиве.
* CVE-2025-58186 - Отсутствие лимита на количество cookies при парсинге HTTP-заголовков.
* CVE-2025-58187 - Алгоритм проверки name constraints имеет нелинейную сложность.
* CVE-2025-61729 - тсутствие лимитов при формировании сообщений об ошибках сертификатов.
* Выявлен ряд уязвимостей средней критичности.
* Основной риск заключается в возможности отказа в обслуживании (DoS). 
* Все уязвимости имеют статус fixed и устраняются обновлением базового Docker-образа и используемых библиотек.

- ✔ 9. Подготовьте отчет `gist`.
```bash
gh gist create lab06.md --public --desc "lab06 report"
```

- ✔ 10. Почистите кеш от `venv` и остановите уязвимостей приложение, почистите контейнера
```bash
docker compose -p lab06-main down # Остановить и удалить основной стенд

docker compose -p lab06-vuln -f vulnerable-app.yml -f vulnerable-app.macos.override.yml down # Остановить и удалить уязвимый стенд

docker container prune -f # Очистка остановленных контейнеров, сетей и кеша Docker
docker network prune -f
docker image prune -f

deactivate 2>/dev/null || true # Удаление виртуального окружения Python
rm -rf venv
```