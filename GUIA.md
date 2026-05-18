# GUÍA COMPLETA PARA NOVATOS — Caso D: Programador de tareas (Dkron) en AWS

> **Esta guía es para alguien que NUNCA ha hecho DevOps.** Te llevará desde "no entiendo nada" hasta entregar el Caso D completo. **Cada paso parte de una pregunta**, te muestra cómo te vas a equivocar (porque te vas a equivocar) y cómo se resuelve cada error. **Equivocarse es parte del aprendizaje** — el reporte final se enriquece con esos errores reales.
>
> **Regla de oro del bootcamp (sección 7 del PDF):** El **REPORTE.md** se escribe SIN ayuda de IA generativa. Esta guía sí puede ayudarte a **entender** y **escribir el código**, pero las palabras del reporte deben ser tuyas. Si copias y pegas, te califican con cero.
>
> **Cómo usar esta guía:** léela en orden. No saltes secciones. Si un comando falla, busca en la sección "errores típicos" del bloque actual antes de googlear. Vas a tardar **4-6 semanas** trabajando 2-3 horas al día. Eso es normal.

---

## ÍNDICE

> 📖 **Orden de lectura recomendado** (no es el orden numérico — los números son IDs estables de capítulo).
> La filosofía es **hands-on primero, teoría después**: copy-paste local antes de los conceptos.

### 🏠 Fase preparación (motivación + setup local)
- [PARTE -1 — Lee esto si tienes miedo a empezar (la parte humana)](#parte--1)
- [PARTE 0 — Antes de tocar nada: instalar herramientas](#parte-0)
- [PARTE 3 — Tu primer día con Docker: levantar Dkron LOCAL](#parte-3) ⬅ **arranca aquí con copy-paste**

### 📚 Fase teórica (ya con manos sucias)
- [PARTE 1 — Entender qué pide el Caso D](#parte-1)
- [PARTE 2 — Conceptos que necesitas dominar (incluye Ansible)](#parte-2)

### ☁️ Fase producción AWS (infra + CI/CD + Ansible)
- [PARTE 4 — Configurar AWS y la base del repositorio (`infra/bootstrap.sh`)](#parte-4)
- [PARTE 5 — Construir la infraestructura con Terraform (6 módulos en `infra/modules/`)](#parte-5)
- [PARTE 6 — Configurar la EC2 con Ansible](#parte-6)
- [PARTE 7 — Pipeline CI/CD con GitHub Actions (`infra/bootstrap-oidc.sh`)](#parte-7)
- [PARTE 8 — Observabilidad: dashboards, SLOs y alertas (módulo `monitoring`)](#parte-8)

### 📝 Fase entrega (decisiones, runbook, reporte)
- [PARTE 9 — Responder las 5 preguntas de decisión técnica del Caso D](#parte-9)
- [PARTE 10 — Runbook, README y REPORTE](#parte-10)
- [PARTE 11 — Errores reales encontrados en producción (sesión de debug 2026-05-17)](#parte-11)
- [PARTE 12 — Cierre, destrucción y costo cero](#parte-12)
- [PARTE 13 — Cronograma sugerido de 6 semanas](#parte-13)
- [PARTE 14 — Tabla maestra de errores más comunes](#parte-14)
- [APÉNDICE A — Bitácora de errores ("yo me equivoqué así")](#apendice-a)
- [APÉNDICE B — Glosario rápido (incluye términos Ansible)](#apendice-b)

---

<a id="parte--1"></a>
# PARTE -1 — Lee esto si tienes miedo a empezar (la parte humana)

> Esta parte no tiene código. Léela igual. Es la más importante.

## ❓ -1.1 ¿Por qué llevo días postergando este proyecto?

Si abriste el PDF, viste palabras como "Terraform", "ECS Fargate", "Prometheus", "OIDC", "SLO" y se te encogió el estómago, **eso es normal**. No estás mal, no eres "menos inteligente". Lo que ves es esto:

```
        Lo que SIENTES                              Lo que en REALIDAD pasa
   ┌────────────────────────┐                  ┌─────────────────────────┐
   │                        │                  │                         │
   │   "tengo que aprender  │                  │   El proyecto se hace   │
   │   TODO esto antes de   │                  │   en pasitos pequeños   │
   │   empezar"             │                  │                         │
   │                        │                  │   Cada paso es 1 cosa   │
   │   ⚠️  ⚠️  ⚠️  ⚠️  ⚠️    │                  │                         │
   │   ⚠️  ⚠️  ⚠️  ⚠️  ⚠️    │                  │   ✓ → ✓ → ✓ → ✓ → ✓     │
   │   ⚠️  PARALIZADO  ⚠️    │       VS         │                         │
   │   ⚠️  ⚠️  ⚠️  ⚠️  ⚠️    │                  │   No tienes que saber   │
   │   ⚠️  ⚠️  ⚠️  ⚠️  ⚠️    │                  │   todo a la vez. Solo   │
   │                        │                  │   el siguiente paso.    │
   │   "voy a esperar a     │                  │                         │
   │    sentirme listo"     │                  │   El "listo" no llega.  │
   │                        │                  │   Empezar te hace listo.│
   └────────────────────────┘                  └─────────────────────────┘
```

**El miedo a equivocarse es lo que más te va a costar el bootcamp** — más que Terraform, más que AWS. Porque mientras pospones, los días pasan.

## ❓ -1.2 ¿Y si rompo algo? ¿Y si gasto plata?

Vamos a desactivar ese miedo con datos concretos:

```
┌──────────────────────────────────────────────────────────────────────┐
│  MITO                            │  REALIDAD                          │
├──────────────────────────────────┼────────────────────────────────────┤
│  "voy a romper AWS"              │  No puedes. Trabajas en TU cuenta. │
│                                  │  Solo afectas tu propia infra.     │
├──────────────────────────────────┼────────────────────────────────────┤
│  "me van a cobrar miles"         │  Budget alert a $10. Si te pasas,  │
│                                  │  email automático. Free tier cubre │
│                                  │  el 80%. Costo real esperado: <$5. │
├──────────────────────────────────┼────────────────────────────────────┤
│  "si me equivoco, perdí días"    │  terraform destroy + apply de nuevo│
│                                  │  = 15 min. La infra es desechable. │
├──────────────────────────────────┼────────────────────────────────────┤
│  "los demás saben más que yo"    │  Todos empezaron sin saber. Tu     │
│                                  │  ventaja es que sabes que no sabes.│
├──────────────────────────────────┼────────────────────────────────────┤
│  "tengo que entenderlo todo      │  Aprendes haciendo. La teoría sin  │
│   antes de tocar"                │  práctica se olvida en 48 horas.   │
└──────────────────────────────────┴────────────────────────────────────┘
```

**Equivocarse en este proyecto es GRATIS.** El error no te cuesta dinero, no daña a nadie, no te baja la nota — al contrario: la sección C del reporte (45% de la nota) **te pide 3-5 problemas reales con su solución**. Si nunca te equivocas, no tienes nada que escribir ahí.

## ❓ -1.3 ¿Cómo desbloqueo la parálisis HOY mismo?

Usa esta técnica de "el primer pasito":

```
┌──────────────────────────────────────────────────────────────────────┐
│              EL ANTÍDOTO CONTRA LA PROCRASTINACIÓN                   │
│                                                                      │
│  Promesa: dedicas SOLO 25 minutos. Después puedes parar sin culpa.   │
│                                                                      │
│   Min 0:        Abre la terminal. Eso es todo.                       │
│   Min 1:        Crea la carpeta:    mkdir ~/proyectos/dkron-aws      │
│   Min 2-5:      Instala UNA cosa de la tabla 0.4 (ej: Docker).       │
│   Min 6-15:     Instala otra cosa.                                   │
│   Min 16-25:    Configura aws configure (Pregunta 4.1).              │
│                                                                      │
│   Resultado:    Has empezado. La inercia se rompió.                  │
│                                                                      │
│  Mañana repites. 25 minutos diarios = 12.5 horas/semana = suficiente.│
└──────────────────────────────────────────────────────────────────────┘
```

**El truco mental:** no te comprometas a "hacer el proyecto". Solo a sentarte 25 minutos. Una vez sentado, sigues más tiempo el 80% de las veces. El otro 20%, paras a los 25 min y eso también está bien.

## ❓ -1.4 ¿Cuál es el mapa mental del proyecto en una sola imagen?

```
                    EL PROYECTO COMPLETO EN UN VISTAZO
                    ───────────────────────────────────

   [Tú aprendes →]   [Tú construyes →]   [Tú entregas →]

   ┌──────────┐      ┌──────────┐         ┌──────────┐
   │ Conceptos│      │ Local    │         │ Reporte  │   45%
   │  Parte 2 │ ───→ │ Parte 3  │         │ Parte 10 │
   └──────────┘      └────┬─────┘         └─────▲────┘
                          │                     │
                          ▼                     │
                    ┌──────────┐                │
                    │  Infra   │                │
                    │ Parte 4-5│                │
                    └────┬─────┘                │
                         │                      │
                         ▼                      │
                    ┌──────────┐                │
                    │  Ansible │ ───────────────┤   20%
                    │  Parte 6 │                │
                    └────┬─────┘                │
                         │                      │
                         ▼                      │
                    ┌──────────┐                │
                    │  CI/CD   │ ───────────────┤   25%
                    │  Parte 7 │                │
                    └────┬─────┘                │
                         │                      │
                         ▼                      │
                    ┌──────────┐                │
                    │  Observ. │ ───────────────┤   10%
                    │  Parte 8 │                │
                    └────┬─────┘                │
                         │                      │
                         ▼                      │
                    ┌──────────┐                │
                    │Decisiones│ ───────────────┘
                    │  Parte 9 │
                    └──────────┘

   Cada caja = 1 semana de trabajo (2-3h/día). Sin atajos, sin saltos.
   (Containerización + IaC se evalúa transversalmente a Parte 5+6+7 = 20% del PDF)
```

**Ahora ya viste el mapa.** No es magia, no es genio: es **6 cajas en orden**. Una por semana. Cada caja te abre la siguiente. **Y aquí no hay examen final** — la evaluación es tu repositorio. Un repo que existe vale infinito más que uno perfecto en tu cabeza.

## ❓ -1.5 ¿Cómo me comprometo conmigo mismo?

Escribe esto a mano en un papel y pégalo en tu monitor:

```
                ╔══════════════════════════════════════════╗
                ║                                          ║
                ║   HOY, _____ de _____ de 2026            ║
                ║                                          ║
                ║   Me comprometo a dedicar 25 minutos     ║
                ║   diarios al proyecto Dkron, durante 5   ║
                ║   semanas. Tengo permiso de equivocarme. ║
                ║                                          ║
                ║   Si un día no puedo, no es el fin del   ║
                ║   mundo. Mañana retomo.                  ║
                ║                                          ║
                ║   Firma: _________________               ║
                ║                                          ║
                ╚══════════════════════════════════════════╝
```

**Este compromiso es contigo, no con el bootcamp.** Cuando te trabes (te vas a trabar), míralo. No estás solo. Todo DevOps Senior empezó como tú: paralizado frente a un PDF.

Ahora sí, vamos al código.

---

<a id="parte-0"></a>
# PARTE 0 — Antes de tocar nada: las preguntas del que recién empieza

> Si nunca has tocado AWS ni Docker, estas preguntas son las que tienes. No te las saltes.

## ❓ 0.1 ¿Qué es DevOps y por qué este proyecto se llama así?
**DevOps** es una forma de trabajar donde el equipo que **desarrolla** y el equipo que **opera** colaboran (o son la misma persona). El proyecto pide que tú **operes** una aplicación open source: no la programes, sino que la pongas a correr en producción con buenas prácticas.

El énfasis del Caso D **no es escribir Dkron**, es **operarlo bien**: infraestructura como código, pipeline automático, observabilidad y documentación.

## ❓ 0.2 ¿Qué es la nube? ¿Qué es AWS?
La "nube" son computadoras que alquilas por hora. **AWS (Amazon Web Services)** es el proveedor de nube de Amazon. En vez de comprar un servidor físico, le pides a AWS uno virtual y pagas por el tiempo que lo uses.

El bootcamp **obliga** a usar AWS (no GCP, no Azure — ver FAQ del PDF).

## ❓ 0.3 ¿Cuánto me va a costar?
La sección 7 del PDF lo explica: **AWS Free Tier cubre la mayoría del consumo**. Los componentes que cuestan dinero continuo son:
- **NAT Gateway** (~$32/mes si lo dejas prendido 24/7 — pero solo lo prendes cuando trabajas)
- **ALB** (~$16/mes si lo dejas todo el mes prendido)

> 💡 **Ojo:** este proyecto **NO usa RDS**. La persistencia de Dkron OSS vive en **BoltDB embebido** sobre un volumen EBS de la propia EC2 (ver PARTE 9.2). Eso te ahorra ~$15/mes de RDS y un módulo Terraform entero. Si vienes de un tutorial antiguo que decía "RDS Postgres ~$15/mes", esa línea ya no aplica aquí.

**Truco crítico:** apaga TODO cuando termines de trabajar. Hay un workflow `destruir.yaml` que ejecuta `terraform destroy`. Úsalo cada noche. Sin esto, la cuenta puede subir a $50–$80 al mes. **Si trabajas 2 horas al día y destruyes después, el costo total del proyecto suele ser <$5.**

### 🔧 Configurar alertas de billing (HÁZLO HOY MISMO):
1. Ve a la consola AWS → **Billing** → **Budgets** → **Create budget**.
2. Crea un budget de **$10 USD mensuales** con alerta a tu email cuando llegues al 80%.
3. Esta alerta te avisa antes de quemar dinero.

## ❓ 0.4 ¿Qué necesito instalar en mi computadora?
Lo mínimo, en este orden exacto:

| Herramienta | Para qué | Comando (Linux Ubuntu/Debian) |
|---|---|---|
| **curl, unzip, jq** | Utilidades base | `sudo apt update && sudo apt install -y curl unzip jq` |
| **Git** | Control de versiones | `sudo apt install -y git` |
| **Docker + Compose v2** | Probar Dkron local | Sigue [docs.docker.com](https://docs.docker.com/engine/install/ubuntu/) y luego `sudo apt install docker-compose-plugin` |
| **AWS CLI v2** | Hablar con AWS | Ver [oficial](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **Terraform** | IaC | Ver [hashicorp.com](https://developer.hashicorp.com/terraform/install) |
| **gh (GitHub CLI)** | PRs desde terminal | `sudo apt install -y gh` |
| **VS Code (recomendado)** | Editor | [code.visualstudio.com](https://code.visualstudio.com/) |

### 💥 Errores que vas a cometer en este paso (todos los novatos los cometen):

**Error 0.4.A:** Instalas Docker, intentas correr `docker ps` y te dice:
```
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```
**Causa:** tu usuario no está en el grupo `docker`. Solución:
```bash
sudo usermod -aG docker $USER
# Cierra sesión completamente y vuelve a entrar (o reinicia)
docker ps  # ahora debe funcionar sin sudo
```

**Error 0.4.B:** Instalas AWS CLI con `apt install awscli` y te queda la **versión 1**, vieja. Verifica con `aws --version`. Si dice 1.x, desinstala y baja la v2 oficial:
```bash
sudo apt remove awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version  # debe decir 2.x.x
```

**Error 0.4.C:** Instalas `docker-compose` (con guion) y luego los tutoriales usan `docker compose` (sin guion). Son distintos. **El plugin v2 (sin guion) es el actual.**

**Error 0.4.D:** No agregas SSH key a GitHub y luego `git push` te falla con `Permission denied (publickey)`.
```bash
ssh-keygen -t ed25519 -C "tuemail@gmail.com"
cat ~/.ssh/id_ed25519.pub  # copia esto
# pégalo en github.com/settings/ssh/new
```

## ❓ 0.5 ¿Qué es el Caso D exactamente?
**Caso D — Programador de tareas (Dkron)**: vas a desplegar **Dkron** en AWS. Dkron es un `cron` distribuido moderno: programa que ciertas tareas se ejecuten a horarios específicos (ej: "cada noche a las 2am, ejecuta este script").

Componentes mínimos que pide el PDF (página 10):
- Container de Dkron (modo `server` y opcionalmente un `agent` aparte para los runs).
- **Persistencia local en BoltDB** (archivo embebido en el container, montado sobre un volumen EBS de la EC2). El PDF dice "BoltDB local **o** PostgreSQL" — en esta guía vamos con BoltDB porque **Dkron OSS v4 no soporta backends Postgres** (el flag `--store=postgres` solo existe en Dkron Pro, la versión comercial). Más detalle y justificación en PARTE 9.2.
- (Opcional) Bucket S3 para los outputs de los jobs.

Métricas a vigilar: **jobs ejecutados a tiempo, drift de horario, jobs fallidos, duración p95 por tipo de job.**

---

<a id="parte-3"></a>
# PARTE 3 — Tu primer día con Docker: levantar Dkron en local

> 🧭 **¿Por qué Parte 3 va antes que la 1 y la 2?** Te conviene tocar Dkron primero. Las Partes 1 (Caso D) y 2 (conceptos teóricos) se entienden 10× mejor cuando ya levantaste el container y curlearon los endpoints con tus dedos. **El número "3" es solo un ID estable — no el orden de lectura.** Después de este capítulo vas a Parte 1, luego Parte 2, luego Parte 4 (producción).
>
> Antes de tocar AWS, prueba Dkron en tu máquina con `docker-compose`. **Esta parte te ahorra horas de debugging después.**

## 🗺️ Diagrama: el stack local con docker-compose

```
       Tu laptop (Linux/Mac/WSL)
   ┌──────────────────────────────────────────────────────────────┐
   │                                                              │
   │   Tu navegador:                                              │
   │     http://localhost:8080  → Dkron UI                        │
   │     http://localhost:9090  → Prometheus UI                   │
   │     http://localhost:3000  → Grafana UI (admin/admin)        │
   │                                                              │
   │   ┌──────────────────────────────────────────────────────┐   │
   │   │  Docker Engine                                       │   │
   │   │                                                      │   │
   │   │   ┌─────────────────────────┐                       │   │
   │   │   │  Dkron                  │                       │   │
   │   │   │  :8080                  │                       │   │
   │   │   │  /metrics               │                       │   │
   │   │   │  store: BoltDB embebido │                       │   │
   │   │   │  vol dkron_data         │                       │   │
   │   │   └──────┬──────────────────┘                       │   │
   │   │          │ scrape /metrics cada 15s                 │   │
   │   │          ▼                                           │   │
   │   │   ┌─────────────┐         ┌─────────────┐            │   │
   │   │   │ Prometheus  │◀────────│  Grafana    │            │   │
   │   │   │  :9090      │  query  │  :3000      │            │   │
   │   │   │ vol prom_dt │         │ dashboards  │            │   │
   │   │   └──────┬──────┘         └─────────────┘            │   │
   │   │          │ alerts                                    │   │
   │   │          ▼                                           │   │
   │   │   ┌─────────────┐                                    │   │
   │   │   │Alertmanager │                                    │   │
   │   │   │  :9093      │                                    │   │
   │   │   └─────────────┘                                    │   │
   │   │                                                      │   │
   │   │   red: bridge interno entre containers               │   │
   │   └──────────────────────────────────────────────────────┘   │
   └──────────────────────────────────────────────────────────────┘

   docker compose up -d   ←  enciende todos los containers
   docker compose logs -f ←  mira lo que pasa
   docker compose down    ←  apaga todo
```

## ❓ 3.1 ¿Por qué empiezo local y no directo en AWS?
Porque cuando algo falle en AWS, no sabrás si es la app, AWS, o la red. Si primero la tienes funcionando local, sabes que la app está bien y puedes enfocarte en lo de AWS. **Esto es lo que hace todo profesional DevOps.**

## ❓ 3.2 ¿Qué archivos creo?
Crea la carpeta del proyecto y la subcarpeta `compose/`:
```bash
mkdir -p ~/proyectos/dkron-aws/compose
cd ~/proyectos/dkron-aws
git init
```

**Archivo `compose/docker-compose.yml`:**
```yaml
services:
  dkron:
    image: dkron/dkron:v4.0.9
    container_name: dkron-server
    command:
      - agent
      - --server
      - --bootstrap-expect=1
      - --node-name=dkron-server
      - --data-dir=/dkron.data
      - --log-level=info
    ports:
      - "8080:8080"
      - "8946:8946"
    volumes:
      - dkron_data:/dkron.data

  prometheus:
    image: prom/prometheus:v2.54.1
    container_name: dkron-prometheus
    depends_on:
      - dkron
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules.yml:/etc/prometheus/rules.yml:ro
      - prom_data:/prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --storage.tsdb.retention.time=15d
      - --web.enable-lifecycle
    ports:
      - "9090:9090"

  alertmanager:
    image: prom/alertmanager:v0.27.0
    container_name: dkron-alertmanager
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    ports:
      - "9093:9093"

  grafana:
    image: grafana/grafana:11.2.0
    container_name: dkron-grafana
    depends_on:
      - prometheus
    environment:
      GF_SECURITY_ADMIN_USER: ${GRAFANA_USER:-admin}
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_USERS_ALLOW_SIGN_UP: "false"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"

volumes:
  dkron_data:
  prom_data:
  grafana_data:
```

> 💡 **¿Y dónde está Postgres?** No está, a propósito. **Dkron OSS v4 usa BoltDB embebido** — es un archivo local dentro del container, en `/dkron.data`. Lo persistimos con el volumen `dkron_data` para que sobreviva a `docker compose down/up`. La opción `--store=postgres` que vas a ver en tutoriales viejos **solo existe en Dkron Pro** (la versión comercial); si la usas con el binario OSS, el container imprime el help y muere. Ver PARTE 11.2 para el debug real que nos llevó a esto.

**Archivo `compose/prometheus/prometheus.yml`** (scrape config + reglas de alerta):
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/rules.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

scrape_configs:
  - job_name: dkron
    metrics_path: /metrics
    static_configs:
      - targets: ["dkron:8080"]
        labels:
          service: dkron
          env: local

  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]
```

**Archivo `compose/prometheus/rules.yml`** (alertas — espejo local de las que correrán en AWS):
```yaml
groups:
  - name: dkron.rules
    rules:
      - alert: DkronHighFailureRate
        expr: increase(dkron_failed_jobs_total[5m]) > 5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Demasiados jobs fallidos en Dkron"
          description: "Más de 5 jobs fallaron en los últimos 5 minutos."

      - alert: DkronNoJobsRunning
        expr: max_over_time(dkron_running_jobs[1h]) < 1
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "Scheduler de Dkron sin actividad"
          description: "Ningún job ha corrido en la última hora — posible scheduler caído."

      - alert: DkronTargetDown
        expr: up{job="dkron"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Dkron no responde a Prometheus"
          description: "El target Dkron no expone /metrics hace 2 min."
```

**Archivo `compose/alertmanager/alertmanager.yml`** (en local va a un webhook fake — en AWS reemplazará por SNS):
```yaml
route:
  receiver: default
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h

receivers:
  - name: default
    webhook_configs:
      - url: "http://host.docker.internal:9999/dummy"
        send_resolved: true
```

**Archivo `compose/grafana/provisioning/datasources/prometheus.yml`** (Grafana descubre Prometheus solo):
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

**Archivo `compose/grafana/provisioning/dashboards/dashboards.yml`** (provider de dashboards — DEBE vivir en `provisioning/dashboards/`, no en `provisioning/datasources/`; si lo dejas en `datasources/` Grafana intenta parsearlo como datasource y lo ignora):
```yaml
apiVersion: 1
providers:
  - name: dkron
    folder: Dkron
    type: file
    disableDeletion: true
    options:
      # Apunta al mismo directorio donde está montado el JSON (provisioning/dashboards/).
      # Evita la necesidad de un segundo mount ./grafana/dashboards.
      path: /etc/grafana/provisioning/dashboards
```

**Archivo `compose/grafana/provisioning/dashboards/dkron-red.json`** (dashboard mínimo método RED — pégalo tal cual; vive junto al provider para que Grafana lo encuentre con un solo mount):
```json
{
  "uid": "dkron-red",
  "title": "Dkron — RED",
  "schemaVersion": 39,
  "version": 1,
  "refresh": "30s",
  "time": { "from": "now-1h", "to": "now" },
  "panels": [
    {
      "type": "stat",
      "title": "Rate — jobs/min (success)",
      "targets": [{ "expr": "rate(dkron_succeeded_jobs_total[5m]) * 60" }],
      "gridPos": { "x": 0, "y": 0, "w": 8, "h": 6 }
    },
    {
      "type": "stat",
      "title": "Errors — failures/min",
      "targets": [{ "expr": "rate(dkron_failed_jobs_total[5m]) * 60" }],
      "gridPos": { "x": 8, "y": 0, "w": 8, "h": 6 }
    },
    {
      "type": "stat",
      "title": "Running jobs (now)",
      "targets": [{ "expr": "dkron_running_jobs" }],
      "gridPos": { "x": 16, "y": 0, "w": 8, "h": 6 }
    },
    {
      "type": "timeseries",
      "title": "Success / Failure throughput",
      "targets": [
        { "expr": "rate(dkron_succeeded_jobs_total[5m])", "legendFormat": "success" },
        { "expr": "rate(dkron_failed_jobs_total[5m])", "legendFormat": "failed" }
      ],
      "gridPos": { "x": 0, "y": 6, "w": 24, "h": 8 }
    },
    {
      "type": "timeseries",
      "title": "Tasa de éxito (SLO 95%)",
      "targets": [{
        "expr": "sum(rate(dkron_succeeded_jobs_total[5m])) / clamp_min(sum(rate(dkron_succeeded_jobs_total[5m]) + rate(dkron_failed_jobs_total[5m])), 0.001)"
      }],
      "gridPos": { "x": 0, "y": 14, "w": 24, "h": 8 }
    }
  ]
}
```

**Archivo `compose/.env.example`** (este SÍ se sube al repo):
```env
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin
```

**Archivo `compose/.env`** (NO subir al repo):
```env
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin
```

> 💡 **¿Por qué este `.env` está casi vacío?** Antes contenía `POSTGRES_USER/PASSWORD/DB` para inyectar el DSN al Dkron. Como ya no hay Postgres (BoltDB no necesita credenciales — es un archivo local), solo quedan las variables de Grafana.

**Archivo `.gitignore`** en la raíz:
```
.terraform/
*.tfstate
*.tfstate.backup
.env
.env.local
*.tfvars
!*.tfvars.example
.DS_Store
```

## ❓ 3.3 ¿Cómo lo levanto?
```bash
cd ~/proyectos/dkron-aws/compose
cp .env.example .env
docker compose up -d
docker compose ps
```

Espera ~20 segundos y abre en tu navegador:
- **Dkron UI:** `http://localhost:8080/dashboard`
- **Prometheus targets:** `http://localhost:9090/targets` — el target `dkron` debe verse en verde (`UP`). Si está rojo, revisa el log: `docker compose logs prometheus`.
- **Grafana:** `http://localhost:3000` (usuario/clave del `.env`). En la barra lateral → *Dashboards → Dkron → Dkron — RED*. Vas a ver los paneles aún en cero hasta que crees un job.
- **Alertmanager UI:** `http://localhost:9093`.

## 💥 Errores que vas a cometer en la PARTE 3 (te van a pasar uno por uno)

### Error 3.B: "port is already allocated" en 8080
**Síntoma:** `Error response from daemon: ports are not available`.
**Causa:** otro proceso usa ese puerto.
**Solución 1:** descubre quién: `sudo lsof -i :8080`. Mátalo si puedes.
**Solución 2:** cambia el puerto en compose:
```yaml
ports:
  - "8090:8080"   # ahora abres http://localhost:8090
```

### Error 3.C: "permission denied while trying to connect to the Docker daemon socket"
**Síntoma:** `docker compose up` lo pide con `sudo`.
**Causa:** tu usuario no está en el grupo `docker`.
**Solución:**
```bash
sudo usermod -aG docker $USER
# CIERRA SESIÓN COMPLETAMENTE Y VUELVE A ENTRAR
docker ps  # ya sin sudo
```

### Error 3.D: Usaste `dkron/dkron:latest`
**Síntoma:** todo funciona pero violaste la regla del PDF.
**Causa:** `latest` no es reproducible.
**Solución:** cambia a `dkron/dkron:v4.0.9`. Documéntalo en el README ("imagen pinneada a v4.0.9").

### Error 3.E: La UI carga pero no autentica (versiones recientes de Dkron)
**Síntoma:** dashboard pide credenciales que no tienes.
**Solución:** la versión `v4.0.9` no las exige por defecto. Si bajaste otra versión, busca en el changelog si hay flag `--no-auth`.

### Error 3.F: `docker compose` te dice "command not found"
**Síntoma:** `docker compose up` falla.
**Causa:** tienes la v1 antigua (`docker-compose` con guion).
**Solución:** instala el plugin v2: `sudo apt install docker-compose-plugin`.

## ❓ 3.4 ¿Cómo creo mi primer job para probar?
Con Dkron corriendo, abre otra terminal:
```bash
curl -X POST http://localhost:8080/v1/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "name": "saludo",
    "schedule": "@every 1m",
    "executor": "shell",
    "executor_config": {
      "command": "echo Hola desde Dkron"
    }
  }'
```

Espera 1 minuto:
```bash
curl http://localhost:8080/v1/jobs/saludo/executions | jq
```
Deberías ver al menos una ejecución con `success: true`.

### 💥 Error 3.G: el job se crea pero nunca se ejecuta
**Síntoma:** `executions` devuelve `[]` después de varios minutos.
**Causa común:** usaste un schedule mal escrito. Dkron usa formato cron extendido, e.g., `@every 1m`, `0 */5 * * * *` (con segundos al inicio).
**Solución:** prueba con `"schedule": "@every 30s"` y verifica.

### 💥 Error 3.H: el target Dkron sale rojo (`DOWN`) en Prometheus
**Síntoma:** en `http://localhost:9090/targets` el job `dkron` aparece como `down`, con error `connection refused` o `no such host`.
**Causa común:** Prometheus está apuntando a `localhost:8080` o a un nombre que no resuelve dentro de la red de compose.
**Solución:** dentro de la red de compose, el host del container Dkron es `dkron` (el nombre del servicio). Verifica que `prometheus.yml` diga `targets: ["dkron:8080"]`, no `localhost`.

### 💥 Error 3.I: Grafana no muestra datos
**Síntoma:** los paneles dicen "No data".
**Causa común:** (a) Dkron todavía no ejecutó ningún job; (b) el datasource no apunta a `http://prometheus:9090`; (c) el rango de tiempo en Grafana es anterior al arranque.
**Solución:**
1. Crea un job rápido (sección 3.4) y espera 1 min.
2. En Grafana → *Connections → Data sources → Prometheus → Test* → debe responder "Data source is working".
3. Cambia el rango a *Last 15 minutes*.

## ❓ 3.5 ¿Qué métricas expone Dkron y cómo se ven en Prometheus?
```bash
curl http://localhost:8080/metrics | grep dkron
```

Verás líneas como:
```
dkron_running_jobs 0
dkron_succeeded_jobs_total 5
dkron_failed_jobs_total 0
```

Las mismas tres métricas (más `up{job="dkron"}` que añade Prometheus) las puedes consultar en `http://localhost:9090/graph`:

| Query PromQL | Qué muestra |
|---|---|
| `dkron_running_jobs` | Cuántos jobs están corriendo ahora mismo. |
| `rate(dkron_succeeded_jobs_total[5m])` | Throughput de éxitos (jobs/s). |
| `rate(dkron_failed_jobs_total[5m])` | Throughput de errores (jobs/s). |
| `increase(dkron_failed_jobs_total[1h])` | Cuántos fallos en la última hora. |
| `up{job="dkron"}` | 1 si Prometheus puede scrapear, 0 si no. |

**Anota estas queries** — las reutilizarás idénticas en el Grafana de AWS (Parte 7).

## 🎯 Lo que aprendiste (apunta para el reporte):

**Concepto B.2 del reporte (containerización vs "EC2 + Ansible" para CI/CD).** Aquí tienes que ser HONESTO en el reporte: en este proyecto vas a usar **las dos cosas a la vez**:

- En tu laptop: `docker compose up` levantó cuatro servicios en 30 segundos. Cero configuración de SO, cero "instalar dependencias", cero "abrir el firewall". Ese es el valor del container: empaqueta runtime + dependencias + red.
- En AWS (Parte 5-6): vas a tener una **EC2 con Docker Compose configurado por Ansible**. Significa que debajo de los containers tienes una capa adicional ("¿la EC2 tiene Docker instalado?", "¿la versión correcta de docker compose plugin?", "¿el daemon corre con los flags que queremos?"). Esa capa la gestiona Ansible — no Terraform, no el container.

**Lo que vas a defender en el reporte (te lo dejo apuntado):**
1. Containers eliminan la matriz de "funciona en mi máquina" — la imagen `dkron/dkron:v4.0.9` es bit-a-bit la misma en local y en EC2.
2. Pero containers **no eliminan** la necesidad de gestión de configuración cuando corres en EC2: sigues teniendo que instalar el motor (Docker), gestionar el `compose.yml`, preocuparte de actualizaciones de seguridad del kernel. Por eso existe Ansible.
3. ECS Fargate **sí** elimina esa capa intermedia (no hay máquina que configurar). Por eso lo elegimos para Prometheus/Grafana, que son servicios sin estado de aplicación.
4. La elección "EC2 + Ansible" para Dkron NO es un retroceso pedagógico: es el único camino que te permite **demostrar** la separación IaC↔gestión de configuración en concreto en el reporte (concepto B.1).

## 🛑 Antes de seguir:
```bash
docker compose down  # detén todo, libera recursos
```

> ✅ **Hecho local. Toca contexto teórico.** Ya tienes Dkron levantado y entiendes qué hace. Ahora sí, las dos siguientes partes (1 y 2) te van a hacer mucho más sentido:
> - **Parte 1** — qué pide el PDF y el Caso D, los entregables, los pesos de evaluación.
> - **Parte 2** — los conceptos que necesitas tener claros antes de tocar AWS (containers, IaC, Ansible, CI/CD, SLOs, VPC, IAM).
>
> Después de la Parte 2 saltas a Parte 4 y arranca la fase de **producción AWS**.

---

<a id="parte-1"></a>
# PARTE 1 — Entender qué pide el Caso D

> ⚠️ **Aviso del PDF (sección 2):** "Una sola elección por proyecto." Si elegiste Caso D, **no puedes saltar** a otro escenario a mitad. Saltar invalida la mayoría del trabajo previo de infraestructura. Si dudaste, dudaste; ahora committe a Dkron y termina.
>
> ⚠️ **Aviso del PDF (sección 5.1 + sección 7):** El código de los talleres del bootcamp es **referencia de estructura**, NO **código de partida**. Importar módulos del taller directamente NO cumple el requisito de "infraestructura nueva". Mira cómo están organizados los talleres y escribe el tuyo desde cero.

## 🗺️ La topología OFICIAL del PDF (página 11) — léela una vez y vuelve a esta imagen mental

> **Esto es lo que el PDF dibuja.** El resto de la guía es cómo lo construyes paso a paso. Si te pierdes en cualquier sección, vuelve aquí.

```
                       Operador (REST API · UI)
                              │
                              │  REST · UI
                              ▼
   ╔══ AWS · VPC (1 región, 1 AZ) ══════════════════════════════════════╗
   ║                                                                    ║
   ║   ╔══ Subnet pública ══╗                                           ║
   ║   ║                    ║                                           ║
   ║   ║  Application       ║                                           ║
   ║   ║  Load Balancer     ║                                           ║
   ║   ║                    ║                                           ║
   ║   ╚══════════╤═════════╝                                           ║
   ║              │ forward                                             ║
   ║              ▼                                                     ║
   ║   ╔══ Subnet privada ═════════════════════════════════════════╗    ║
   ║   ║                                                           ║    ║
   ║   ║  ┌─ Dkron ──────────────────┐                             ║    ║
   ║   ║  │                          │                             ║    ║
   ║   ║  │   ┌─────────────────┐    │                             ║    ║
   ║   ║  │   │ Server          │    │     ┌─────────────────────┐ ║    ║
   ║   ║  │   │ (scheduler)     │────┼─────│ BoltDB embebido     │ ║    ║
   ║   ║  │   │                 │ state    │ volumen EBS gp3     │ ║    ║
   ║   ║  │   └────────┬────────┘    │     │ (jobs e historial)  │ ║    ║
   ║   ║  │            │             │     └─────────────────────┘ ║    ║
   ║   ║  │      dispatch            │                             ║    ║
   ║   ║  │            ▼             │                             ║    ║
   ║   ║  │   ┌─────────────────┐    │                             ║    ║
   ║   ║  │   │ Agent (executor)│    │                             ║    ║
   ║   ║  │   │ opcional · puede│    │                             ║    ║
   ║   ║  │   │ ser el mismo    │    │                             ║    ║
   ║   ║  │   │ nodo            │    │                             ║    ║
   ║   ║  │   └────┬────────────┘    │                             ║    ║
   ║   ║  └───────│──────────────────┘                             ║    ║
   ║   ║          │                                                ║    ║
   ║   ║   output │   ejecución                                    ║    ║
   ║   ║   opcional   (sale del VPC                                ║    ║
   ║   ║          │    por NAT)                                    ║    ║
   ║   ║          │                                                ║    ║
   ║   ║   ╔══ Almacenamiento (opcional) ══╗                       ║    ║
   ║   ║   ║                               ║                       ║    ║
   ║   ║   ║   ┌─────────────────────┐     ║                       ║    ║
   ║   ║   ║   │ S3                  │     ║                       ║    ║
   ║   ║   ║   │ outputs de jobs     │     ║                       ║    ║
   ║   ║   ║   └─────────────────────┘     ║                       ║    ║
   ║   ║   ╚═══════════════════════════════╝                       ║    ║
   ║   ║                                                           ║    ║
   ║   ║   ╔══ Plataforma ═════════════════════════════╗           ║    ║
   ║   ║   ║                                           ║           ║    ║
   ║   ║   ║   ┌──────────────────┐  ┌──────────────┐  ║           ║    ║
   ║   ║   ║   │ Logs y métricas  │  │ ECR          │  ║◀── docker ║    ║
   ║   ║   ║   │ (camino a elegir)│  │ (mirror de   │  ║   pull    ║    ║
   ║   ║   ║   │  ← logs/metrics  │  │  la imagen   │  ║   (desde  ║    ║
   ║   ║   ║   │                  │  │  oficial)    │  ║   server) ║    ║
   ║   ║   ║   └──────────────────┘  └──────────────┘  ║           ║    ║
   ║   ║   ╚═══════════════════════════════════════════╝           ║    ║
   ║   ╚═══════════════════════════════════════════════════════════╝    ║
   ║                                                  │                 ║
   ╚══════════════════════════════════════════════════│═════════════════╝
                                                      │ ejecución
                                                      ▼
                                          ┌──────────────────────┐
                                          │ Targets de los jobs  │
                                          │ (HTTP, scripts)      │
                                          │ FUERA de la VPC      │
                                          └──────────────────────┘
```

**Cómo leer este diagrama de la imagen del PDF (de arriba hacia abajo):**

1. **Operador** = tú (o cualquier humano/CI) hablándole a Dkron por su REST API o por su UI web.
2. **ALB** en subnet pública: la única puerta abierta a Internet. Recibe el tráfico del operador y lo reenvía al Server.
3. **Server (scheduler)**: dentro de la subnet privada, lleva el reloj y guarda el estado en **BoltDB embebido** (archivo local persistido en un volumen EBS). Cuando llega la hora de un job, dispara un *dispatch* al Agent.
4. **Agent (executor)**: dentro de la misma subnet, recibe el dispatch y EJECUTA el job. Como dice la nota literal del PDF, *"opcional · puede ser el mismo nodo"* — en single-node es el mismo binario actuando con dos roles.
5. **BoltDB embebido + EBS gp3**: el "libro" de jobs e historial. El PDF te deja elegir entre BoltDB y PostgreSQL; aquí vamos con **BoltDB** porque Dkron OSS v4 no soporta el flag `--store=postgres` (solo existe en Dkron Pro). La durabilidad la cubrimos montando el data dir sobre un volumen EBS encriptado.
6. **S3 outputs (opcional)**: si los jobs generan archivos grandes, el Agent los sube ahí. Si no, se omite.
7. **Plataforma lateral**:
   - *Logs y métricas (camino a elegir)*: el PDF deja la elección al proyecto (sección 5.4 — Camino 1 self-hosted Prometheus/Grafana/Loki, Camino 2 CloudWatch nativo, Camino 3 AMP/AMG). **Este proyecto elige Camino 1**.
   - *ECR (mirror de la imagen oficial)*: la EC2 hace `docker pull` desde ECR, no desde Docker Hub.
8. **Targets de los jobs (HTTP, scripts)**: viven **FUERA** de la VPC. El Agent sale a Internet por el NAT Gateway para llamarlos.

> 📐 **Esta es la imagen mental que defendemos en el reporte.** Todo lo que aparece en este diagrama está justificado en el PDF; lo que NO aparece (Ansible, Prometheus, Grafana, SNS, etc.) son decisiones del proyecto y se justifican en el reporte como tales.

---

## 🍎 La lógica del Caso D explicada con manzanitas (lee esto primero)

> Si nada de lo que dice el PDF te entra en la cabeza, esta sección está hecha para ti. Olvida AWS, Terraform, contenedores. Aquí vamos con manzanitas.

### 🍎 ¿Qué hace Dkron? Una analogía con el restaurante (DOS personas: jefe de cocina y ayudante).

Imagina que abres un restaurante. **Tu cocina tiene 30 tareas diarias que repetir a horas fijas:**

```
   5:00 am  →  encender los hornos
   6:00 am  →  amasar el pan
   7:00 am  →  cortar las verduras
   8:00 am  →  hacer el caldo del día
  10:00 am  →  preparar postres
  12:00 pm  →  poner la sopa al fuego
   2:00 pm  →  limpiar la primera freidora
   8:00 pm  →  limpiar la segunda freidora
  11:00 pm  →  guardar todo en refrigeración
  ... 21 tareas más ...
```

**Problema sin Dkron:** el cocinero tiene que acordarse de todo solo. Si se distrae, una tarea no se hace y se quema el pan.

**Con Dkron, el trabajo se reparte entre DOS roles** — y aquí es donde la imagen del PDF (página 11) es muy explícita:

```
   ┌─────────────────────────────────────────────────────────────┐
   │   El JEFE DE COCINA  =  Dkron Server (scheduler)            │
   │   • Lleva el cuaderno con horarios                          │
   │   • Mira el reloj                                           │
   │   • A las 7:00 grita: "¡cortar verduras AHORA!"             │
   │   • Anota en el cuaderno quién la hizo y a qué hora         │
   │   • NO corta las verduras él mismo                          │
   ├─────────────────────────────────────────────────────────────┤
   │   El AYUDANTE  =  Dkron Agent (executor)                    │
   │   • Espera la orden del jefe                                │
   │   • Va y CORTA las verduras (ejecuta el comando)            │
   │   • Llama al proveedor si toca (HTTP request a otra API)    │
   │   • Reporta al jefe: "listo, en 3 min, sin errores"         │
   └─────────────────────────────────────────────────────────────┘

   Nota clave de la imagen del PDF:
   "Agent (executor) opcional · puede ser el mismo nodo"

   → Significa: en un restaurante chico, el jefe y el ayudante
     pueden ser la MISMA persona (un solo binario corre los dos roles).
   → En un restaurante grande, conviene separarlos: un jefe que
     planifica + varios ayudantes que ejecutan en paralelo.
```

**Otros personajes que aparecen en la imagen del PDF:**

```
   ┌─────────────────────────────────────────────────────────────┐
   │   El OPERADOR (REST API · UI)                               │
   │   • Eres TÚ desde tu computadora                            │
   │   • Le dices al jefe por la API:                            │
   │       "agrega esta nueva tarea a las 3am todos los días"    │
   │   • También miras el panel web para ver el histórico        │
   ├─────────────────────────────────────────────────────────────┤
   │   Los TARGETS de los jobs (HTTP, scripts) — FUERA DEL VPC   │
   │   • Son los lugares a donde el AYUDANTE tiene que ir:       │
   │       el proveedor de verduras, el banco, otra API          │
   │   • No viven dentro de tu restaurante                       │
   │   • El ayudante sale a buscarlos por la puerta de atrás     │
   │     (NAT Gateway en AWS)                                    │
   ├─────────────────────────────────────────────────────────────┤
   │   El RECETARIO (BoltDB embebido sobre volumen EBS)          │
   │   • Cuaderno propio del cocinero, sobre un anaquel          │
   │     fijo en la cocina (volumen EBS encriptado)              │
   │   • El jefe anota cada tarea y cada ejecución               │
   │   • Si la cocina se incendia, el anaquel sobrevive          │
   │     (snapshots EBS) — pero si tiras toda la cocina sin      │
   │     guardar el cuaderno, lo pierdes                         │
   │   • NO es un "libro en caja fuerte de otro local" (RDS) —   │
   │     Dkron OSS no soporta backend Postgres, ese flag solo    │
   │     existe en Dkron Pro                                     │
   ├─────────────────────────────────────────────────────────────┤
   │   La DESPENSA DE RECETAS (ECR · mirror imagen oficial)      │
   │   • Una copia local del manual del cocinero (imagen Docker) │
   │   • Si la fábrica original (Docker Hub) cierra, abres igual │
   ├─────────────────────────────────────────────────────────────┤
   │   La BODEGA OPCIONAL (S3 outputs de jobs)                   │
   │   • Caja donde el ayudante mete copia del informe de        │
   │     cada tarea grande (un dump de DB, un PDF, un log gordo) │
   │   • Es OPCIONAL: si los informes son cortos, no la usas     │
   │   • La imagen del PDF la marca explícitamente "(opcional)"  │
   └─────────────────────────────────────────────────────────────┘
```

**Eso es Dkron: un jefe de cocina (server) que reparte tareas a tiempo, y un ayudante (agent) que las ejecuta. Y como dice la imagen del PDF, en un restaurante chico jefe y ayudante pueden ser la misma persona.**

### 🍎 ¿Qué pide el Caso D? Construir el restaurante completo.

El proyecto NO es escribir Dkron (Dkron ya existe, es open source). El proyecto es **montar el restaurante donde Dkron va a vivir**, con todas las cosas que un restaurante profesional tiene:

```
   Componente del proyecto                 Equivalente en restaurante
   ────────────────────────────────        ─────────────────────────────
   EC2 + Docker Compose (la cocina)   ←→   La cocina física que tú alquilas
   [PDF Opción B, sección 5.2]             y montas con Ansible

   Container Dkron rol SERVER         ←→   El JEFE DE COCINA
   (--server scheduler)                    Lleva el reloj, planifica, anota
   [bloque "Server (scheduler)"            en el recetario, NO ejecuta él
    en la imagen del PDF]                  mismo las tareas

   Container Dkron rol AGENT          ←→   El AYUDANTE DE COCINA
   (executor — opcional, mismo nodo)       Recibe la orden del jefe y la
   [bloque "Agent (executor)" en           ejecuta. Sale por la puerta de
    la imagen del PDF]                     atrás si tiene que ir a otra
                                           tienda (target externo)

   BoltDB embebido + volumen EBS      ←→   El cuaderno propio del cocinero
   [el PDF lista BoltDB o PostgreSQL;       sobre un anaquel fijo (recuerda
    Dkron OSS solo soporta BoltDB,          qué tareas hay, a qué hora y
    Postgres es feature de Dkron Pro]       cómo terminó cada una)

   ALB (subnet pública)               ←→   La puerta principal del
   [bloque "Application Load Balancer"     restaurante (los operadores
    en subnet pública del PDF]             entran por ahí, NO por la cocina)

   Operador (tú con `curl` o el panel)←→   El dueño que llega por la puerta
   [icono persona arriba en la imagen]     principal y dice: "agrega esta
                                           nueva tarea para mañana 3am"

   Targets de los jobs (HTTP, scripts)←→   Los proveedores externos a los
   [icono "Targets de los jobs"            que el ayudante tiene que ir:
    fuera de la VPC en la imagen]          banco, proveedor de carne, otra
                                           API. Viven afuera del restaurante

   S3 outputs (OPCIONAL)              ←→   Bodega donde el ayudante guarda
   [bloque "Almacenamiento (opcional)"     copia del informe de cada tarea
    en la imagen del PDF]                  grande. Si no es necesaria, no
                                           se monta

   Security Groups                    ←→   El portero que solo deja entrar
                                           al personal autorizado por cada
                                           puerta

   ECR (mirror imagen oficial)        ←→   La despensa donde guardas una
   [bloque "ECR (mirror de la              copia local del manual del
    imagen oficial)" en la imagen]         cocinero, no dependes del
                                           proveedor original (Docker Hub)

   Logs y métricas (Prom + Grafana    ←→   Las cámaras de seguridad + el
    en Fargate)                            tablero del gerente que muestra
   [bloque "Logs y métricas (camino        cuántas tareas se hicieron, con
    a elegir)" en la imagen]               qué retraso, cuántas fallaron

   SSM Parameter Store                ←→   La caja fuerte con las llaves
                                           (clave de la base de datos, etc.)

   SNS + email                        ←→   El teléfono que suena si algo
                                           se quema

   Terraform                          ←→   Los planos del restaurante.
                                           Si se incendia, en 15 minutos
                                           construyes uno idéntico

   Ansible                            ←→   El contratista que entra al local
                                           ya construido e instala los
                                           hornos, monta el recetario y
                                           pone al cocinero a trabajar

   GitHub Actions (CI/CD)             ←→   El gerente que revisa que cualquier
                                           cambio al restaurante cumpla normas
                                           antes de dejarlo entrar

   Runbook                            ←→   El manual del cocinero suplente
                                           ("si pasa X, haz Y")

   REPORTE.md                         ←→   La memoria que entregas a tus
                                           inversores explicando todas las
                                           decisiones que tomaste
```

### 🍎 Las 5 decisiones del Caso D explicadas con el restaurante

El PDF (página 11) pide 5 decisiones. Aquí van con manzanitas:

```
  Pregunta del PDF                    Versión con manzanitas
  ──────────────────                  ───────────────────────────────
  1. ¿Un nodo o cluster?              ¿Un cocinero o un equipo?
                                      → Cluster = más cocineros, si uno
                                        se enferma siguen los otros.
                                      → Para un restaurante chico
                                        (alcance del proyecto), 1 basta.

  2. ¿BoltDB o PostgreSQL?            ¿El recetario en un cuaderno propio
                                      del cocinero o en un libro de otro
                                      local?
                                      → BoltDB: cuaderno del cocinero,
                                        sobre un anaquel fijo de la
                                        cocina (volumen EBS). Resiste
                                        reinicios; si tiras la cocina
                                        sin guardar el cuaderno, lo
                                        pierdes (mitigación: snapshots
                                        de EBS).
                                      → PostgreSQL (RDS): libro en otro
                                        local de la cadena. Suena bien,
                                        pero Dkron OSS NO soporta este
                                        flag — solo Dkron Pro lo tiene.
                                        Para este Caso D vamos con
                                        BoltDB (es la única opción real).

  3. ¿Cómo medir el drift?            ¿Cómo sé si el cocinero llega
                                      tarde a sus tareas?
                                      → Anoto la hora a la que DEBÍA
                                        empezar cada tarea y la hora
                                        REAL. La diferencia es el drift.

  4. ¿Cómo evitar duplicados?         ¿Y si el cocinero termina la sopa
                                      pero se reinicia su memoria y
                                      la vuelve a empezar?
                                      → Cada tarea verifica primero
                                        ("¿ya hice esto hoy?") en el
                                        libro permanente. Si sí, no
                                        repite.

  5. ¿Política de timeout?            ¿Cuánto tiempo le doy al cocinero
                                      para una tarea antes de cancelarla?
                                      → "Si no termina la sopa en 10 min,
                                        algo está mal: corto la tarea,
                                        registro el fallo, suena alarma."
```

### 🍎 ¿Por qué este flujo y no otro? El sentido común detrás.

```
   ¿Por qué Internet NO habla directo a Dkron?
   ──────────────────────────────────────────
   Porque sería como dejar la cocina del restaurante con la puerta
   abierta a la calle. Cualquiera entraría. El ALB es la puerta
   principal con guardia: "tú entras por aquí o no entras".

   ¿Por qué Dkron está en subnet privada?
   ──────────────────────────────────────
   Porque la cocina no debe estar a la vista del cliente.
   Solo el ALB es público. Todo lo demás (la EC2 con Dkron,
   el volumen EBS con el cuaderno BoltDB, las tasks de
   observabilidad) vive en subnet privada y solo se llega
   por el ALB.

   ¿Por qué replicar la imagen oficial a ECR?
   ──────────────────────────────────────────
   Porque si dependes de Docker Hub y un día Docker Hub no anda,
   tu restaurante no abre. Si tienes una copia de la receta del
   cocinero en TU despensa (ECR), abres aunque el mercado esté cerrado.

   ¿Por qué Terraform y no clic-clic en consola AWS?
   ──────────────────────────────────────────────────
   Porque si tu restaurante se quema, con clic-clic tienes que
   acordarte qué configuraste. Con Terraform, los planos están
   en papel: comando → restaurante idéntico nuevo en 15 minutos.

   ¿Por qué Ansible si ya tengo Terraform?
   ────────────────────────────────────────
   Terraform te entrega el LOCAL del restaurante con luz y agua
   (la EC2 prendida, la red, la base de datos). Pero ese local
   está VACÍO por dentro: no tiene horno, no tiene cocinero, no
   tiene recetario montado. Ansible es el contratista que entra
   y monta todo el interior: instala Docker (el horno), trae el
   docker-compose.yml (el recetario), arranca a Dkron (el
   cocinero). Si tuvieras Fargate, AWS armaría el interior por ti
   y no necesitarías Ansible — pero elegimos EC2 (Opción B del
   PDF) precisamente para PRACTICAR esa separación.

   ¿Por qué CloudWatch y SNS?
   ───────────────────────────
   Porque si una freidora se prende fuego a las 3am y no hay nadie,
   el incendio crece. Cámaras (CloudWatch) y teléfono que suena
   (SNS → email) te avisan a las 3:01am.

   ¿Por qué pipeline en GitHub Actions?
   ────────────────────────────────────
   Porque cualquier cambio al restaurante (mover un horno, cambiar
   un menú) debería pasar primero por un gerente que verifique:
   "¿esto cumple normas? ¿ya está scaneado por bomberos?". El
   pipeline hace eso automático antes de aplicar el cambio.

   ¿Por qué SLOs?
   ──────────────
   Porque "el restaurante anda bien" es subjetivo. SLO es un número:
   "el 99% de las tareas se ejecutan en sus primeros 30 segundos
    durante la última semana". Eso es objetivo, medible, defendible.
```

### 🍎 Si tuvieras que explicarle el proyecto a tu abuela en 30 segundos

> "Abuela, hay un programa que se llama Dkron, hace de despertador para tareas de computadora — le dices 'haz X a las 3am' y lo hace solo. Yo voy a ponerlo a vivir en una computadora alquilada en Amazon (la nube). Tengo dos cuadernos: uno (Terraform) le dice a Amazon 'arma esta computadora con esta red y esta base de datos'; el otro (Ansible) le dice a la computadora ya armada 'ahora instala Docker y arranca a Dkron'. Si todo se rompe, con un comando construyo otra computadora idéntica en 15 minutos. Y aparte tengo cámaras y un teléfono que me avisa si Dkron falla."

Si entendiste eso, entiendes el Caso D. Lo demás son detalles técnicos.

---

## ❓ 1.1 ¿Qué es Dkron en términos simples?
Imagina que tienes 50 tareas que se deben ejecutar a horas distintas (backups, reportes, limpieza de logs). En vez de tener un cron por máquina (que se cae si la máquina se cae), **Dkron** es un servicio centralizado: tú le dices por API "corre `script_de_backup.sh` todos los días a las 3am" y él se encarga.

Tiene:
- **REST API** para crear/borrar/listar jobs (`POST /v1/jobs`, `GET /v1/jobs/...`).
- **Panel web** en `http://servidor:8080/dashboard`.
- **Métricas Prometheus** en `/metrics`.
- **Almacenamiento** en BoltDB (archivo embebido — la única opción real en Dkron OSS; el flag `--store=postgres` solo existe en Dkron Pro). En este proyecto lo persistimos sobre un volumen EBS encriptado para que sobreviva a reinicios.

## ❓ 1.2 ¿Qué decisiones técnicas debo justificar?
Las **5 decisiones obligatorias** del Caso D (página 11 del PDF):

1. **¿Un único nodo Dkron o un cluster?** ¿Qué aporta operar en cluster?
2. **¿BoltDB local o PostgreSQL?** ¿Qué se gana en cada caso? (Spoiler: Dkron OSS solo permite BoltDB — Postgres es feature de Dkron Pro. Lo discutimos igual en PARTE 9.2 para tener material en el reporte.)
3. **¿Cómo se mide el drift** (diferencia entre la hora programada y la real)? ¿Qué métrica registra ese delta?
4. **¿Cómo se previene la ejecución duplicada** si Dkron reinicia mientras corría?
5. **¿Qué política de timeout aplica** y qué pasa con un job que la excede?

Estas las contestas en el **REPORTE.md**. La guía te lleva paso a paso a las respuestas con tus propios datos.

> 🧭 **Decisiones adicionales sugeridas por la topología del PDF (página 11)** — NO son obligatorias, pero quedan implícitas en la imagen y conviene tomarlas y documentarlas en el reporte sección A para evidenciar comprensión:
> - **¿Server y agent en el mismo proceso o separados?** La topología los dibuja como bloques distintos con la nota "opcional · puede ser el mismo nodo". Ver PARTE 9.1bis.
> - **¿Persistir outputs en S3 o no?** La topología marca el bucket como "(opcional)". Ver PARTE 9.6.

## 🗺️ Diagrama: lo que vas a tener al terminar

> 📐 **Base de este diagrama:** topología sugerida del Escenario D en la página 11 del PDF — Operador → ALB (subnet pública) → Dkron `Server (scheduler)` con un `Agent (executor)` opcional ("puede ser el mismo nodo") → **persistencia local en BoltDB sobre EBS** (el PDF también lista Postgres como alternativa, pero Dkron OSS no la soporta — ver PARTE 9.2), con ECR como mirror de la imagen oficial, S3 opcional para outputs de jobs, y Targets de los jobs (HTTP, scripts) **fuera de la VPC**. Reflejamos esa topología fielmente y le superponemos la decisión propia del proyecto (Opción B del PDF 5.2: EC2 + Compose + Ansible) y la observabilidad (camino a elegir — sección 5.4 del PDF).

```
              Operador (REST API · UI)
                       │
                       ▼  HTTP :80
        ┌─────────────────────┐
        │  Application Load   │   ← entrada pública
        │     Balancer        │     (subnet pública)
        └──────────┬──────────┘
                   │  forward :8080
                   ▼
   ╔════════════════════════════════════════════════════════════╗
   ║              SUBNET PRIVADA                                ║
   ║                                                            ║
   ║   ┌────────────────────────────────────────────────────┐  ║
   ║   │ EC2 (t3.micro)  —  Docker Compose v2, cfg ANSIBLE  │  ║
   ║   │ ┌────────────────────────────┐                     │  ║
   ║   │ │ dkron-server (scheduler)   │──┐                  │  ║
   ║   │ │  :8080  /metrics           │  │ state            │  ║
   ║   │ │  --data-dir=/dkron.data    │  ▼                  │  ║
   ║   │ └────────────┬───────────────┘ ┌──────────────────┐│  ║
   ║   │              │ dispatch        │ BoltDB embebido  ││  ║
   ║   │              ▼                 │ vol EBS gp3 enc. ││  ║
   ║   │ ┌────────────────────────────┐ │ /var/lib/        ││  ║
   ║   │ │ dkron-agent (executor)     │ │   dkron-data     ││  ║
   ║   │ │  OPCIONAL · mismo proceso  │ └──────────────────┘│  ║
   ║   │ │  del server                │                     │  ║
   ║   │ └────────────┬───────────────┘                     │  ║
   ║   │ + node_exporter :9100                              │  ║
   ║   └──────────────┼─────────────────────────────────────┘  ║
   ║                  │ ejecución                              ║
   ║                  ▼                                        ║
   ║                  └─────────────────────────────────────────╫──▶ Targets de los jobs
   ║                                                           ║    (HTTP, scripts — fuera
   ║                                                           ║     de la VPC)
   ║                  │ output opcional                        ║
   ║                  ▼                                        ║
   ║         ┌──────────────────┐                              ║
   ║         │ S3 (OPCIONAL):   │  ← outputs de jobs           ║
   ║         │ dkron-outputs    │                              ║
   ║         └──────────────────┘                              ║
   ║                                                           ║
   ║   ┌──────────────────┐         ┌────────────────┐         ║
   ║   │ ECS Fargate      │◀────────│ ECS Fargate    │         ║
   ║   │ Service:         │  query  │ Service:       │         ║
   ║   │ Prometheus       │         │ Grafana        │         ║
   ║   │ + Alertmanager   │         │ (dashboards)   │         ║
   ║   │ EFS persistente  │         │ EFS persistente│         ║
   ║   └────────┬─────────┘         └────────┬───────┘         ║
   ║            │ scrape /metrics (file_sd → IP privada de EC2)║
   ║            │ alerts                     │                 ║
   ╚════════════┼════════════════════════════┼═════════════════╝
                │                            │
                ▼                            ▼ (vía ALB interno)
        ┌──────────────┐             ┌───────────────┐
        │  SNS Topic   │──▶ 📧 Email │  Tu navegador │
        │ dkron-alerts │              │ → Grafana UI  │
        └──────────────┘             └───────────────┘

   Plataforma lateral (fuera de la VPC):
     ECR (mirror de la imagen oficial dkron/dkron)
     CloudWatch Logs (logs de Dkron, Prometheus, Grafana)
     SSM Parameter Store (URL del repo ECR, password de Grafana)

   GitHub  ──────▶  GitHub Actions ──────▶  AWS (vía OIDC, sin keys)
                       │
                       ├─ Validate (fmt, validate, tflint, Checkov, ansible-lint)
                       ├─ Replicate image:  Docker Hub → ECR
                       ├─ Trivy scan
                       ├─ Plan (en PRs)
                       ├─ Apply (Terraform en main, gateado por aprobación manual)
                       └─ Deploy (ansible-playbook deploy.yml — pull imagen + restart compose)
```

> 📝 **Cómo se mapea esta topología al PDF — para el reporte sección A:**
> - **Operador, ALB, server, agent (opcional), persistencia (BoltDB en EBS por restricción de Dkron OSS — ver PARTE 9.2), ECR mirror y S3 opcional** vienen del diagrama de página 11 del PDF y son la base no negociable.
> - **EC2 + Docker Compose + Ansible** es nuestra elección dentro de la "Opción B" del PDF 5.2 (cómputo y red): el diagrama del PDF no obliga a Fargate, EC2 ni EKS — la elección es del proyecto y queda justificada en la PARTE 9.
> - **Prometheus + Grafana en ECS Fargate (Camino 1 del PDF 5.4 "Observabilidad")** es nuestra interpretación del bloque "Logs y métricas (camino a elegir)" que aparece etiquetado así en la topología del PDF.
> - **S3 dkron-outputs** queda como opcional siguiendo la nota del PDF página 10 ("(Opcional) Storage S3 para los outputs"). Si decides no usarlo, lo retiras del diagrama y lo justificas en el reporte.

> **Por qué ANSIBLE entra en este Caso D:** elegimos la **Opción B** del PDF (sección 5.2): EC2 + Docker Compose desplegado por Ansible. Terraform crea la EC2 y el resto de AWS; **Ansible configura el interior** de esa máquina (instala Docker, copia el `docker-compose.yml`, levanta los containers, hace `docker pull` en cada deploy). Esto te da contenido **real** y concreto para el concepto B.1 del reporte ("IaC vs gestión de configuración") — porque vas a usar las dos herramientas en el mismo proyecto, cada una en su capa.

**Promesa:** al terminar, tendrás esta infraestructura corriendo, código en Git, pipeline automático, alertas funcionando. Sin haber tocado un solo servidor físico.

## ❓ 1.3 ¿Qué entregables debo producir?
1. **Repositorio en GitHub** con la estructura sugerida.
2. **REPORTE.md** (2.000–5.000 palabras, escrito por ti SIN IA).
3. **docs/runbook.md** (procedimientos operativos).
4. **Evidencias** (capturas en README.md o `docs/evidencias.md`).
5. **Video de 10 min** (opcional pero recomendado).

## ❓ 1.4 ¿Cómo me van a evaluar?
- **Reporte técnico: 45%** ← lo que más pesa
- CI/CD: 25%
- Containerización y despliegue: 20%
- Observabilidad: 10%

**Conclusión:** un buen reporte vale más que un código brillante. Invierte tiempo escribiéndolo.

---

<a id="parte-2"></a>
# PARTE 2 — Los conceptos que necesitas dominar antes de tocar AWS

> Esta parte es teórica. Sí, es larga. **Sin esto, cometerás errores caros.** Lee con calma. Si no entiendes algo a la primera, vuelve a leerlo después.

## ❓ 2.1 ¿Qué es un container y por qué Docker?
Un **container** es una caja que empaqueta una aplicación con todo lo que necesita (librerías, runtime, configuración). Lo bueno: corre igual en tu laptop, en AWS o en Marte.

**Imagen** = la receta (`dkron/dkron:v4.0.9`). **Container** = la receta corriendo.

**Regla del bootcamp:** NO se permite hacer fork de Dkron ni modificar su código. Usa la imagen oficial.

> 📝 **Nota sobre la licencia de Dkron — para tu reporte sección A:** Dkron está liberado bajo **LGPL-3.0**. El PDF (final de sección 2, "Si se propone una aplicación distinta") exige licencia permisiva (MIT/Apache 2.0/BSD/MPL 2.0) **solo si propones una aplicación distinta** a las cuatro recomendadas. Como Dkron ES una de las recomendadas explícitamente por el bootcamp (Caso D), su licencia ya fue validada por el material y no necesitas justificarla. LGPL-3.0 es weak copyleft: nos cubre porque (a) no modificamos el código de Dkron — lo operamos como container; (b) no enlazamos estáticamente con su código en nuestros propios binarios. Si el evaluador pregunta, esa es la respuesta corta.

**Práctica fundamental:** **pinnea** la versión. NUNCA uses `:latest`. Usa `dkron/dkron:v4.0.9`. Si usas `latest`, mañana puede cambiar y producción rompe sin que nadie lo decida.

### 🧠 Analogía: Docker es como una caja de Lego prearmada
Si tu programa es un castillo, sin Docker tienes que armar el castillo cada vez en cada laptop. Con Docker, alguien armó el castillo, lo metió en una caja sellada (imagen), y tú solo "abres la caja" (`docker run`) en cualquier máquina con Docker.

## ❓ 2.2 ¿Qué es Infraestructura como Código (IaC) y qué es Terraform?
En vez de hacer clic en la consola de AWS para crear servidores (eso es **clickops** — está mal visto), escribes archivos `.tf` que **describen** la infraestructura. Luego corres `terraform apply` y Terraform crea todo.

Ventajas: el código vive en Git, es revisable, reproducible, `terraform destroy` borra todo limpio.

**Ejemplo mínimo** (no copies, entiende):
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "dkron-vpc"
    Project     = "dkron"
    Environment = "prod"
    Owner       = "tu-nombre"
    ManagedBy   = "Terraform"
  }
}
```
Esos **tags** son obligatorios (sección 5.1 del PDF). Si los olvidas, pierdes puntos.

## ❓ 2.3 ¿Qué diferencia hay entre IaC (Terraform) y gestión de configuración (Ansible)?
- **IaC (Terraform):** crea **recursos** en la nube (VPCs, máquinas, BDs, IAM, security groups). Responde la pregunta **"¿qué infraestructura existe?"**.
- **Gestión de configuración (Ansible):** configura el **interior** de una máquina ya creada (instalar paquetes, copiar archivos, arrancar servicios). Responde **"¿cómo está esa máquina por dentro?"**.

**En este Caso D vas a usar las DOS** (concepto B.1 del reporte). Esa fue la razón exacta por la que el PDF (sección 5.2) ofrece la **Opción B: EC2 + Docker Compose desplegado por Ansible** — para que practiques la separación de capas.

```
   Capa                 Herramienta   Qué crea/configura
   ─────────────────    ───────────   ──────────────────────────────────
   Infraestructura      Terraform     VPC, subnets, EC2 (+ volumen EBS
   (afuera de la VM)                  para BoltDB), ALB, ECR, IAM,
                                      security groups, ECS Fargate
                                      (Prom/Grafana), SSM Parameters
   ─────────────────    ───────────   ──────────────────────────────────
   Configuración        Ansible       Docker engine, docker-compose.yml,
   (dentro de la VM)                  variables de entorno desde SSM,
                                      pull de la imagen, up/restart de
                                      los containers, healthcheck post-
                                      deploy
```

**Regla mental:** si lo que cambias se ve desde la consola de AWS (un recurso), va en Terraform. Si lo que cambias solo se ve haciendo `ssh` a la máquina, va en Ansible. Esta frontera la repites varias veces en el reporte; tenla clara.

**¿Y por qué no hacer todo con Terraform usando `user_data`?** Sí se puede, pero `user_data` corre **una sola vez** al primer arranque de la EC2. Ansible se ejecuta **cada vez que despliegas**: cuando hay una imagen nueva, vuelves a correr el playbook y solo cambia lo que necesita cambiar (idempotencia). Esa diferencia la justificas en el reporte.

## ❓ 2.4 ¿Qué es CI/CD?
- **CI (Continuous Integration):** cada `git push` corre validaciones (¿el Terraform es válido? ¿hay vulnerabilidades?).
- **CD (Continuous Delivery):** el sistema **prepara** el deploy y queda listo para aprobar manualmente.
- **CD (Continuous Deployment):** el sistema **despliega solo**, sin aprobación humana.

El proyecto pide **Continuous Delivery** (apply gateado por aprobación manual — sección 5.3, punto 5).

## ❓ 2.5 ¿Qué es SLI, SLO y error budget?
- **SLI (Service Level Indicator):** métrica que mide salud del servicio. Ej: "% de jobs que se ejecutan en sus primeros 30s".
- **SLO (Service Level Objective):** objetivo numérico para esa métrica. Ej: "el 99% en un mes".
- **Error budget:** el complemento. SLO 99% → budget 1% de errores tolerables.

Para Dkron:
- **SLO 1 (drift):** "99% de jobs ejecutan dentro de 30s de su horario, en 7 días".
- **SLO 2 (éxito):** "95% de jobs terminan en `success`, en 24h".

## ❓ 2.6 ¿Qué es VPC, subnet pública/privada, ALB?
- **VPC:** tu red privada en AWS. Como tu propia LAN.
- **Subnet pública:** con salida a Internet. Aquí va el ALB.
- **Subnet privada:** sin salida directa. Aquí va Dkron y la BD. Más seguro.
- **ALB (Application Load Balancer):** balanceador HTTP. Recibe Internet → Dkron.

**Diagrama mental del Caso D (basado en la topología sugerida del PDF, página 11):**
```
Operador
  │ REST · UI
  ▼
ALB (subnet pública)
  │ forward
  ▼
┌─ Subnet privada ───────────────────────────────────────────┐
│  Dkron:                                                    │
│    Server (scheduler) ──dispatch──▶ Agent (executor)       │
│        │                              opcional · puede ser │
│        │ state                        el mismo nodo        │
│        ▼                                  │                │
│    BoltDB embebido (vol EBS gp3)          │ ejecución      │
│    /var/lib/dkron-data en la EC2          │                │
│    → /dkron.data dentro del container     │                │
└───────────────────────────────────────────┼────────────────┘
                                            │
       Targets de los jobs (HTTP, scripts)  ◀─ fuera de la VPC
       S3 dkron-outputs                     ◀─ opcional, lo escribe el agent

Plataforma lateral: ECR (mirror) · CloudWatch Logs · SSM Parameter Store
```
**Lectura rápida**: solo el ALB es público; server y agent viven en privada; el estado vive en BoltDB local sobre un volumen EBS encriptado en la propia EC2 (no hay BD externa); los targets (lo que Dkron ejecuta) son externos por naturaleza — esa frontera la respetamos con un security group de egreso explícito.

## ❓ 2.7 ¿Qué es ECR y por qué replicar la imagen?
**ECR (Elastic Container Registry)** es Docker Hub privado de AWS. La sección 3 dice: **replica la imagen oficial de Dkron a tu ECR**. Razón: si Docker Hub se cae o cambian políticas, tu producción no depende de un tercero.

```bash
docker pull dkron/dkron:v4.0.9
docker tag dkron/dkron:v4.0.9 123456789.dkr.ecr.us-east-1.amazonaws.com/dkron:v4.0.9
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/dkron:v4.0.9
```

Esto lo automatizarás en el pipeline.

> 📝 **Aviso del PDF (sección 3, Aviso "Replicación recomendada a ECR"):** *"Esta replicación se documenta en el reporte como una decisión consciente."* Significa que en la sección A del reporte tienes que escribir explícitamente: "elegí replicar la imagen oficial a un ECR propio en vez de consumirla directamente desde Docker Hub porque [...]". El "porque" debe mencionar al menos: rate-limits de Docker Hub para usuarios anónimos, riesgo de que el upstream borre o re-etiquete una versión, y que el deploy de la EC2 no depende de un servicio externo a AWS.

## ❓ 2.8 ¿Qué es ECS Fargate vs EC2 vs EKS?
- **ECS Fargate:** AWS corre tu container, tú no manejas máquinas. Más simple, NO usa Ansible.
- **EC2 con Docker Compose + Ansible:** tú alquilas una máquina, **Ansible** instala Docker, copia el compose, arranca los containers. Más control, más trabajo, **es lo que pide la Opción B del PDF y lo que vamos a hacer aquí para Dkron**.
- **EKS (Kubernetes):** orquestación industrial, gran complejidad. No para principiante.

**Decisión de este Caso D — arquitectura híbrida (justifícala en el reporte sección A):**

| Componente            | Cómputo elegido                | Por qué                                                                 |
|-----------------------|--------------------------------|-------------------------------------------------------------------------|
| **Dkron**             | **EC2 + Docker Compose + Ansible** | Cumple Opción B del PDF; da contenido real al concepto B.1 del reporte (IaC vs gestión de config) y al B.2 ("containerización vs EC2+Ansible") porque experimentamos las dos rutas. |
| Prometheus + Grafana  | ECS Fargate                    | No requieren imagen nueva en cada deploy de Dkron; Fargate los simplifica y libera al estudiante de instalar Prom/Grafana también con Ansible. |

> **Trade-off honesto que vas al reporte:** mantener dos modelos de cómputo en el mismo proyecto **añade complejidad operativa** (dos formas de hacer "deploy", dos formas de leer logs, dos formas de hacer rollback). Lo aceptamos porque la sección B del reporte pide diferenciar IaC vs gestión de configuración con aplicación concreta — sin EC2+Ansible, esa diferenciación es teórica.

> 📝 **Sobre cache/cola en el Caso D — del PDF sección 5.2:** *"Cache o cola según el escenario, vía ElastiCache Redis o SQS"*. Para el **Caso D (Dkron)**, ElastiCache/SQS **no son requisitos** — Dkron no necesita cache distribuido ni cola de eventos para operar. La persistencia es **BoltDB embebido en la propia EC2** (sobre un volumen EBS encriptado). Esto es distinto del Caso A (Shlink puede usar Redis para cache), Caso B (Convoy requiere Redis o SQS para cola) y Caso C (imgproxy puede usar S3 cache). En el reporte sección A, cuando hagas el bloque "qué se eligió por componente", para "cache/cola" anota: *"No aplica al Caso D — Dkron no necesita componente asíncrono separado; la persistencia y la cola interna de jobs viven en el BoltDB embebido del propio binario, sobre un volumen EBS de la EC2."*

## ❓ 2.9 ¿Qué es un Security Group?
Un **firewall virtual** alrededor de un recurso. Define qué puertos están abiertos y desde dónde. Ej: el SG-app de la EC2 con Dkron solo acepta puerto 8080 desde el SG del ALB, nadie más.

## ❓ 2.10 ¿Qué es IAM y "mínimo privilegio"?
**IAM (Identity and Access Management)** maneja quién puede hacer qué en AWS. **Mínimo privilegio** = darle a cada componente solo los permisos que necesita. Si tu Task Role solo necesita leer un parameter de SSM, no le des `*:*`.

## ❓ 2.11 ¿Qué es Ansible y por qué lo necesito ahora?

**Ansible** es la herramienta de **gestión de configuración** que ejecuta tareas en máquinas remotas vía SSH (o WinRM en Windows). No tiene agente: tú corres `ansible-playbook` desde tu laptop o desde el runner de CI, y Ansible se conecta a la máquina objetivo, ejecuta los pasos descritos en YAML, y se desconecta.

**Conceptos mínimos que vas a usar:**

| Término             | Qué es                                                                                  |
|---------------------|------------------------------------------------------------------------------------------|
| **Inventario**      | Lista de las máquinas que vas a configurar. En este proyecto es **dinámico**: el plugin `aws_ec2` consulta a AWS por las EC2 con tag `Project=dkron` y arma la lista solo. |
| **Playbook**        | Archivo YAML con la secuencia de tareas. Ej: `deploy.yml` hace pull de la imagen y restart del compose. |
| **Rol**             | Carpeta con tareas reutilizables (tasks, handlers, templates, defaults). Vamos a tener `roles/docker/` y `roles/dkron-compose/`. |
| **Tarea (task)**    | Una unidad atómica: `apt: name=docker-ce state=present`. Cada tarea usa un **módulo** (apt, copy, template, docker_compose_v2, etc.). |
| **Handler**         | Tarea que solo corre si otra tarea la "notifica". Útil para "restart docker si cambió daemon.json". |
| **Idempotencia**    | Correr el playbook 1 vez o 10 veces deja la máquina en el mismo estado. Ansible lo logra: si el paquete ya está instalado, no hace nada. |
| **Vault**           | Cifrado simétrico para secretos en YAML. **Nosotros no lo usamos** — los secretos viven en SSM Parameter Store y los lee Ansible al ejecutar (regla del PDF 5.5: sin secretos en el repo). |

**Cómo se relaciona con lo que YA sabes:**

```
   Lo que ya hiciste                  Lo que Ansible automatiza
   ──────────────────                 ──────────────────────────
   En Parte 3 corriste a mano:        En AWS, Ansible va a hacer
                                       lo MISMO sobre la EC2:
   $ docker compose up -d              ─→ docker_compose_v2 module
                                          state=present
   Editaste .env con vars              ─→ template module renderiza
                                          .env desde variables
                                          + lookups de SSM
   Hiciste docker pull cuando          ─→ docker_compose_v2 con
   actualizaste                           pull=always en deploy
```

**Cuándo NO usar Ansible:** para tareas one-shot del día 0 (formateo de disco, primer boot) `user_data` de Terraform basta. Para tareas recurrentes que van a correr **cada deploy** (pull de imagen nueva, copiar compose actualizado, reiniciar containers), Ansible es la herramienta correcta — porque es **idempotente** y porque vive en **el mismo repo** que el código.

**Cómo lo vas a invocar (spoiler de la PARTE 6):**
```bash
cd ansible
ansible-playbook -i inventories/prod/aws_ec2.yml playbooks/deploy.yml \
  --extra-vars "dkron_image_tag=v4.0.9"
```

**Concepto B.1 del reporte (IaC vs gestión de configuración) — guion para tu reflexión:**
> "En este proyecto Terraform y Ansible no compiten, se complementan. Terraform crea la EC2 (con su volumen EBS para BoltDB), IAM, security groups, ALB y ECR — todo lo que vive en AWS. Ansible entra después, vía SSM Session Manager a la EC2 ya creada, e instala Docker, sube el `docker-compose.yml` y hace `docker compose up -d`. Si llega una versión nueva de Dkron, no toco Terraform: corro de nuevo el playbook de Ansible y se actualiza solo lo necesario, sin recrear la EC2 ni perder el archivo BoltDB."

> ✅ **Local + teoría: hecho.** A partir de aquí entras a la **fase producción AWS**. Las próximas partes (4 → 5 → 6 → 7 → 8) construyen el mismo Dkron que probaste en local, pero en AWS: bootstrap, infra Terraform, Ansible, CI/CD, observabilidad. Mismo orden copy-paste e incremental.

---

<a id="parte-4"></a>
# PARTE 4 — Configurar AWS y la base del repositorio

## ❓ 4.1 ¿Cómo creo mi cuenta AWS?
1. Ve a [aws.amazon.com](https://aws.amazon.com) → **Create an AWS Account**.
2. Te pide tarjeta de crédito (es solo verificación si te quedas en Free Tier).
3. **ACTIVA MFA EN LA CUENTA ROOT INMEDIATAMENTE.** Console → tu nombre arriba → Security Credentials → MFA → Add device. Usa Google Authenticator.
4. **Configura el alerta de billing** (vista en 0.3): Budget de $10/mes con email a 80%.

## ❓ 4.2 ¿Por qué no uso la cuenta root para trabajar?
Porque si te roban las credenciales, te queman la cuenta. La cuenta root es como las llaves del banco: solo se usa para emergencias.

### Crea un usuario IAM:
1. Console AWS → **IAM** → **Users** → **Create user** → nombre: `dev-tu-nombre`.
2. Marca **Provide user access to the AWS Management Console**, password autogenerada.
3. Adjunta política directamente: `PowerUserAccess` (suficiente para este proyecto).
4. Termina la creación.
5. Para esa misma user → **Security credentials** → **Create access key** → "Command Line Interface (CLI)". Descarga el CSV. **Guárdalo seguro** (1Password, BitWarden, lo que uses).

### Configura AWS CLI:
```bash
aws configure
# AWS Access Key ID:     AKIA...
# AWS Secret Access Key: ...
# Default region:        us-east-1
# Default output:        json
```

Verifica:
```bash
aws sts get-caller-identity
```
Salida esperada:
```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/dev-tu-nombre"
}
```

## 💥 Errores típicos en la PARTE 4

### Error 4.A: "An error occurred (InvalidClientTokenId) when calling the GetCallerIdentity operation"
**Causa:** tus credenciales son incorrectas o expiraron.
**Solución:** `aws configure` de nuevo. Verifica que copiaste bien sin espacios.

### Error 4.B: Te aparece tu cuenta root en `get-caller-identity` y no el IAM user
**Causa:** olvidaste hacer `aws configure` después de crear el user, y AWS CLI usa otro perfil.
**Solución:**
```bash
aws configure list   # mira qué perfil estás usando
aws configure        # reescribe credenciales del IAM user
```

### Error 4.C: Le diste `AdministratorAccess` al IAM user en vez de `PowerUserAccess`
**Causa:** confundiste las políticas.
**Solución:** no es crítico para el proyecto (PowerUser es muy parecido), pero buena práctica: usa la mínima.

## ❓ 4.3 ¿Qué es el "state remoto en S3" y por qué lo necesito?
Terraform guarda el estado en `terraform.tfstate`. Si lo guardas en tu laptop:
- Lo puedes perder.
- Si trabajas en equipo, dos personas lo corrompen.

**Solución:** lo guardas en un bucket S3 con **locking**. Antes de `apply`, Terraform pone un lock; cuando termina, lo libera. Dos `apply` simultáneos no chocan.

### ❗ Pregunta clave del reporte (B.6): ¿Qué pasa si dos `apply` corren sin lock?
Ambos leen el state "antes", calculan cambios, aplican, y el último que escribe pisa al otro. Resultado: recursos creados sin estar en el state ("huérfanos"), o el state apunta a recursos inexistentes. Recuperarse requiere `terraform import` recurso por recurso. **Por eso el lock es obligatorio.**

### 🖱️ Equivalente en AWS Console (lo que harías click-a-click)

> El `bootstrap.sh` ejecuta **5 pasos** sobre el mismo bucket. Aquí los desglosamos 1:1 para que puedas reproducirlos a mano en la consola y comprobar **exactamente** lo que hace el script.

| Paso del script | Recurso | Servicio | Que harías en consola |
|---|---|---|---|
| 1) `create-bucket` | Bucket S3 | 🪣 S3 | **S3 → Buckets → Create bucket** → AWS Region: `us-east-1` → Bucket name: `tfstate-dkron-tunombre-2026` → Object Ownership: ACLs disabled → Create bucket. |
| 2) `put-bucket-versioning` | Versioning del bucket | 🪣 S3 | El bucket → pestaña **Properties → Bucket Versioning → Edit → Enable → Save changes**. |
| 3) `put-bucket-encryption` | Default encryption | 🪣 S3 | El bucket → **Properties → Default encryption → Edit** → Encryption type: **Server-side encryption with Amazon S3 managed keys (SSE-S3 / AES-256)** → Bucket Key: Enable → Save changes. |
| 4) `put-public-access-block` | Block public access | 🪣 S3 | El bucket → **Permissions → Block public access (bucket settings) → Edit** → marca **las 4 opciones**: BlockPublicAcls, IgnorePublicAcls, BlockPublicPolicy, RestrictPublicBuckets → Save changes → escribe `confirm`. |
| 5) `put-bucket-tagging` | Tags del bucket | 🪣 S3 | El bucket → **Properties → Tags → Add new tag** (4 veces) → `Project=dkron`, `Environment=prod`, `Owner=tunombre`, `ManagedBy=bootstrap.sh` → Save changes. |

> 🧠 **Concepto:** este bucket es **el huevo del que sale Terraform**. No lo gestionamos con Terraform (paradoja "gallina y huevo"), por eso lo creamos antes con un script `bootstrap.sh`. Tampoco lo elimina `terraform destroy` — lo documentamos en el runbook (Parte 10).

### 📋 Script copy-paste: `infra/bootstrap.sh`

Crea la carpeta `infra/` y dentro pega este script tal cual. Es **idempotente**: lo puedes correr varias veces y solo crea lo que falte.

```bash
mkdir -p infra
```

Crea `infra/bootstrap.sh` con este contenido exacto:

```bash
#!/usr/bin/env bash
# infra/bootstrap.sh
# Crea (si no existen) los recursos previos a Terraform:
#  - Bucket S3 para el state remoto, con versioning + encryption + public-access-block.
# Idempotente: corres este script tantas veces como quieras, no rompe nada.
#
# Uso:
#   chmod +x infra/bootstrap.sh
#   ./infra/bootstrap.sh

set -euo pipefail

# ─── Variables (edítalas) ─────────────────────────────────────────────────────
PROJECT="dkron"
OWNER="tunombre"                          # ← cámbialo, debe ser único globalmente
SUFFIX="2026"                             # ← entropía adicional
REGION="us-east-1"
BUCKET="tfstate-${PROJECT}-${OWNER}-${SUFFIX}"

echo "🪣 Asegurando bucket de state: ${BUCKET} en ${REGION}"

# 1) Crear bucket si no existe (us-east-1 no acepta LocationConstraint)
if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "   ↳ ya existe, salto creación"
else
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}"
  echo "   ↳ creado"
fi

# 2) Versioning (obliga a tener historial del state para recovery)
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

# 3) Encryption en reposo (AES256 nativo de S3 — sin coste, sin KMS extra)
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

# 4) Bloquear todo acceso público (es state secreto, nunca debe filtrarse)
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5) Tags consistentes (para FinOps y para el requisito PDF 5.1)
aws s3api put-bucket-tagging \
  --bucket "${BUCKET}" \
  --tagging "TagSet=[
    {Key=Project,Value=${PROJECT}},
    {Key=Environment,Value=prod},
    {Key=Owner,Value=${OWNER}},
    {Key=ManagedBy,Value=bootstrap.sh}
  ]"

echo "✅ Bucket listo: ${BUCKET}"
echo ""
echo "📝 Anota este valor para usarlo en infra/envs/prod/backend.tf:"
echo "   bucket = \"${BUCKET}\""
```

Hazlo ejecutable y córrelo:

```bash
chmod +x infra/bootstrap.sh
./infra/bootstrap.sh
```

Salida esperada (primera vez):
```
🪣 Asegurando bucket de state: tfstate-dkron-tunombre-2026 en us-east-1
   ↳ creado
✅ Bucket listo: tfstate-dkron-tunombre-2026

📝 Anota este valor para usarlo en infra/envs/prod/backend.tf:
   bucket = "tfstate-dkron-tunombre-2026"
```

Salida esperada (segunda vez — verifica idempotencia):
```
🪣 Asegurando bucket de state: tfstate-dkron-tunombre-2026 en us-east-1
   ↳ ya existe, salto creación
✅ Bucket listo: tfstate-dkron-tunombre-2026
```

> 📝 **Anota el nombre exacto del bucket; lo usarás en `infra/envs/prod/backend.tf`.**

### 💥 Error 4.D: "BucketAlreadyExists"
**Causa:** los nombres de bucket S3 son globales (en todo el mundo). Alguien ya lo usó.
**Solución:** edita `OWNER` o `SUFFIX` en `bootstrap.sh` con más entropía: `OWNER="juanperez-aBc1d"` y vuelve a correr.

### 💥 Error 4.E: "Could not connect to the endpoint URL"
**Causa:** `aws configure` no quedó con la región `us-east-1` o tus credenciales caducaron.
**Solución:**
```bash
aws configure get region        # debe decir us-east-1
aws sts get-caller-identity     # debe devolver tu IAM user
```

## ❓ 4.4 ¿Cómo organizo el repositorio?

> 💡 **Filosofía de la estructura:** separamos **lo que define un entorno** (`infra/envs/prod/`) de **lo reutilizable** (`infra/modules/`). Si mañana quieres `staging`, copias `envs/prod` a `envs/staging` y reutilizas los mismos módulos. Es el patrón estándar de Terraform a escala.

### 🖱️ Equivalente en AWS Console
*(no aplica — esta sección es solo organización de tu repo en GitHub)*

```bash
cd ~/proyectos/dkron-aws
gh repo create dkron-aws --public --source=. --remote=origin
```

### 📋 Comandos copy-paste para crear el árbol vacío

```bash
# Carpetas Terraform (infra/envs/prod + 6 módulos)
mkdir -p infra/envs/prod
mkdir -p infra/modules/network
mkdir -p infra/modules/ecr
mkdir -p infra/modules/storage
mkdir -p infra/modules/compute
mkdir -p infra/modules/monitoring/dashboards
mkdir -p infra/modules/cicd

# Carpeta compose para probar en local (Parte 3)
mkdir -p compose/prometheus compose/alertmanager
mkdir -p compose/grafana/provisioning/datasources
mkdir -p compose/grafana/provisioning/dashboards
# Nota: el JSON del dashboard vive junto al provider en provisioning/dashboards/,
# así un único mount (./grafana/provisioning) basta. No hace falta compose/grafana/dashboards.

# Carpetas Ansible (PARTE 6)
mkdir -p ansible/inventories/prod/group_vars
mkdir -p ansible/roles/docker/{tasks,handlers,defaults,meta}
mkdir -p ansible/roles/dkron-compose/{tasks,handlers,templates,defaults,files}
mkdir -p ansible/playbooks

# Docs + workflows
mkdir -p docs .github/workflows

# Archivos vacíos del entorno prod
touch infra/envs/prod/versions.tf
touch infra/envs/prod/backend.tf
touch infra/envs/prod/variables.tf
touch infra/envs/prod/terraform.tfvars.example
touch infra/envs/prod/main.tf
touch infra/envs/prod/outputs.tf

# bootstrap.sh ya lo creaste en 4.3. Toca crear bootstrap-oidc.sh (PARTE 7)
touch infra/bootstrap-oidc.sh

# Docs raíz
touch docs/arquitectura.md docs/runbook.md docs/evidencias.md
touch REPORTE.md README.md
```

### 📁 Árbol final que vas a construir

```
dkron-aws/
├── compose/                            # Probar en tu laptop (PARTE 3)
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── prometheus/{prometheus.yml,rules.yml}
│   ├── alertmanager/alertmanager.yml
│   └── grafana/provisioning/{datasources,dashboards}/...
│
├── infra/                              # Terraform — la capa "afuera de la VM"
│   ├── bootstrap.sh                    # 4.3 — crea el bucket S3 del state
│   ├── bootstrap-oidc.sh               # 7.1 — crea OIDC provider + rol GHA
│   │
│   ├── envs/
│   │   └── prod/                       # único entorno (PDF 4: un solo entorno)
│   │       ├── versions.tf             # 5.1.1 versiones de Terraform + providers
│   │       ├── backend.tf              # 5.1.2 backend S3 con use_lockfile
│   │       ├── variables.tf            # 5.1.3 variables del entorno
│   │       ├── terraform.tfvars.example # 5.1.4 plantilla versionada
│   │       ├── terraform.tfvars        # 5.1.4 (gitignored: secretos reales)
│   │       ├── main.tf                 # 5.1.5 instancia los 6 módulos
│   │       └── outputs.tf              # 5.1.6 outputs que consume Ansible
│   │
│   └── modules/                        # 5 módulos propios (PDF 5.1: mín. 2)
│       ├── network/                    # 5.2 — VPC + 2 pub + 2 priv + IGW + NAT
│       ├── ecr/                        # 5.3 — Repositorio ECR (mirror)
│       │                               # 5.4 — (eliminado: NO hay módulo storage;
│       │                               #        persistencia local en BoltDB/EBS,
│       │                               #        ver PARTE 5.4 y PARTE 9.2)
│       ├── compute/                    # 5.5 — EC2 + ALB + SGs + IAM
│       ├── monitoring/                 # 5.7/Parte 8 — Prom + Grafana en Fargate
│       │   └── dashboards/dkron-red.json
│       └── cicd/                       # 7.1 — OIDC + role GHA (opcional Terraform-managed)
│
├── ansible/                            # Ansible — la capa "dentro de la VM" (PARTE 6)
│   ├── ansible.cfg
│   ├── requirements.yml
│   ├── inventories/prod/
│   │   ├── aws_ec2.yml                 # plugin dinámico (tag Project=dkron)
│   │   └── group_vars/all.yml
│   ├── roles/
│   │   ├── docker/                     # instala docker-ce + plugin compose v2
│   │   └── dkron-compose/              # despliega el compose en la EC2
│   └── playbooks/
│       ├── site.yml                    # bootstrap completo
│       └── deploy.yml                  # deploy incremental
│
├── .github/workflows/
│   ├── ci-cd.yaml                      # PARTE 7
│   └── destruir.yaml                   # PARTE 7
│
├── docs/{arquitectura,runbook,evidencias}.md
├── REPORTE.md
├── README.md
└── .gitignore
```

### 🧭 Lectura del árbol (una frase por carpeta)

| Carpeta | Qué hace | Cuándo se ejecuta |
|---|---|---|
| `infra/bootstrap.sh` | Crea bucket S3 del state | **Una sola vez**, antes de Terraform |
| `infra/bootstrap-oidc.sh` | Crea OIDC provider + rol GHA | **Una sola vez**, antes del primer CI |
| `infra/envs/prod/` | "Compone" el entorno prod usando los módulos | Cada `terraform apply` |
| `infra/modules/` | Lego reutilizable | Solo se referencia, no se aplica directo |
| `ansible/` | Configura **dentro** de la EC2 que Terraform creó | Después de `terraform apply` |
| `compose/` | Probar Dkron en tu laptop | Solo en local (Parte 3) |
| `.github/workflows/` | Orquesta apply + deploy | En cada push a main |

### 📋 `.gitignore` (copy-paste)

Crea `.gitignore` en la raíz con este contenido:

```gitignore
# Terraform
**/.terraform/
**/.terraform.lock.hcl
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfplan
*.tfvars
!*.tfvars.example
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# Ansible
*.retry
ansible/.vault_pass

# Secrets / credenciales
.env
!.env.example
*.pem
*.key
!ansible/roles/*/files/*.pub

# IDEs
.vscode/
.idea/
*.swp
.DS_Store

# Python (ansible-lint cache)
__pycache__/
*.pyc
.venv/
```

> 🔐 **Detalle clave:** `*.tfvars` está ignorado pero `*.tfvars.example` no — así versionas la **plantilla** pero nunca los **valores reales** (password de Grafana, etc.).

### 📌 Cumplimiento PDF 5.1

- ✅ "Mínimo 2 módulos propios" → tenemos **5** (network, ecr, compute, monitoring, cicd). El módulo `storage/` se eliminó cuando descubrimos que Dkron OSS no soporta backend Postgres — ver PARTE 5.4 y 9.2.
- ✅ "State remoto en S3 con locking" → `backend.tf` con `use_lockfile = true` (S3-native lock, no DynamoDB).
- ✅ "Tags obligatorios" → `default_tags` en el provider (5.1.1).
- ✅ "Sin recursos huérfanos en destroy" → el bucket S3 y el OIDC viven fuera del state (creados por `bootstrap*.sh`); todo lo que crea Terraform lo destruye Terraform.

### 🚀 Primer commit

```bash
git add .
git commit -m "estructura inicial del repo con envs/prod + 6 módulos"
git push -u origin main
```

---

<a id="parte-5"></a>
# PARTE 5 — Construir la infraestructura con Terraform

> En esta parte vas a escribir Terraform desde cero. La sección 5.1 dice "código nuevo, organizado en módulos propios". No copies-pegues los talleres del bootcamp, úsalos solo como referencia.

## 🗺️ Diagrama: la arquitectura AWS completa con security groups

> 📐 **Base de este diagrama:** topología sugerida del Escenario D (PDF página 11). Mantenemos sus componentes obligatorios — ALB en pública, server + agent (opcional) en privada, **persistencia local en BoltDB sobre EBS** (Dkron OSS no soporta el flag Postgres — ver PARTE 9.2), ECR mirror, S3 outputs opcional, targets externos — y le añadimos el detalle de security groups que el PDF deja explícitamente como decisión del proyecto (cita del propio PDF, sección 2: *"los detalles operativos (cantidad de réplicas, esquemas de IAM, security groups, tags, configuración del ALB, dimensionamiento de la base de datos) se diseñan y justifican como parte del proyecto"*).

```
                            INTERNET (0.0.0.0/0)
                                    │
                                    │ :80 (Dkron)   :3000 (Grafana, opcional)
                                    ▼
                      ╔═══════════════════════════╗
                      ║   ALB (subnet pública)    ║
                      ║   listeners 80, 3000      ║
                      ║   SG-alb:                 ║
                      ║   ingress ← 0.0.0.0/0     ║
                      ╚═════════════╤═════════════╝
                                    │ forwards a target groups
                                    ▼
   ┌─────────────────────────────────────────────────────────────────┐
   │ VPC 10.20.0.0/16                                                │
   │                                                                 │
   │  ┌──────────────────┐     ┌────────────────────────────────┐    │
   │  │ subnets públicas │     │ subnet privada-a 10.20.10.0/24 │    │
   │  │ a: 10.20.0.0/24  │     │                                │    │
   │  │ b: 10.20.1.0/24  │     │  ╔═════════════════════════╗   │    │
   │  │  [Internet GW]   │     │  ║ EC2 (t3.micro) — Dkron  ║   │    │
   │  │  [NAT Gateway]──┐│     │  ║  Docker Compose v2:     ║   │    │
   │  │  [ALB]          ││     │  ║   • dkron-server :8080  ║   │    │
   │  └─────────────────┼┘     │  ║       (scheduler)       ║◀──┼─┐  │
   │                    │      │  ║   • dkron-agent         ║   │ │  │
   │                    │      │  ║       OPCIONAL · mismo  ║   │ │  │
   │                    │      │  ║       proceso o aparte  ║   │ │  │
   │                    │      │  ║   • node_exporter :9100 ║   │ │  │
   │                    │      │  ║  cfg por ANSIBLE (SSM)  ║   │ │  │
   │                    │      │  ║  SG-app                 ║   │ │  │
   │                    │      │  ║                         ║   │ │  │
   │                    │      │  ║  Persistencia:          ║   │ │  │
   │                    │      │  ║   BoltDB embebido en    ║   │ │  │
   │                    │      │  ║   /dkron.data (mount    ║   │ │  │
   │                    │      │  ║   del vol EBS gp3 enc.  ║   │ │  │
   │                    │      │  ║   en /var/lib/dkron-    ║   │ │  │
   │                    │      │  ║   data del host)        ║   │ │  │
   │                    │      │  ╚═════════════════════════╝   │ │  │
   │                    │      │                                │ │  │
   │                    │      │  ╔═════════════════════════╗   │ │  │
   │                    │      │  ║ ECS Service: prometheus ║   │ │  │
   │                    │      │  ║  container prom :9090   ║   │ │  │
   │                    │      │  ║  container alertmgr     ║   │ │  │
   │                    │      │  ║  + EFS (data/rules)     ║───┼─┘  │
   │                    │      │  ║  SG-prom (scrape EC2)   ║   │    │
   │                    │      │  ╚═════════╤═══════════════╝   │    │
   │                    │      │            │ query             │    │
   │                    │      │            ▼                   │    │
   │                    │      │  ╔═════════════════════════╗   │    │
   │                    │      │  ║ ECS Service: grafana    ║   │    │
   │                    │      │  ║  container graf :3000   ║   │    │
   │                    │      │  ║  + EFS (dashboards)     ║   │    │
   │                    │      │  ║  SG-graf                ║   │    │
   │                    │      │  ╚═════════════════════════╝   │    │
   │                    └─────▶│                                │    │
   │                           │ subnet privada-b 10.20.11.0/24 │    │
   │                           │ (réplica AZ exigida por ALB    │    │
   │                           │  y por Fargate multi-AZ)       │    │
   │                           └────────────────────────────────┘    │
   └─────────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────────┐
  │  Servicios laterales (fuera de la VPC):                          │
  │                                                                  │
  │   ECR (mirror imagen oficial dkron/dkron) ◄── docker pull        │
  │   SSM Parameter Store                     ◄── URL del repo ECR +  │
  │     (/dkron/prod/image_repo, etc.)            password de Grafana │
  │   CloudWatch Logs                         ◄── logs Dkron/Prom/Graf│
  │   EFS                                     ◄── persistencia Prom+Graf│
  │   SNS Topic dkron-alerts                  ◄── Alertmanager → email│
  │   S3 bucket de tfstate                    ◄── solo Terraform     │
  │   S3 dkron-outputs (OPCIONAL)             ◄── outputs de jobs    │
  │                                                                  │
  │  Targets de los jobs (fuera de AWS):                             │
  │   Endpoints HTTP, scripts, APIs externas  ◄── llamadas desde el  │
  │                                              agent vía NAT GW     │
  └──────────────────────────────────────────────────────────────────┘
```

**Cómo se lee este diagrama (de afuera hacia adentro):**
1. **Internet** llega al ALB en puerto 80 (Dkron) y opcionalmente 3000 (Grafana).
2. El **ALB** (en las **dos** subnets públicas — AWS exige mínimo 2 AZs para crearlo) reenvía cada listener a su target group correspondiente. Dkron usa target type `instance` (apunta a la EC2 por su instance-id); Grafana usa `ip` (apunta a la task de Fargate).
3. **EC2 con Dkron** vive en subnet privada — Internet NO le habla directo. Le habla solo el ALB.
4. La **EC2 corre Docker Compose** con el container de Dkron en modo `--server` (scheduler) y, en el mismo proceso o como container separado, el rol `agent` que **ejecuta** los runs — la imagen del PDF página 11 marca el agent como "opcional · puede ser el mismo nodo". Justificamos la elección en la PARTE 9 (Decisión 1bis). Ansible es quien instala Docker, copia el compose y arranca los containers (vía SSH desde el runner de CI o desde tu laptop).
5. Dkron persiste el estado en **BoltDB local** (archivo `/dkron.data` dentro del container, montado desde `/var/lib/dkron-data` del host sobre el volumen EBS de la EC2). **No hay BD externa, no hay puerto 5432 abierto, no hay SG-db** — esto se simplificó cuando descubrimos en producción que Dkron OSS no soporta el flag `--store=postgres` (ver PARTE 9.2 y PARTE 11.2).
6. **Prometheus (en Fargate)** scrapea Dkron en la IP privada de la EC2 cada 30s — el bridge cross-compute lo explica la PARTE 8; Grafana consulta a Prometheus.
7. **Alertmanager** dispara alertas vía webhook → Lambda → **SNS** → tu email.
8. Logs: la EC2 manda los logs de los containers a **CloudWatch Logs** vía el agent de CloudWatch (lo configura Ansible). Prometheus/Grafana en Fargate ya escriben a CloudWatch nativo. Datos de Prometheus/Grafana persisten en **EFS**.
9. **NAT Gateway**: la EC2 lo usa para hacer `docker pull` desde ECR cuando Ansible despliega; también para que el **agent llegue a los targets externos** (HTTP, scripts en otras APIs) y, si decides usarlo, para escribir los **outputs en S3 dkron-outputs** vía VPC endpoint o Internet; las tasks de Fargate también lo usan.
10. **S3 dkron-outputs es OPCIONAL** (PDF página 10): si lo activas, el `agent` escribe ahí el stdout/stderr de cada run con `output_size_limit` controlado; si no, los outputs van solo a CloudWatch Logs vía driver `awslogs`. La decisión queda registrada en el reporte sección A.

**Regla de seguridad simple para recordar:** "el firewall de cada cosa solo abre el puerto necesario, y solo desde quien debe llamar." ALB se abre a Internet, EC2 (puerto 8080) solo al ALB, EC2 (puerto 22 SSH) solo a la IP del runner de GitHub Actions o a tu IP, Prometheus scrapea la IP privada de la EC2 en 8080 y 9100, Grafana solo consulta a Prometheus, **el agent tiene egreso a Internet vía NAT solo a los hosts permitidos** (lo justificas en el reporte si abres `0.0.0.0/0` por simplicidad). **No hay regla 5432** — la persistencia es BoltDB local, no hay puerto de BD que abrir.

## ❓ 5.1 ¿Por dónde empiezo? — Los 6 archivos de `infra/envs/prod/`

> 🧠 **Filosofía:** `envs/prod/` es donde **compones** tu entorno. No tiene lógica reutilizable — solo "qué módulos uso y con qué valores". Si todo está bien partido, este archivo `main.tf` es corto y se lee como un índice.

Vas a crear **6 archivos** en `infra/envs/prod/`, cada uno con una responsabilidad clara. Los creas en este orden — cada uno depende del anterior solo en concepto, no en código.

| Archivo | Responsabilidad | Cuándo se aplica |
|---|---|---|
| `versions.tf` | Versiones de Terraform + provider AWS + tags globales | Lo lee `terraform init` |
| `backend.tf` | Dónde se guarda el state (S3) | Lo lee `terraform init` |
| `variables.tf` | Declaración de variables del entorno | Compilado en cada comando |
| `terraform.tfvars` | Valores reales (gitignored) | Compilado en cada comando |
| `main.tf` | Instancia los módulos con esos valores | `terraform plan / apply` |
| `outputs.tf` | Outputs visibles del entorno (Ansible y CI los leen) | Tras `terraform apply` |

### 5.1.1 `infra/envs/prod/versions.tf` (copy-paste)

```hcl
# infra/envs/prod/versions.tf
# Pinneamos versiones para que el "funciona en mi laptop"
# sea idéntico al "funciona en GitHub Actions".

terraform {
  required_version = ">= 1.10"   # 1.10+ requerido por backend S3 con use_lockfile = true

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Tags obligatorios del PDF 5.1 — se aplican a TODO recurso del provider.
# Cualquier recurso que cree Terraform los hereda automáticamente.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}
```

### 5.1.2 `infra/envs/prod/backend.tf` (copy-paste)

> ⚠️ **Antes de pegar:** cambia `tfstate-dkron-tunombre-2026` por el nombre exacto del bucket que creó tu `bootstrap.sh`. **Los valores aquí no admiten variables** (limitación de Terraform: el backend se evalúa antes de las variables).

```hcl
# infra/envs/prod/backend.tf
# State remoto en S3 con locking nativo (use_lockfile = true).
# El archivo de lock es un objeto S3 hermano del tfstate — sin DynamoDB extra.

terraform {
  backend "s3" {
    bucket       = "tfstate-dkron-tunombre-2026"   # ← cámbialo
    key          = "dkron/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true                            # locking S3-native (Terraform >= 1.10)
  }
}
```

### 5.1.3 `infra/envs/prod/variables.tf` (copy-paste)

```hcl
# infra/envs/prod/variables.tf
# Declaraciones — los valores van en terraform.tfvars

variable "region"      { type = string  default = "us-east-1" }
variable "project"     { type = string  default = "dkron" }
variable "environment" { type = string  default = "prod" }
variable "owner"       { type = string }

variable "vpc_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR del VPC. /16 deja espacio para crecer; subnets /24 (256 IPs cada una)."
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "AZs para subnets. ALB requiere mín. 2; resto es single-AZ por costo."
}

variable "dkron_image_tag" {
  type        = string
  default     = "v4.0.9"
  description = "Tag de la imagen Dkron a usar (pinneada, NUNCA :latest). Lo consume Ansible vía --extra-vars; Terraform lo declara para que aparezca en terraform.tfvars como única fuente de verdad del proyecto."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Free tier 12 meses. Si Dkron hace OOM sube a t3.small (~$15/mes)."
}

variable "ssh_public_key" {
  type        = string
  description = "Contenido de ~/.ssh/id_ed25519.pub (Terraform crea key pair, deploy real vía SSM)."
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs autorizados a SSH 22 en la EC2. Vacío = SSH cerrado (usa SSM)."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo (owner/repo). Lo consume bootstrap-oidc.sh y se referencia en el CI vía ${github.repository}. Si NO usas el módulo cicd opcional, esta var queda declarada pero sin uso en Terraform — es OK, sirve para documentar la dependencia en un solo lugar."
}

variable "alert_email" {
  type        = string
  description = "Email destino del topic SNS de alertas Prometheus."
}
```

### 5.1.4 `infra/envs/prod/terraform.tfvars.example` (copy-paste — versionado)

```hcl
# infra/envs/prod/terraform.tfvars.example
# Copia este archivo a terraform.tfvars y rellena con tus valores REALES.
# terraform.tfvars está en .gitignore — NUNCA lo subas.

owner                  = "tunombre"
ssh_public_key         = "ssh-ed25519 AAAA... tunombre@laptop"
ssh_allowed_cidrs      = []                          # vacío = SSH cerrado
github_repo            = "tunombre/dkron-aws"        # owner/repo (usado por CI/CD)
alert_email            = "tu-correo@gmail.com"
grafana_admin_password = "Cambia-Esto-También-Por-Algo-Largo-123!"
```

Genera el archivo real (gitignored):
```bash
cd infra/envs/prod
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tus valores.
# Tip: para ssh_public_key:
#   echo "ssh_public_key = \"$(cat ~/.ssh/id_ed25519.pub)\"" >> terraform.tfvars
```

### 5.1.5 `infra/envs/prod/main.tf` — DEJALO VACÍO POR AHORA

Lo iremos llenando módulo por módulo en 5.2 → 5.7. **Por ahora créalo vacío** o con un comentario:

```hcl
# infra/envs/prod/main.tf
# Aquí instanciamos los módulos. Lo construiremos incremental:
#  5.2 → module "network"
#  5.3 → module "ecr"
#  5.4 → (NO hay módulo "storage" — ver explicación en PARTE 5.4:
#         Dkron OSS no soporta backend Postgres, persistencia = BoltDB
#         sobre el EBS root de la EC2)
#  5.5 → module "compute"
#  5.6 → module "cicd"  (referencia documental — OIDC se crea por script)
#  5.7 → module "monitoring"
```

### 5.1.6 `infra/envs/prod/outputs.tf` — TAMBIÉN VACÍO POR AHORA

Lo llenamos a medida que cada módulo expone sus outputs:

```hcl
# infra/envs/prod/outputs.tf
# Outputs que consumirá Ansible (inventario dinámico) y los workflows de CI/CD.
# Se llenan en 5.2 → 5.7.
```

### 🚀 Primera prueba de `terraform init`

Aún sin lógica, podemos validar que el backend está bien:

```bash
cd infra/envs/prod
terraform fmt -recursive
terraform init
```

Salida esperada:
```
Initializing the backend...
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### 💥 Error 5.A: "Error configuring the backend 's3': NoSuchBucket"
**Causa:** el bucket no existe o el nombre tiene typo.
**Solución:** verifica con `aws s3 ls | grep tfstate` y corrige `backend.tf`.

### 💥 Error 5.B: "Error refreshing state: AccessDenied"
**Causa:** tu IAM user no tiene `s3:GetObject` sobre ese bucket.
**Solución:** PowerUserAccess lo cubre. Si usaste otra política, agrega:
```json
{ "Effect": "Allow", "Action": "s3:*", "Resource": ["arn:aws:s3:::tfstate-dkron-*"] }
```

### 💥 Error 5.B-bis: "use_lockfile is not a valid argument"
**Causa:** tu Terraform local es < 1.10 (la versión que introdujo el lock S3-nativo).
**Solución:** actualiza:
```bash
terraform version    # debe ser >= 1.10
# Si no lo es, sigue https://developer.hashicorp.com/terraform/install
```
Alternativa (Terraform 1.6–1.9): crea una tabla DynamoDB `tfstate-locks` y cambia `use_lockfile = true` por `dynamodb_table = "tfstate-locks"`. Documentado en el reporte.

## ❓ 5.2 Módulo `network/` — VPC + 2 públicas + 2 privadas + IGW + NAT

> 🧠 **Por qué 2 + 2 subnets:**
> - **2 públicas**: requisito **inflexible** del ALB (AWS no permite crear un ALB con una sola subnet — necesita 2 en AZs distintas para tolerancia a fallos del propio ALB).
> - **2 privadas**: dejamos 2 AZ aunque la EC2 vive en 1 sola, para que el ALB tenga un target group con tolerancia futura y para alojar Fargate (Prom/Graf) en multi-AZ. Originalmente la justificación era RDS (que exigía `db_subnet_group` con ≥ 2 AZs); ya no usamos RDS pero mantenemos las 2 privadas por las razones anteriores.
> - **NAT en una sola AZ** (la primera pública): para abaratar (NAT en 2 AZs duplica el costo, ~$64/mes). Tradeoff aceptado: si cae la AZ del NAT, las privadas pierden egreso. Lo documentas en el reporte.
> - **Offset `+10`**: `cidrsubnet(var.vpc_cidr, 8, count.index + 10)` para que las privadas sean `10.20.10.0/24` y `10.20.11.0/24`, lejos de las públicas `10.20.0.0/24` y `10.20.1.0/24`. Facilita debugging cuando ves una IP en CloudTrail (sabes pública vs privada de un vistazo).

### 🖱️ Equivalente en AWS Console

| Recurso Terraform | Servicio | Que harías click-a-click |
|---|---|---|
| `aws_vpc.main` | 🌐 VPC | **VPC → Your VPCs → Create VPC** → Name: `dkron-vpc`, IPv4 CIDR: `10.20.0.0/16`, DNS hostnames: **Enable**, DNS resolution: **Enable**. |
| `aws_subnet.public[0..1]` | 🌐 VPC | **VPC → Subnets → Create subnet** → VPC: dkron-vpc → Name: `dkron-public-0` / `-1` → AZ: `us-east-1a` / `us-east-1b` → CIDR: `10.20.0.0/24` / `10.20.1.0/24`. Tras crear: **Edit subnet settings → Auto-assign IPv4: ON**. |
| `aws_subnet.private[0..1]` | 🌐 VPC | Mismo wizard → CIDR `10.20.10.0/24` / `10.20.11.0/24` → Auto-assign IPv4: **OFF**. |
| `aws_internet_gateway.this` | 🌐 VPC | **VPC → Internet Gateways → Create internet gateway** → Name: `dkron-igw` → **Actions → Attach to VPC** → `dkron-vpc`. |
| `aws_eip.nat` | 🌐 VPC | **VPC → Elastic IPs → Allocate Elastic IP address** → Network border group: us-east-1 → Allocate. |
| `aws_nat_gateway.this` | 🌐 VPC | **VPC → NAT Gateways → Create NAT gateway** → Name: `dkron-nat` → Subnet: `dkron-public-0` → Connectivity: Public → Elastic IP: la que asignaste. |
| `aws_route_table.public` | 🌐 VPC | **VPC → Route tables → Create route table** → Name: `dkron-rt-public` → VPC: dkron-vpc. Tras crear: **Routes → Edit routes → Add route** `0.0.0.0/0` → Target: Internet Gateway → dkron-igw. **Subnet associations → Edit subnet associations** → marca las dos pública. |
| `aws_route_table.private` | 🌐 VPC | Mismo wizard → Name: `dkron-rt-private` → Route `0.0.0.0/0` → Target: NAT Gateway → dkron-nat → Asocia las dos privadas. |

> 🧠 **Conceptualmente — la distinción public/private es CRÍTICA:**
>
> - **Public subnet** tiene una ruta `0.0.0.0/0 → IGW`. Cualquier recurso aquí puede salir a Internet **Y** ser alcanzable desde Internet (con su IP pública). Aquí vive el ALB y la NAT Gateway.
> - **Private subnet** tiene una ruta `0.0.0.0/0 → NAT`. Los recursos aquí pueden salir a Internet (para `docker pull`, log a CloudWatch, etc.) pero **NO son alcanzables desde Internet**. Aquí viven la EC2 con Dkron y las tasks Fargate de Prom/Graf — todo lo "sensible" sin exposición pública.

### 📋 `infra/modules/network/variables.tf` (copy-paste)

```hcl
# infra/modules/network/variables.tf
variable "project"  { type = string }
variable "vpc_cidr" { type = string }
variable "azs" {
  type        = list(string)
  description = "Lista de AZs (necesitamos al menos 2 — ALB lo exige)."
  validation {
    condition     = length(var.azs) >= 2
    error_message = "El ALB requiere mínimo 2 AZs; este módulo crea 2 subnets por tipo."
  }
}
```

### 📋 `infra/modules/network/main.tf` (copy-paste)

```hcl
# infra/modules/network/main.tf

locals {
  azs = slice(var.azs, 0, 2)   # nos quedamos con las 2 primeras AZs
}

# ───── VPC ─────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project}-vpc" }
}

# ───── Subnets PÚBLICAS (ALB + NAT viven aquí) ─────
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)        # 10.20.0.0/24, 10.20.1.0/24
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-${count.index}" }
}

# ───── Subnets PRIVADAS (EC2 con Dkron + tasks Fargate Prom/Graf viven aquí) ─────
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)         # 10.20.10.0/24, 10.20.11.0/24
  availability_zone = local.azs[count.index]
  tags              = { Name = "${var.project}-private-${count.index}" }
}

# ───── Internet Gateway ─────
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

# ───── Elastic IP para el NAT ─────
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags       = { Name = "${var.project}-nat-eip" }
}

# ───── NAT Gateway (single-AZ a propósito para abaratar) ─────
# Tradeoff: si cae us-east-1a, las privadas pierden egreso. Documentado en reporte.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project}-nat" }
  depends_on    = [aws_internet_gateway.this]
}

# ───── Route Tables ─────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.project}-rt-public" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "${var.project}-rt-private" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### 📋 `infra/modules/network/outputs.tf` (copy-paste)

```hcl
# infra/modules/network/outputs.tf
output "vpc_id"             { value = aws_vpc.main.id }
output "vpc_cidr"           { value = aws_vpc.main.cidr_block }
output "public_subnet_ids"  { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "azs_used"           { value = local.azs }
```

### 🔌 Instancia el módulo en `infra/envs/prod/main.tf`

Añade este bloque al final del archivo:

```hcl
# infra/envs/prod/main.tf  (añadir)

module "network" {
  source   = "../../modules/network"
  project  = var.project
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}
```

Y al final de `infra/envs/prod/outputs.tf`:

```hcl
# infra/envs/prod/outputs.tf  (añadir)

output "vpc_id"             { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "public_subnet_ids"  { value = module.network.public_subnet_ids }
```

### 🧪 Aplica solo el módulo network para validar incrementalmente

```bash
cd infra/envs/prod
terraform fmt -recursive
terraform init
terraform plan -target=module.network -out tfplan
terraform apply tfplan
```

Salida esperada: `Apply complete! Resources: ~12 added`.

Verifica en consola:
```bash
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=dkron" \
  --query "Vpcs[].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key=='Name']|[0].Value}" --output table
```

## ❓ 5.3 Módulo `ecr/` — Repositorio para mirror de la imagen oficial

> 🧠 **Por qué ECR separado:** el PDF 5.3.2 obliga a **replicar la imagen oficial a un repositorio ECR propio** (no consumir directamente de Docker Hub — quitamos dependencia externa, evitamos rate limit, podemos escanear con Trivy). Tener el ECR en su propio módulo te permite crearlo **antes** que el resto, hacer `docker push` una vez, y recién después aplicar `compute`.

### 🖱️ Equivalente en AWS Console

| Recurso Terraform | Servicio | Que harías click-a-click |
|---|---|---|
| `aws_ecr_repository.this` | 📦 ECR | **ECR → Private registry → Repositories → Create repository** → Visibility: Private → Repository name: `dkron-dkron` → Tag immutability: **Mutable** → Scan on push: **Enable** → Encryption settings: **AES-256** (AWS-owned key) → Create. |
| `aws_ecr_lifecycle_policy.this` | 📦 ECR | El repo creado → pestaña **Lifecycle Policy → Create rule** dos veces:<br>• **Rule priority 1** — Description: "Mantener últimas 5 imágenes con tag" → Image status: **Tagged**, tag pattern: `*` → Match criteria: **Image count more than 5** → Action: Expire.<br>• **Rule priority 2** — Description: "Borrar imágenes sin tag tras 1 día" → Image status: **Untagged** → Match criteria: **Since image pushed > 1 day** → Action: Expire. |
| `aws_ssm_parameter.image_repo` | 🔐 SSM | **Systems Manager → Parameter Store → Create parameter** → Name: `/dkron/prod/image_repo` → Tier: Standard → Type: **String** → Value: la URI del repo ECR recién creado (`<accountid>.dkr.ecr.us-east-1.amazonaws.com/dkron-dkron`) → Tags: `Name=dkron-image-repo` → Create. Ansible lo lee en runtime para saber qué imagen pull. |

### 📋 `infra/modules/ecr/variables.tf` (copy-paste)

```hcl
# infra/modules/ecr/variables.tf
variable "project" { type = string }
variable "name" {
  type        = string
  default     = "dkron"
  description = "Nombre del repositorio ECR (sufijo)."
}
```

### 📋 `infra/modules/ecr/main.tf` (copy-paste)

```hcl
# infra/modules/ecr/main.tf

resource "aws_ecr_repository" "this" {
  name                 = "${var.project}-${var.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Lifecycle: no acumular basura indefinidamente (cuesta storage)
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantener últimas 5 imágenes con tag"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["*"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Borrar imágenes sin tag tras 1 día"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      }
    ]
  })
}

# Publica la URL del repositorio en SSM para que Ansible la lea en runtime
# (lookup amazon.aws.aws_ssm '/dkron/prod/image_repo' en ansible/inventories/prod/group_vars/all.yml).
resource "aws_ssm_parameter" "image_repo" {
  name  = "/${var.project}/prod/image_repo"
  type  = "String"
  value = aws_ecr_repository.this.repository_url
  tags  = { Name = "${var.project}-image-repo" }
}
```

### 📋 `infra/modules/ecr/outputs.tf` (copy-paste)

```hcl
# infra/modules/ecr/outputs.tf
output "repository_url"        { value = aws_ecr_repository.this.repository_url }
output "repository_arn"        { value = aws_ecr_repository.this.arn }
output "repository_name"       { value = aws_ecr_repository.this.name }
output "image_repo_param_arn"  { value = aws_ssm_parameter.image_repo.arn }
output "image_repo_param_name" { value = aws_ssm_parameter.image_repo.name }
```

### 🔌 Añade el módulo a `infra/envs/prod/main.tf`

```hcl
# infra/envs/prod/main.tf  (añadir)

module "ecr" {
  source  = "../../modules/ecr"
  project = var.project
}
```

Y al `outputs.tf` del entorno:

```hcl
# infra/envs/prod/outputs.tf  (añadir)
output "ecr_repository_url" { value = module.ecr.repository_url }
```

### 🧪 Aplica y replica la imagen oficial

```bash
cd infra/envs/prod
terraform apply -target=module.ecr -auto-approve
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR: $ECR_URL"

aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$ECR_URL"
docker pull dkron/dkron:v4.0.9
docker tag dkron/dkron:v4.0.9 "$ECR_URL:v4.0.9"
docker push "$ECR_URL:v4.0.9"
```

> En el PARTE 7 esto lo automatiza el pipeline. Aquí lo haces una vez a mano para que ECR no esté vacío cuando levantes la EC2.

---

## ❓ 5.4 (Eliminado) Persistencia — decisión BoltDB embebido

> 🧠 **Esta sección originalmente describía un módulo `storage/` con RDS PostgreSQL + un SSM SecureString con el DSN + un bucket S3 opcional para outputs. Lo eliminamos.** Aquí queda solo la explicación de por qué, para que el reporte y el runbook tengan continuidad.

**Qué había antes:** un módulo Terraform que aprovisionaba:
- `aws_db_instance.dkron` — RDS PostgreSQL `db.t3.micro` single-AZ.
- `aws_db_subnet_group.this` — grupo de subnets para RDS (exigía 2 AZs).
- `aws_security_group.db` — SG con regla `ingress 5432` desde el SG-app.
- `aws_ssm_parameter.dsn` — SecureString con el DSN `postgres://...` que Ansible inyectaba al `.env` del compose.
- Un bucket S3 opcional para outputs de jobs.

**Por qué lo quitamos — descubrimiento real en producción (ver PARTE 11.2):**

1. **Dkron OSS v4 no soporta backend Postgres.** Los flags `--store=postgres`, `--backend=postgres` y `--dsn=...` **solo existen en Dkron Pro** (la versión comercial). El binario OSS no reconoce esos flags: imprime el listado completo de opciones de `agent --help` y sale con código 1. El container queda en `Restarting (1)` infinito.
2. Verificación directa: `docker run --rm dkron/dkron:v4.0.9 agent --help | grep -iE 'store|backend|dsn|postgres'` devuelve **vacío**. Ninguno de esos flags existe en el binario OSS.
3. Resultado: gastábamos ~$15/mes de RDS + un SecureString + un SG + 5 minutos de apply en algo que el binario nunca iba a usar.

**Qué hicimos en su lugar — BoltDB embebido sobre EBS:**

- Dkron arranca con `--data-dir=/dkron.data` (BoltDB es el default).
- El compose monta el host directory `/var/lib/dkron-data` (dentro del volumen root EBS de la EC2) sobre `/dkron.data` del container.
- El volumen root EBS está `encrypted = true` y es `gp3` (ver `infra/modules/compute/main.tf`, bloque `root_block_device`).
- El `.env` ya no necesita `DKRON_DSN`. El archivo `env.j2` queda casi vacío (solo `DKRON_LOG_LEVEL`).

**Tradeoffs aceptados (escríbelos en el reporte sección A):**

| Aspecto | RDS Postgres (lo que íbamos a hacer) | BoltDB en EBS (lo que hacemos) |
|---|---|---|
| Disponibilidad si la EC2 muere | Estado sobrevive (RDS independiente) | Estado vive en EBS del EC2; si destruyes EC2 sin snapshot, pierdes histórico |
| Costo extra | ~$15/mes | $0 (sobre el EBS root de 20 GB ya pagado) |
| Backups | Snapshots automáticos RDS | Snapshots EBS manuales o vía DLM (opcional, ver runbook R1) |
| Compatibilidad Dkron OSS | ❌ no soporta el flag | ✅ es el default |
| Complejidad infra | Módulo storage + SG-db + SSM SecureString + 2 AZ privadas obligadas | Cero — solo el volumen EBS root de la EC2 |

**Mitigación de durabilidad (opcional):** activa **AWS DLM (Data Lifecycle Manager)** con una policy diaria del volumen EBS de la EC2 — son ~$0.05/mes por snapshot. Procedimiento en `docs/runbook.md` (R1: snapshot manual + restore).

**Lo que se ahorra el repo:**
- Módulo `infra/modules/storage/` → **eliminado** entero.
- Variable `db_password` → eliminada de `envs/prod/variables.tf` y `terraform.tfvars.example`.
- Variable `enable_s3_outputs` → eliminada (el bucket opcional se puede recrear más adelante si hace falta).
- Outputs `rds_endpoint`, `dsn_parameter_name`, `s3_outputs_bucket_name` → eliminados de `envs/prod/outputs.tf`.
- Regla `aws_security_group_rule.db_from_app` → eliminada del módulo compute (no hay BD que abrir).
- Policy IAM `ec2_ssm_dsn` → eliminada (la EC2 ya no necesita leer `/dkron/prod/dsn`).

**Cómo se ve hoy en `envs/prod/main.tf`:** **no hay `module "storage"`**. El árbol queda con 5 módulos en vez de 6 (network, ecr, compute, monitoring, cicd).

> 📝 **Para el reporte (9.2):** la pregunta del PDF "¿BoltDB local o PostgreSQL?" sigue siendo válida — solo que la respuesta correcta para **Dkron OSS** es **BoltDB es la única opción real**. Documentar esta restricción de la herramienta es valioso: muestra que verificaste la matriz de features OSS vs Pro antes de comprometerte con una arquitectura.

---

## ❓ 5.5 Módulo `compute/` — EC2 + ALB + Security Groups + IAM

> 🧠 **Decisión del PDF 5.2 Opción B:** EC2 + Docker Compose desplegado por Ansible. El módulo `compute` solo crea **la cáscara**: la EC2 cruda, el ALB que la fronta, los SGs, el IAM role y los log groups. **Dkron mismo lo instala Ansible** (Parte 6) sobre esa EC2.

### 🖱️ Equivalente en AWS Console

| Recurso Terraform | Servicio | Que harías click-a-click |
|---|---|---|
| `aws_security_group.alb` | 🌐 VPC | **VPC → Security groups → Create** → Name: `dkron-alb-sg` → VPC: dkron-vpc → Inbound: HTTP 80 from `0.0.0.0/0`, HTTP 3000 from `0.0.0.0/0` → Outbound: all traffic → Create. |
| `aws_security_group.app` | 🌐 VPC | **VPC → Security groups → Create** → Name: `dkron-app-sg` → VPC: dkron-vpc → Inbound: TCP 8080 from SG `dkron-alb-sg` (y SSH 22 desde `ssh_allowed_cidrs` solo si la lista NO está vacía — dynamic block). El puerto 9100 (node_exporter) lo abre `monitoring` con una regla aparte → Outbound: all traffic → Create. |
| `aws_key_pair.this` | 💻 EC2 | **EC2 → Network & Security → Key pairs → Actions → Import key pair** → Name: `dkron-key` → Pega tu `~/.ssh/id_ed25519.pub` → Import key pair. |
| `data.aws_ssm_parameter.al2023` | 🔐 SSM | **No es creación** — Terraform solo lee el parámetro público `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` para obtener el AMI ID actual. En consola lo verás al elegir "Amazon Linux 2023 AMI" en el wizard de EC2. |
| `aws_iam_role.ec2` | 🔐 IAM | **IAM → Roles → Create role** → Trusted entity type: AWS service → Use case: **EC2** → Next (sin marcar policies aún) → Role name: `dkron-ec2-role` → Create role. |
| `aws_iam_role_policy.ec2_ecr` (inline) | 🔐 IAM | En el rol `dkron-ec2-role` → **Add permissions → Create inline policy → JSON** → permite `ecr:GetAuthorizationToken` sobre `*` y `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`, `ecr:BatchCheckLayerAvailability` sobre el ARN del repo `dkron-dkron`. |
| `aws_iam_role_policy.ec2_ssm_read` (inline) | 🔐 IAM | Mismo rol → **Add permissions → Create inline policy → JSON** → `ssm:GetParameter`, `ssm:GetParameters` sobre el ARN de `/dkron/prod/image_repo` (String plano — Ansible lo lee para resolver la URL del ECR). **Ya NO necesitas `/dkron/prod/dsn` ni `kms:Decrypt`** — la persistencia es BoltDB local, no hay SecureString del DSN. |
| `aws_s3_bucket.ansible_ssm` + `aws_s3_bucket_public_access_block.ansible_ssm` | 🪣 S3 | **S3 → Create bucket** → Name: `dkron-ansible-ssm-<accountid>` (el plugin `community.aws.aws_ssm` lo usa para transferir archivos a la EC2) → Block all public access: ON → Create. Anota el nombre. |
| `aws_iam_role_policy.ec2_ansible_ssm` (inline) | 🔐 IAM | Mismo rol `dkron-ec2-role` → **Create inline policy → JSON** → `s3:GetObject/PutObject/DeleteObject` sobre `arn:aws:s3:::dkron-ansible-ssm-<accountid>/*` + `s3:ListBucket/GetBucketLocation` sobre el bucket. |
| `aws_ssm_parameter.ansible_ssm_bucket` | 🔐 SSM | **Systems Manager → Parameter Store → Create parameter** → Name: `/dkron/prod/ansible_ssm_bucket` → Type: String → Value: `dkron-ansible-ssm-<accountid>` (el inventory Ansible lo lee en runtime). |
| `aws_iam_role_policy_attachment.ec2_cw` | 🔐 IAM | Mismo rol → **Add permissions → Attach policies** → busca `CloudWatchAgentServerPolicy` (AWS managed) → Attach. |
| `aws_iam_role_policy_attachment.ec2_ssm_managed` | 🔐 IAM | Mismo rol → **Attach policies** → busca `AmazonSSMManagedInstanceCore` (AWS managed) → Attach. |
| `aws_iam_instance_profile.ec2` | 🔐 IAM | Cuando creas el rol con caso de uso **EC2** desde la UI, AWS crea automáticamente el instance profile con el mismo nombre. Si usaste AWS CLI: `aws iam create-instance-profile --instance-profile-name dkron-ec2-profile && aws iam add-role-to-instance-profile --instance-profile-name dkron-ec2-profile --role-name dkron-ec2-role`. |
| `aws_cloudwatch_log_group.dkron` | 📊 CloudWatch | **CloudWatch → Log groups → Create log group** → Name: `/dkron/ec2/dkron` → Retention: **1 day** → Create. |
| `aws_cloudwatch_log_group.compose` | 📊 CloudWatch | Mismo wizard → Name: `/dkron/ec2/compose` → Retention: **1 day**. |
| `aws_instance.dkron` | 💻 EC2 | **EC2 → Instances → Launch instance** → Name: `dkron-host`, Tag adicional `Role=dkron-server` → AMI: Amazon Linux 2023 → Instance type: t3.micro → Key pair: `dkron-key` → Network settings: VPC `dkron-vpc`, Subnet `dkron-private-0`, **Auto-assign public IP: Disable**, SG: `dkron-app-sg` → Configure storage: 20 GB, **gp3**, **Encrypted: Yes**, **Delete on termination: Yes** → Advanced details: IAM instance profile: `dkron-ec2-profile`, **Detailed monitoring: Enable**, User data: `#!/bin/bash`<br>`set -e`<br>`dnf -y update`<br>`dnf -y install python3 awscli`<br>`systemctl enable --now amazon-ssm-agent`. |
| `aws_lb.this` | ⚖️ EC2 | **EC2 → Load balancers → Create load balancer → Application Load Balancer** → Name: `dkron-alb` → Scheme: **internet-facing** → IP address type: IPv4 → VPC: dkron-vpc → Mappings: 2 AZs con `dkron-public-0` y `dkron-public-1` → SG: `dkron-alb-sg`. |
| `aws_lb_target_group.dkron` | ⚖️ EC2 | **EC2 → Target groups → Create target group** → Target type: **Instances** → Name: `dkron-tg` → Protocol: HTTP, Port: **8080** → VPC: dkron-vpc → Protocol version: HTTP1 → Health checks: Path `/v1/jobs`, Healthy threshold: 2, Unhealthy threshold: 3, Interval: 30s, **Success codes: 200**. |
| `aws_lb_target_group_attachment.dkron` | ⚖️ EC2 | En el paso **Register targets** del wizard del target group → selecciona la EC2 `dkron-host` → Port: **8080** → Include as pending below → Create target group. |
| `aws_lb_listener.http` | ⚖️ EC2 | En el ALB `dkron-alb` → pestaña **Listeners → Add listener** → Protocol: HTTP, Port: **80** → Default action: **Forward to target group → `dkron-tg`** → Add. |

### 📋 `infra/modules/compute/variables.tf` (copy-paste)

```hcl
# infra/modules/compute/variables.tf
variable "project"            { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "vpc_cidr"           { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "instance_type"      { type = string  default = "t3.micro" }
variable "ssh_public_key"     { type = string }
variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "ecr_repository_arn" { type = string }
variable "image_repo_param_arn" {
  type        = string
  description = "ARN del SSM String /dkron/prod/image_repo — Ansible lo lee para saber qué tag de ECR usar."
}
```

### 📋 `infra/modules/compute/main.tf` (copy-paste)

```hcl
# infra/modules/compute/main.tf

# ───── Security Groups ─────
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "ALB público — acepta HTTP/3000 de Internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP (Dkron UI/API)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana (PARTE 8)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-alb-sg" }
}

resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "EC2 con Dkron — solo recibe del ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Dkron HTTP desde ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH solo si hay CIDRs explícitos (debug puntual)
  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      description = "SSH debug"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-app-sg" }
}

# ───── Key Pair + AMI ─────
resource "aws_key_pair" "this" {
  key_name   = "${var.project}-key"
  public_key = var.ssh_public_key
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ───── IAM: instance profile ─────
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Pull desde ECR (la EC2 hace docker pull al desplegar)
resource "aws_iam_role_policy" "ec2_ecr" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# Lectura del parámetro SSM con la URL del repo ECR (Ansible lo resuelve en runtime).
# Ya no se lee ningún DSN — Dkron OSS persiste en BoltDB local, no hay credenciales
# de BD que inyectar al compose.
resource "aws_iam_role_policy" "ec2_ssm_read" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = [var.image_repo_param_arn]
    }]
  })
}

# Bucket auxiliar para el plugin community.aws.aws_ssm (transferencia de archivos
# Ansible → EC2 vía SSM). NO confundir con el bucket de outputs de jobs.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "ansible_ssm" {
  bucket        = "${var.project}-ansible-ssm-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "${var.project}-ansible-ssm" }
}

resource "aws_s3_bucket_public_access_block" "ansible_ssm" {
  bucket                  = aws_s3_bucket.ansible_ssm.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# La EC2 lee/escribe en el bucket ansible-ssm (el plugin sube payloads transitorios)
resource "aws_iam_role_policy" "ec2_ansible_ssm" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.ansible_ssm.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.ansible_ssm.arn
      }
    ]
  })
}

# Publica el nombre del bucket en SSM para que el inventario aws_ec2.yml lo resuelva
# en runtime (mismo patrón que /dkron/prod/image_repo).
resource "aws_ssm_parameter" "ansible_ssm_bucket" {
  name  = "/${var.project}/${var.environment}/ansible_ssm_bucket"
  type  = "String"
  value = aws_s3_bucket.ansible_ssm.id
  tags  = { Name = "${var.project}-ansible-ssm-bucket" }
}

# CloudWatch Logs agent
resource "aws_iam_role_policy_attachment" "ec2_cw" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM Session Manager (login sin SSH para debug y conexión Ansible)
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# ───── CloudWatch Log Groups ─────
resource "aws_cloudwatch_log_group" "dkron" {
  name              = "/${var.project}/ec2/dkron"
  retention_in_days = 1     # alcance proyecto; prod real: 7-30
}

resource "aws_cloudwatch_log_group" "compose" {
  name              = "/${var.project}/ec2/compose"
  retention_in_days = 1
}

# ───── EC2 (host de Dkron) ─────
resource "aws_instance" "dkron" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = false
  monitoring                  = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # user_data MÍNIMO: solo SSM agent + Python.
  # Docker, compose y Dkron los instala Ansible (PARTE 6) — idempotente, repetible.
  user_data = <<-EOT
    #!/bin/bash
    set -e
    dnf -y update
    dnf -y install python3 awscli
    systemctl enable --now amazon-ssm-agent
  EOT

  tags = {
    Name = "${var.project}-host"
    Role = "dkron-server"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [ami]  # no rotemos AMI en cada apply
  }
}

# ───── ALB ─────
resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.project}-alb" }
}

resource "aws_lb_target_group" "dkron" {
  name        = "${var.project}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/v1/jobs"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "dkron" {
  target_group_arn = aws_lb_target_group.dkron.arn
  target_id        = aws_instance.dkron.id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dkron.arn
  }
}
```

### 📋 `infra/modules/compute/outputs.tf` (copy-paste)

```hcl
# infra/modules/compute/outputs.tf
output "ec2_instance_id"     { value = aws_instance.dkron.id }
output "ec2_private_ip"      { value = aws_instance.dkron.private_ip }
output "alb_dns_name"        { value = aws_lb.this.dns_name }
output "alb_arn"             { value = aws_lb.this.arn }              # consumido por module.monitoring (8.2)
output "alb_listener_arn"    { value = aws_lb_listener.http.arn }
output "app_sg_id"           { value = aws_security_group.app.id }
output "alb_sg_id"           { value = aws_security_group.alb.id }
output "log_group_dkron"     { value = aws_cloudwatch_log_group.dkron.name }
output "log_group_compose"   { value = aws_cloudwatch_log_group.compose.name }
output "ec2_role_name"       { value = aws_iam_role.ec2.name }
output "ansible_ssm_bucket"  { value = aws_s3_bucket.ansible_ssm.id }
```

### 🧭 Cómo accede Ansible a una EC2 en SUBNET PRIVADA

Tres caminos posibles (decidimos C, lo justificas en el reporte):

| Camino | Pros | Contras |
|---|---|---|
| A. SSH directo via NAT | Lo conocido | Necesitas bastion público o EC2 con IP pública. **No lo usamos.** |
| B. SSH a través de bastion | Aísla SSH, registro centralizado | +1 EC2 prendida 24/7, +costo |
| **C. SSM Session Manager** ✅ | Sin SSH, sin bastion, IAM mínimo, gratis | Curva del plugin `community.aws.aws_ssm` |

> 🔐 **`ssh_allowed_cidrs = []` por defecto** — SSH cerrado. Si necesitas debug puntual, edita `terraform.tfvars` con tu IP `["1.2.3.4/32"]` y `terraform apply`. Ciérralo después. Lo documentas como decisión en el reporte (B.5 — mínimo privilegio).

### 🔌 Instancia el módulo en `infra/envs/prod/main.tf`

```hcl
# infra/envs/prod/main.tf  (añadir)

module "compute" {
  source               = "../../modules/compute"
  project              = var.project
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  instance_type        = var.instance_type
  ssh_public_key       = var.ssh_public_key
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  ecr_repository_arn   = module.ecr.repository_arn
  image_repo_param_arn = module.ecr.image_repo_param_arn
}
```

Y al `outputs.tf`:

```hcl
# infra/envs/prod/outputs.tf  (añadir)

output "ec2_instance_id" { value = module.compute.ec2_instance_id }
output "ec2_private_ip"  { value = module.compute.ec2_private_ip }
output "alb_dns_name"    { value = module.compute.alb_dns_name }
output "app_sg_id"       { value = module.compute.app_sg_id }
```

### 🧪 Aplica solo el módulo compute para validar incrementalmente

```bash
cd infra/envs/prod
terraform apply -target=module.compute -auto-approve
```

Tarda ~2-3 min (EC2 ~1 min, ALB ~1 min).

Verifica:
```bash
terraform output ec2_instance_id
terraform output alb_dns_name

# La EC2 está Online en SSM?
aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$(terraform output -raw ec2_instance_id)" \
  --query "InstanceInformationList[].PingStatus" --output text
# Esperado: Online (puede tardar 2-3 min tras boot)

# El ALB devuelve 502 (esperado — la EC2 está vacía, Ansible la configura en PARTE 6)
curl -sI http://$(terraform output -raw alb_dns_name)/v1/jobs
# Esperado: HTTP/1.1 502 Bad Gateway
```

> ✅ **Llegaste hasta aquí con 3 applies incrementales independientes:**
> 1. `apply -target=module.network` (~2 min)
> 2. `apply -target=module.ecr` (~30s) + docker push de la imagen
> 3. `apply -target=module.compute` (~2-3 min)
>
> Si cualquiera falla, solo recreas ese módulo — no rehaces todo el stack. Ese es el valor del patrón modular. (Antes había un cuarto paso `apply -target=module.storage` para RDS — eliminado tras el descubrimiento de PARTE 5.4.)

---

## ❓ 5.6 Checkpoint consolidado — el `main.tf` completo hasta este punto

> 📋 **Esta sección es una consolidación**, no añade nada nuevo. Si fuiste pegando `module "..."` bloque a bloque en 5.2 → 5.5, tu `main.tf` ya quedó así. Úsalo de **referencia** para verificar que no te falta nada. El bloque `monitoring` lo añadirás en Parte 8; el `cicd` es scripted en Parte 7 (no entra a `main.tf`).

```hcl
# infra/envs/prod/main.tf — versión completa hasta 5.6

module "network" {
  source   = "../../modules/network"
  project  = var.project
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "ecr" {
  source  = "../../modules/ecr"
  project = var.project
}

module "compute" {
  source               = "../../modules/compute"
  project              = var.project
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  instance_type        = var.instance_type
  ssh_public_key       = var.ssh_public_key
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  ecr_repository_arn   = module.ecr.repository_arn
  image_repo_param_arn = module.ecr.image_repo_param_arn
}
```

> ✅ **Flujo incremental sin ciclos:** `network → ecr → compute`. **Ya no hay módulo `storage`** (ver PARTE 5.4: BoltDB local sobre EBS, eliminamos RDS). Cada módulo se puede `terraform apply -target=module.X` en orden.

Y el `outputs.tf` del entorno queda:

```hcl
# infra/envs/prod/outputs.tf — versión completa hasta 5.6

# Network
output "vpc_id"             { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "public_subnet_ids"  { value = module.network.public_subnet_ids }

# ECR
output "ecr_repository_url" { value = module.ecr.repository_url }

# Compute (Ansible los consume vía inventario dinámico)
output "ec2_instance_id" { value = module.compute.ec2_instance_id }
output "ec2_private_ip"  { value = module.compute.ec2_private_ip }
output "alb_dns_name"    { value = module.compute.alb_dns_name }
output "app_sg_id"       { value = module.compute.app_sg_id }
```

### 🚀 Apply completo

```bash
cd infra/envs/prod
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

Tarda ~3–5 min (EC2 ~1 min, ALB ~1 min, el resto son SGs/IAM/log groups). **Antes eran 10–15 min porque RDS tardaba 5–7; al eliminar storage el apply es mucho más rápido.**

Salida esperada al final:
```
alb_dns_name           = "dkron-alb-1234567890.us-east-1.elb.amazonaws.com"
ec2_instance_id        = "i-0123456789abcdef0"
ec2_private_ip         = "10.20.10.42"
ecr_repository_url     = "123456789.dkr.ecr.us-east-1.amazonaws.com/dkron-dkron"
```

### 🔎 ¿La EC2 está VACÍA y el ALB devuelve 502? Eso es ESPERADO

```
   Estado actual (post terraform apply):
   ───────────────────────────────────────
   ✅ EC2 prendida con Amazon Linux 2023
   ✅ ssm-agent corriendo (gracias al user_data mínimo)
   ❌ Docker NO instalado
   ❌ docker-compose.yml NO existe
   ❌ Container de Dkron NO está corriendo
   ❌ Puerto 8080 cerrado (no hay quien escuche)
   ─────────────────────────────────
   ⚠️  ALB target group: UNHEALTHY (health check falla)
   ⚠️  curl al ALB: 502 Bad Gateway
```

**Es correcto.** Lo arregla **Ansible** en la PARTE 6. Antes, verifica:

```bash
# La EC2 existe y SSM puede contactarla?
aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$(terraform output -raw ec2_instance_id)" \
  --query "InstanceInformationList[].PingStatus" --output text
# debe decir: Online
```

Si dice `Online`, Ansible podrá conectarse vía SSM (PARTE 6). Si está vacío, esperá 2-3 min — el agent SSM tarda en registrarse tras el primer boot.

## 💥 Errores que vas a cometer en la PARTE 5 (yo me equivoqué así)

### Error 5.D: ALB target unhealthy después del apply (esperado)
**Síntoma:** `curl http://$ALB` devuelve 502 Bad Gateway.
**Causa:** la EC2 está creada pero **vacía** — todavía no corriste Ansible. Es el estado correcto al final de la PARTE 5.
**Solución:** continúa a la PARTE 6. Una vez que el playbook `site.yml` termine, el ALB pasará a healthy en ~60 segundos.

**Verificación previa antes de culpar a Ansible:**
```bash
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id) \
  --query "Reservations[].Instances[].State.Name" --output text   # debe ser "running"

aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$(terraform output -raw ec2_instance_id)" \
  --query "InstanceInformationList[].PingStatus" --output text     # debe ser "Online"
```

### Error 5.E: la EC2 no aparece en SSM (`InstanceInformationList` vacío)
**Síntoma:** `aws ssm describe-instance-information` no devuelve la EC2 después de 5 minutos.
**Causa A:** falta el `IAM instance profile` con `AmazonSSMManagedInstanceCore`.
**Causa B:** la EC2 no tiene salida a Internet (NAT mal configurado) y el agent SSM no puede llamar al endpoint.
**Diagnóstico:**
```bash
# ¿el role tiene la policy?
aws iam list-attached-role-policies --role-name dkron-ec2-role

# ¿la subnet privada tiene route hacia el NAT?
aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=<private_subnet_id>"
```
**Solución:** revisa tu módulo `network/` — la subnet privada necesita `route 0.0.0.0/0 → nat-gateway`.

### Error 5.G: terraform destroy bloqueado por VPC
**Síntoma:** `DependencyViolation: The vpc has dependencies`.
**Causa:** ENIs de la EC2 o de tasks ECS Fargate aún liberándose.
**Solución:** espera 2-5 min y reintenta. Si persiste:
```bash
aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=<vpc-id>" --query "NetworkInterfaces[?Status=='available']"
aws ec2 delete-network-interface --network-interface-id eni-xxx
```

### Error 5.H: Olvidaste tags obligatorios
**Detección:** revisa cualquier recurso en consola; si no tiene `Project, Environment, Owner, ManagedBy=Terraform`, perdiste puntos.
**Solución:** los `default_tags` del provider los aplican a casi todo. Algunos recursos (volúmenes EBS implícitos, key pairs) no respetan default_tags; agrégalos manualmente con `tags_all`.

### Error 5.I: el inventario dinámico de Ansible no encuentra la EC2 (PARTE 6 lo verifica)
**Síntoma:** `ansible-inventory --graph` devuelve vacío.
**Causa típica:** olvidaste agregar tag `Project=dkron` a la EC2 o el plugin filtra por una región distinta.
**Solución:** confirma `tags_all` con:
```bash
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id) \
  --query "Reservations[].Instances[].Tags"
```

## 🎯 Lo que aprendiste:
- **Concepto B.1 del reporte:** IaC vs gestión de configuración. Aquí terminaste la **mitad de IaC**: Terraform tiene VPC, EC2 (con su EBS root para BoltDB), ALB, ECR, IAM, SSM. La otra mitad la harás en la PARTE 6 con Ansible. Documenta la frontera: "Terraform creó la EC2 vacía; Ansible la configurará".
- **Concepto B.5 del reporte:** mínimo privilegio. El instance profile de la EC2 tiene **solo** `AmazonSSMManagedInstanceCore` (para gestión remota), `CloudWatchAgentServerPolicy` (para enviar logs) y dos policies inline acotadas a leer dos parámetros SSM específicos por ARN. Eso es defendible. Si tuviste que ampliar (por ejemplo, abrir más permisos de ECR o de KMS), anótalo.
- **Concepto B.6 del reporte:** state remoto + locking. Hasta aquí ya viste por qué hace falta lock — si dos `terraform apply` corrieran a la vez sobre estos recursos, podrías quedarte con dos EC2 huérfanas o con security groups conflictivos.

---

<a id="parte-6"></a>
# PARTE 6 — Configurar la EC2 con Ansible

> Aquí entra la **gestión de configuración**. Terraform te dejó una EC2 vacía. Ansible la transforma en un host de Dkron usable. Esta es la pieza que diferencia este proyecto de uno hecho con Fargate puro.

## 🗺️ Diagrama: cómo se conectan Terraform, Ansible y la EC2

```
   ┌────────────────────────────────────────────────────────────────────┐
   │                     Tu laptop o GitHub Actions runner              │
   │                                                                    │
   │   1) terraform apply                                               │
   │      └─▶ crea EC2 (con su EBS), VPC, ECR, SSM, IAM, ALB            │
   │                                                                    │
   │   2) ansible-inventory --graph -i ansible/inventories/prod/        │
   │      └─▶ plugin aws_ec2 consulta AWS por tag Project=dkron         │
   │      └─▶ encuentra la EC2 y la añade al grupo "tag_Role_dkron"     │
   │                                                                    │
   │   3) ansible-playbook playbooks/site.yml                           │
   │      └─▶ rol "docker": instala docker-ce + plugin compose          │
   │      └─▶ rol "dkron-compose": render compose.yml.j2 + .env.j2      │
   │                                  → /opt/dkron/                     │
   │      └─▶ docker_compose_v2 module: pull + up -d                    │
   │      └─▶ wait_for: health del puerto 8080                          │
   └─────────────────────────────────────┬──────────────────────────────┘
                                         │ via SSM Session Manager (sin SSH)
                                         ▼
   ┌────────────────────────────────────────────────────────────────────┐
   │  EC2 (subnet privada, sin IP pública)                              │
   │                                                                    │
   │   ssm-agent (online) ←── conexión Ansible                          │
   │       ▼                                                            │
   │   /opt/dkron/                                                      │
   │     ├── docker-compose.yml   (renderizado por Ansible)             │
   │     ├── .env                 (vars + DSN leído de SSM)             │
   │     └── ...                                                        │
   │                                                                    │
   │   Containers después del playbook:                                 │
   │     • dkron:v4.0.9   :8080  (UI + REST + /metrics)                 │
   │       cmd: "agent --server" → scheduler + executor (9.1bis)        │
   │     • node-exporter  :9100  (métricas del HOST para Prometheus)    │
   └────────────────────────────────────────────────────────────────────┘
```

## ❓ 6.1 ¿Cómo instalo Ansible y qué versión uso?

```bash
# En tu laptop (también lo instalará el runner de CI vía pip)
python3 -m pip install --user "ansible-core==2.17.*" "boto3>=1.34" "botocore>=1.34"
ansible --version    # debe ser >= 2.17
```

Luego instala las colecciones que vamos a usar:

```bash
cat > ansible/requirements.yml <<'YAML'
collections:
  - name: amazon.aws
    version: ">=8.0.0"
  - name: community.aws
    version: ">=8.0.0"
  - name: community.docker
    version: ">=3.10.0"
YAML

ansible-galaxy collection install -r ansible/requirements.yml
```

> **Versión pinneada en el reporte (sección 6.4 evidencias):** anota `ansible-core 2.17.x`, `community.docker 3.10+`, `amazon.aws 8.x`. Pinnear es regla del PDF (sección 3 paso 7).

## ❓ 6.2 ¿Qué pongo en `ansible.cfg`?

`ansible/ansible.cfg`:
```ini
[defaults]
inventory          = inventories/prod
host_key_checking  = False
retry_files_enabled = False
stdout_callback    = yaml
forks              = 5
pipelining         = True
timeout            = 30

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

> ⚠️ **`host_key_checking = False`** se documenta en el reporte sección B.5: la conexión a la EC2 va por **SSM Session Manager** (no SSH directo a Internet), así que el riesgo de MITM no aplica del modo clásico — la autenticación va por IAM.

## ❓ 6.3 ¿Cómo configuro el inventario DINÁMICO con el plugin `aws_ec2`?

`ansible/inventories/prod/aws_ec2.yml`:
```yaml
---
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  tag:Project: dkron
  tag:Environment: prod
  instance-state-name: running
keyed_groups:
  - prefix: tag_Role
    key: tags.Role
hostnames:
  - tag:Name
compose:
  ansible_host: instance_id              # ← clave: usamos instance-id como "host"
  ansible_connection: aws_ssm             # ← conexión via SSM, sin SSH público
  ansible_aws_ssm_region: us-east-1
  ansible_aws_ssm_bucket_name: "{{ lookup('amazon.aws.aws_ssm', '/dkron/prod/ansible_ssm_bucket', region='us-east-1') }}"
  ansible_python_interpreter: /usr/bin/python3
```

> 🪣 **Bucket `ansible-ssm`**: el plugin `aws_ssm` usa un bucket S3 para transferir archivos a la EC2 (porque SSM Session Manager por sí solo no es un canal de archivos completo). Lo crea el módulo `compute/` (sección 5.5) — ya está incluido en los snippets de `compute/main.tf` que copiaste antes de llegar aquí; Terraform escribe su nombre al SSM parameter `/dkron/prod/ansible_ssm_bucket` y el inventory lo resuelve en runtime (mismo patrón que `ecr_repo`).

**Variables del grupo `all`** — `ansible/inventories/prod/group_vars/all.yml`:
```yaml
---
project: dkron
environment: prod
region: us-east-1

# Versiones pinneadas (espejo de las que pinnearás en docker-compose)
dkron_image_tag: "v4.0.9"
node_exporter_image_tag: "v1.8.2"

# Lookups a SSM (Ansible los resuelve EN TIEMPO DE EJECUCIÓN, no se versionan)
# Ya NO hay lookup de db_dsn — Dkron OSS usa BoltDB local, no requiere DSN.
ecr_repo: "{{ lookup('amazon.aws.aws_ssm', '/dkron/prod/image_repo', region=region) }}"

# Endpoint del CloudWatch agent
cw_log_group_compose: "/dkron/ec2/compose"
cw_log_group_dkron: "/dkron/ec2/dkron"
```

**Verifica el inventario:**
```bash
cd ansible
ansible-inventory --graph -i inventories/prod/aws_ec2.yml
# Esperas ver:
# @all:
#   |--@tag_Role_dkron_server:
#   |  |--i-0123456789abcdef0
```

Si está vacío → Error 5.I (revisa tags y región).

## ❓ 6.4 El rol `docker` — instalar Docker Engine + plugin compose

`ansible/roles/docker/defaults/main.yml`:
```yaml
---
docker_users:
  - ec2-user
docker_compose_plugin_version: "v2.29.7"
```

`ansible/roles/docker/tasks/main.yml`:
```yaml
---
- name: Instalar paquetes base
  ansible.builtin.dnf:
    name:
      - docker
      - python3-pip
      - python3-urllib3        # awscli depende de este — ver PARTE 11.1
    state: present

- name: Habilitar y arrancar Docker
  ansible.builtin.systemd:
    name: docker
    state: started
    enabled: true

- name: Agregar usuario(s) al grupo docker
  ansible.builtin.user:
    name: "{{ item }}"
    groups: docker
    append: true
  loop: "{{ docker_users }}"

- name: Instalar plugin Docker Compose v2 (binario)
  ansible.builtin.get_url:
    url: "https://github.com/docker/compose/releases/download/{{ docker_compose_plugin_version }}/docker-compose-linux-x86_64"
    dest: /usr/libexec/docker/cli-plugins/docker-compose
    mode: "0755"
    owner: root
    group: root
  notify: Reiniciar docker

- name: Instalar SDK de Docker para Python (necesario para el módulo community.docker)
  ansible.builtin.pip:
    name:
      - "docker>=7.1"
      - "PyYAML"
    state: present
  # OJO: NO uses --ignore-installed aquí. Si lo agregas, pip sobreescribe
  # archivos del urllib3 del sistema y rompe el awscli (ver PARTE 11.1).

- name: Verificar integridad de python3-urllib3 (pip puede haber sobrescrito sus archivos y roto awscli)
  ansible.builtin.command: rpm -V python3-urllib3
  register: urllib3_verify
  failed_when: false
  changed_when: false

- name: Reinstalar python3-urllib3 si está corrupto
  ansible.builtin.command: dnf reinstall -y python3-urllib3
  when: urllib3_verify.stdout | length > 0

- name: Obtener token efímero de ECR (válido 12h)
  ansible.builtin.command:
    cmd: "aws ecr get-login-password --region {{ region }}"
  register: ecr_token
  changed_when: false
  no_log: true
  tags: [deploy]

- name: docker login al ECR
  ansible.builtin.shell:
    cmd: "echo '{{ ecr_token.stdout }}' | docker login --username AWS --password-stdin {{ ecr_repo | regex_replace('/.*$', '') }}"
  changed_when: false
  no_log: true
  tags: [deploy]
```

`ansible/roles/docker/handlers/main.yml`:
```yaml
---
- name: Reiniciar docker
  ansible.builtin.systemd:
    name: docker
    state: restarted
```

> 📌 **Por qué `notify` y handlers**: si el binario de compose ya está en la versión correcta, Ansible no notifica → no reinicia Docker. Es la **idempotencia** que vendiste en la sección 2.11.

## ❓ 6.5 El rol `dkron-compose` — desplegar el compose

`ansible/roles/dkron-compose/defaults/main.yml`:
```yaml
---
dkron_dir: /opt/dkron
dkron_data_volume: /var/lib/dkron-data
dkron_log_level: info
dkron_node_name: dkron-server
```

`ansible/roles/dkron-compose/tasks/main.yml`:
```yaml
---
- name: Crear directorios
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: "0755"
  loop:
    - "{{ dkron_dir }}"
    - "{{ dkron_data_volume }}"

- name: Renderizar docker-compose.yml
  ansible.builtin.template:
    src: docker-compose.yml.j2
    dest: "{{ dkron_dir }}/docker-compose.yml"
    mode: "0644"
  notify: Reiniciar compose

- name: Renderizar .env (configuración runtime — ya no contiene DSN)
  ansible.builtin.template:
    src: env.j2
    dest: "{{ dkron_dir }}/.env"
    mode: "0600"   # mantenemos 0600 por convención aunque ya no hay secretos
    owner: root
  no_log: true
  notify: Reiniciar compose

- name: Pull de la imagen pinneada
  community.docker.docker_compose_v2_pull:
    project_src: "{{ dkron_dir }}"
  tags: [deploy]

- name: Up del compose (idempotente)
  community.docker.docker_compose_v2:
    project_src: "{{ dkron_dir }}"
    state: present
    pull: missing                # solo pull si no la tiene local
    remove_orphans: true
  tags: [deploy]

- name: Esperar a que Dkron responda en :8080
  ansible.builtin.wait_for:
    host: 127.0.0.1
    port: 8080
    timeout: 90
  tags: [deploy, smoke]

- name: Smoke test — GET /v1/jobs
  ansible.builtin.uri:
    url: http://127.0.0.1:8080/v1/jobs
    status_code: 200
  register: smoke
  retries: 6
  delay: 5
  until: smoke.status == 200
  tags: [deploy, smoke]
```

`ansible/roles/dkron-compose/handlers/main.yml`:
```yaml
---
- name: Reiniciar compose
  community.docker.docker_compose_v2:
    project_src: "{{ dkron_dir }}"
    state: restarted    # OJO: en docker_compose_v2 el parámetro `restarted: true`
                        # NO existe — se usa state: restarted directo.
                        # Ver PARTE 11.3 por qué.
```

`ansible/roles/dkron-compose/templates/docker-compose.yml.j2`:
```yaml
x-logging: &awslogs
  driver: awslogs
  options:
    awslogs-region: {{ region }}
    awslogs-group: {{ cw_log_group_compose }}
    awslogs-create-group: "true"

services:
  dkron:
    image: {{ ecr_repo }}:{{ dkron_image_tag }}
    container_name: dkron
    restart: unless-stopped
    env_file: .env
    command:
      - agent
      - --server
      - --bootstrap-expect=1
      - --node-name={{ dkron_node_name }}
      - --data-dir=/dkron.data
      - --log-level={{ dkron_log_level }}
    ports:
      - "8080:8080"
    volumes:
      - {{ dkron_data_volume }}:/dkron.data    # BoltDB persistente (host EBS)
    logging: *awslogs

  node-exporter:
    image: prom/node-exporter:{{ node_exporter_image_tag }}
    container_name: node-exporter
    restart: unless-stopped
    pid: host
    network_mode: host    # expone :9100 en la IP privada de la EC2
    command:
      - --path.rootfs=/host
      - --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)
    volumes:
      - /:/host:ro,rslave
    logging: *awslogs
```

`ansible/roles/dkron-compose/templates/env.j2`:
```bash
# Generado por Ansible — NO editar a mano (se sobrescribe en cada deploy)
# Dkron OSS v4 usa BoltDB embebido — no requiere DSN ni backend externo.
DKRON_LOG_LEVEL={{ dkron_log_level }}
```

> 📝 **Sobre la separación de variables sensibles vs no sensibles:** el PDF sección 3 paso 4 pide separar variables no sensibles (puertos, flags, niveles de log) de variables sensibles (URLs de conexión con credenciales, API keys) usando SSM Parameter Store. En este proyecto, **al cambiar a BoltDB embebido desaparecieron las variables sensibles del runtime de Dkron** (ya no hay DSN). El `.env` queda solo con `DKRON_LOG_LEVEL`. Las únicas credenciales sensibles que siguen viviendo en SSM son las **de Grafana** (la admin password, que se inyecta en la task Fargate vía `secrets:` — ver PARTE 8). Si más adelante necesitas variables sensibles para Dkron (por ejemplo, un token para webhooks de notificación), el patrón sigue siendo el mismo: declararlas en `env.j2` con un lookup `{{ lookup('amazon.aws.aws_ssm', '...', decrypt=True) }}`.

## ❓ 6.6 Los playbooks: `site.yml` y `deploy.yml`

`ansible/playbooks/site.yml` (bootstrap completo, día 0 o tras recrear EC2):
```yaml
---
- name: Configurar host de Dkron desde cero
  hosts: tag_Role_dkron_server
  gather_facts: true
  become: true
  roles:
    - docker
    - dkron-compose
```

`ansible/playbooks/deploy.yml` (solo deploy de imagen nueva — lo usa CI/CD):
```yaml
---
- name: Deploy de Dkron en EC2 ya configurada
  hosts: tag_Role_dkron_server
  gather_facts: false
  become: true
  pre_tasks:
    - name: Validar que docker está instalado
      ansible.builtin.command: docker version --format '{{ "{{" }}.Server.Version{{ "}}" }}'
      changed_when: false
      register: docker_check
      failed_when: docker_check.rc != 0
  tasks:
    - name: Solo tareas con tag deploy/smoke del rol dkron-compose
      ansible.builtin.include_role:
        name: dkron-compose
        tasks_from: main
      tags: [deploy, smoke]
```

**Diferencia importante:**

| `site.yml`               | `deploy.yml`                                      |
|--------------------------|---------------------------------------------------|
| Corre los DOS roles      | Asume Docker ya instalado                         |
| ~3-4 minutos             | ~30-60 segundos                                   |
| Lo usas la primera vez   | Lo usa el CI/CD en cada push a `main`             |
| Tras `terraform taint` de la EC2 | Tras nueva imagen en ECR                  |

## ❓ 6.7 ¿Cómo lo corro la primera vez?

Asumiendo que ya hiciste `terraform apply` (PARTE 5) y que la imagen está en ECR:

```bash
cd ansible
export AWS_PROFILE=dev-tu-nombre        # o las credenciales del runner
export AWS_REGION=us-east-1

# 1) Verifica que el inventario encuentra la EC2
ansible-inventory --graph

# 2) Ping (debe contestar la EC2 vía SSM)
ansible all -m ansible.builtin.ping

# 3) Bootstrap completo
ansible-playbook playbooks/site.yml

# 4) Verifica desde fuera (vía ALB)
ALB=$(cd ../infra/envs/prod && terraform output -raw alb_dns_name)
curl http://$ALB/v1/jobs    # debe responder []
```

Tarda ~3-5 minutos la primera vez. Si `curl` responde `[]`, ✅ Dkron está corriendo en producción gestionado por Ansible.

## ❓ 6.8 ¿Cómo se valida el código de Ansible en CI?

Vas a meter dos pasos en el pipeline (PARTE 7):

```bash
# ansible-lint — equivalente a tflint para Ansible
pip install ansible-lint==24.7.*
ansible-lint ansible/

# yamllint — formato YAML
pip install yamllint
yamllint ansible/
```

Crea `ansible/.ansible-lint`:
```yaml
---
profile: production
exclude_paths:
  - .cache/
skip_list:
  - yaml[line-length]   # los Jinja largos rompen 160 cols
```

## 💥 Errores que vas a cometer en la PARTE 6

### Error 6.A: `ansible-inventory --graph` devuelve vacío
**Causa:** AWS_REGION mal exportada o filtros del plugin no matchean los tags.
**Solución:**
```bash
aws ec2 describe-instances --filters "Name=tag:Project,Values=dkron" \
  --query "Reservations[].Instances[].{ID:InstanceId,Tags:Tags}"
```
Si la EC2 aparece, el plugin debería verla — revisa el `regions:` y `filters:` del YAML.

### Error 6.B: "An exception occurred during task execution: aws_ssm" / no se conecta
**Causa A:** la cuenta no tiene permisos de SSM (`ssm:StartSession`).
**Causa B:** la EC2 no aparece en `aws ssm describe-instance-information` (revisa Error 5.E).
**Causa C:** el bucket `ansible-ssm` no existe o el role no tiene permisos.
**Diagnóstico rápido:**
```bash
aws ssm start-session --target $(cd ../infra/envs/prod && terraform output -raw ec2_instance_id)
# ¿abre una shell? Si sí, el problema es de Ansible. Si no, es IAM/SSM.
```

### Error 6.C: `community.docker.docker_compose_v2` falla con "no Python module 'docker'"
**Causa:** olvidaste el paso `pip install docker` en el rol `docker`.
**Solución:** revisa que la tarea "Instalar SDK de Docker para Python" esté antes de cualquier tarea del compose.

### Error 6.D: `wait_for: port 8080` timeout
**Causa A:** el container de Dkron está en `Restarting (1)` — el binario salió con error. Causa más común en este proyecto: usaste `--store=postgres` en el `command` y Dkron OSS no lo soporta (imprime el help y muere). **Ver PARTE 11.2 con el debug completo.**
**Causa B:** la imagen de ECR no se descargó (token vencido, rol IAM mal). `docker logs dkron` te lo dice.
**Diagnóstico:**
```bash
ansible all -a "docker compose -f /opt/dkron/docker-compose.yml ps"
ansible all -a "docker logs dkron --tail 50"
```

### Error 6.E: el playbook se ejecuta dos veces y modifica todo de nuevo
**Síntoma:** todas las tareas reportan `changed=N` en cada run.
**Causa:** alguna tarea no es idempotente — típicamente un `command:` o `shell:` sin `creates:` o `changed_when: false`.
**Solución:** usa módulos nativos (`copy`, `template`, `dnf`) en vez de shell. Si necesitas shell, agrega `creates:` o `changed_when:`.

### Error 6.F: `docker login` rota el token y al día siguiente el deploy falla
**Causa:** el token de ECR vive 12h. El playbook hace login nuevamente cada run, así que **no** es problema en producción si el deploy va por CI; sí lo es si el operador olvida re-loguearse al ejecutar manualmente.
**Solución:** en `roles/docker/tasks/main.yml` la tarea de login tiene tag `[deploy]` — siempre se ejecuta en `deploy.yml`. Para correr manualmente:
```bash
ansible-playbook playbooks/deploy.yml --tags deploy
```

### Error 6.G: el playbook funciona local pero falla en CI con "no module named boto3"
**Causa:** el Python del runner no tiene boto3 instalado.
**Solución:** en el job de CI, instala `pip install ansible-core boto3 botocore` antes de ejecutar.

## 🎯 Lo que aprendiste:
- **Concepto B.1 del reporte (cierre):** ahora SÍ tienes ejemplo concreto. Terraform creó la EC2 + IAM + ALB + ECR. Ansible instaló Docker, copió `docker-compose.yml`, levantó los containers (con BoltDB persistente en `/var/lib/dkron-data` del host), hizo el smoke test. Ninguna de las dos herramientas habría podido sola.
- **Idempotencia (concepto subyacente):** corre `ansible-playbook site.yml` dos veces seguidas. La segunda debe terminar con todas las tareas en `ok=N changed=0`. Esa es la firma de un playbook bien escrito y la diferencia clave con un script bash.
- **Mínimo privilegio (B.5):** la EC2 NO expone SSH a Internet. Ansible se conecta vía SSM Session Manager con autenticación IAM. Documenta este desvío del patrón "ansible+ssh" clásico del bootcamp.

---

<a id="parte-7"></a>
# PARTE 7 — Pipeline CI/CD con GitHub Actions

## 🗺️ Diagrama: el flujo del pipeline de principio a fin

```
   git push  ──────────────────────────────────────────────────────▶
   │
   │   ┌──────────────┐
   │   │ Pull Request │           ┌──────────────┐
   ├──▶│   a main     │──────────▶│  Push a main │
   │   └──────┬───────┘           └──────┬───────┘
   │          │                          │
   │          ▼                          ▼
   │  ┌─────────────────────────────────────────┐
   │  │        Job 1: iac-validate              │
   │  │  ─ terraform fmt -check                 │
   │  │  ─ terraform validate                   │
   │  │  ─ tflint                               │
   │  │  ─ Checkov                              │
   │  │  ─ ansible-lint  ← NUEVO                │
   │  │  ─ yamllint      ← NUEVO                │
   │  └────────────────┬────────────────────────┘
   │                   │ (si pasa)
   │                   ▼
   │  ┌─────────────────────────────────────────┐
   │  │        Job 2: replicate-image           │
   │  │  ─ docker pull dkron/dkron:v4.0.9       │
   │  │  ─ tag → ECR                            │
   │  │  ─ docker push                          │
   │  └────────────────┬────────────────────────┘
   │                   │
   │                   ▼
   │  ┌─────────────────────────────────────────┐
   │  │        Job 3: trivy-scan                │
   │  │  Falla si HIGH/CRITICAL sin .trivyignore│
   │  └────────────────┬────────────────────────┘
   │                   │
   │     ┌─────────────┴─────────────┐
   │     │                           │
   │     ▼ (solo en PR)              ▼ (solo en push a main)
   │  ┌─────────────┐         ┌─────────────────────────┐
   │  │  Job: plan  │         │  Job: apply             │
   │  │  terraform  │         │  environment: production│
   │  │  plan       │         │  ⏸️  ESPERA APROBACIÓN  │
   │  └─────────────┘         │     MANUAL TUYA         │
   │                          │  (un humano hace clic)  │
   │                          └────────────┬────────────┘
   │                                       │
   │                                       ▼
   │                          ┌─────────────────────────┐
   │                          │  terraform apply        │
   │                          │  → outputs (EC2 ID, ECR)│
   │                          └────────────┬────────────┘
   │                                       │
   │                                       ▼
   │                          ┌─────────────────────────┐
   │                          │  Job: ansible-deploy    │
   │                          │  ─ pip install ansible  │
   │                          │  ─ inventario aws_ec2   │
   │                          │  ─ ansible-playbook     │
   │                          │       deploy.yml        │
   │                          │  ─ smoke test al ALB    │
   │                          └─────────────────────────┘

   Workflow separado: destruir.yaml (manual)
   ────────────────────────────────────────
   Tú lo disparas a mano. Tienes que escribir "DESTRUIR" para confirmar.
   Termina con costo cero hasta el próximo apply.
```

**Por qué este flujo es Continuous Delivery (no Deployment):** porque hay un **humano** que aprueba antes del apply de Terraform. En Continuous Deployment puro, el apply correría solo. El bootcamp pide delivery (sección 5.3 punto 5).

**Nota sobre la gate manual y Ansible:** una vez que el humano aprueba, **tanto** `terraform apply` como `ansible-playbook deploy.yml` corren automáticos. La aprobación se aplica al deploy completo (infra + config). No metemos otra gate antes de Ansible porque en este flujo Ansible es la ejecución del deploy, no una decisión adicional.

## ❓ 7.1 ¿Cómo le doy a GitHub Actions credenciales de AWS sin meter secretos en el código?

Usa **OIDC** (OpenID Connect): GitHub se autentica contra AWS asumiendo un rol IAM, **sin guardar Access Keys** en GitHub Secrets. Es la práctica recomendada y elimina rotación de credenciales.

> 🥚🐔 **Paradoja del huevo y la gallina:** el rol OIDC tiene que existir **antes** de que el pipeline pueda correr Terraform. Por eso lo creamos con un **script aparte** (`infra/bootstrap-oidc.sh`), que ejecutas **una sola vez** desde tu laptop con tus credenciales locales. Es la misma filosofía que `bootstrap.sh` (PARTE 4.3).

### 🖱️ Equivalente en AWS Console

| Paso del script | Recurso | Servicio | Que harías click-a-click |
|---|---|---|---|
| 1) `create-open-id-connect-provider` | OIDC Provider | 🔐 IAM | **IAM → Identity providers → Add provider** → Provider type: **OpenID Connect** → Provider URL: `https://token.actions.githubusercontent.com` → Audience: `sts.amazonaws.com` → Thumbprint: `6938fd4d98bab03faadb97b34396831e3780aea1` (lo calcula AWS automáticamente al pulsar "Get thumbprint") → Add provider. |
| 2)+3) `create-role` con trust policy | Rol GHA | 🔐 IAM | **IAM → Roles → Create role** → Trusted entity type: **Web identity** → Identity provider: `token.actions.githubusercontent.com` → Audience: `sts.amazonaws.com` → GitHub organization: `tunombre`, GitHub repository: `dkron-aws` (la consola compone el `sub` `repo:tunombre/dkron-aws:*` automáticamente) → Role name: `github-actions-dkron` → Description: "Rol asumible por GitHub Actions vía OIDC para CI/CD" → Create role. |
| 4) `attach-role-policy` | PowerUserAccess managed | 🔐 IAM | El rol → **Permissions → Add permissions → Attach policies** → busca y marca **`PowerUserAccess`** (AWS managed) → Attach. |
| 5) `put-role-policy` | Policy inline `TerraformIAMManage` | 🔐 IAM | El rol → **Add permissions → Create inline policy → JSON** → Allow `iam:*` sobre `*` → Policy name: `TerraformIAMManage` → Create policy. PowerUser excluye `iam:*`, pero Terraform crea roles (instance profile EC2, etc.) — la justificación va en REPORTE.md B.5. |
| 6) `tag-role` | Tags del rol | 🔐 IAM | El rol → pestaña **Tags → Manage tags → Add tag** (3 veces): `Project=dkron`, `Environment=prod`, `ManagedBy=bootstrap-oidc.sh` → Save. |

### 📋 Script copy-paste: `infra/bootstrap-oidc.sh`

```bash
#!/usr/bin/env bash
# infra/bootstrap-oidc.sh
# Crea (si no existen) el OIDC provider de GitHub Actions y un rol IAM
# que el pipeline pueda asumir vía AssumeRoleWithWebIdentity.
# Idempotente: corres este script varias veces sin romper nada.
#
# Uso:
#   chmod +x infra/bootstrap-oidc.sh
#   ./infra/bootstrap-oidc.sh tunombre/dkron-aws

set -euo pipefail

GITHUB_REPO="${1:-}"                      # ej: tunombre/dkron-aws
if [[ -z "${GITHUB_REPO}" ]]; then
  echo "Uso: ./infra/bootstrap-oidc.sh <owner>/<repo>"
  echo "Ej:   ./infra/bootstrap-oidc.sh juanperez/dkron-aws"
  exit 1
fi

PROJECT="dkron"
REGION="us-east-1"
ROLE_NAME="github-actions-${PROJECT}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
OIDC_URL="token.actions.githubusercontent.com"
OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_URL}"

# ─── 1) OIDC provider ────────────────────────────────────────────────────────
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_ARN}" >/dev/null 2>&1; then
  echo "✅ OIDC provider ya existe: ${OIDC_ARN}"
else
  echo "🔧 Creando OIDC provider..."
  aws iam create-open-id-connect-provider \
    --url "https://${OIDC_URL}" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
  echo "   ↳ creado"
fi

# ─── 2) Trust policy del rol GHA (solo del repo declarado) ───────────────────
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "${OIDC_ARN}" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "${OIDC_URL}:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "${OIDC_URL}:sub": "repo:${GITHUB_REPO}:*"
      }
    }
  }]
}
EOF
)

# ─── 3) Crear o actualizar el rol GHA ────────────────────────────────────────
if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "✅ Rol ya existe: ${ROLE_NAME} — actualizando trust policy"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "${TRUST_POLICY}"
else
  echo "🔧 Creando rol ${ROLE_NAME}..."
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "${TRUST_POLICY}" \
    --description "Rol asumible por GitHub Actions vía OIDC para CI/CD"
  echo "   ↳ creado"
fi

# ─── 4) PowerUserAccess (suficiente para el alcance del proyecto) ────────────
aws iam attach-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"

# ─── 5) Permisos IAM:* — necesarios para crear los roles del módulo compute ──
# Justificación reporte B.5: PowerUser excluye iam:*, pero Terraform crea roles
# (instance profile EC2, SGs). Acotamos a iam:* sobre la cuenta propia.
aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "TerraformIAMManage" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    }]
  }'

# ─── 6) Tags ─────────────────────────────────────────────────────────────────
aws iam tag-role \
  --role-name "${ROLE_NAME}" \
  --tags "Key=Project,Value=${PROJECT}" \
         "Key=Environment,Value=prod" \
         "Key=ManagedBy,Value=bootstrap-oidc.sh"

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo ""
echo "✅ Setup completo."
echo ""
echo "📋 Configura este secret en GitHub:"
echo "   Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "   Name:  AWS_ROLE_ARN"
echo "   Value: ${ROLE_ARN}"
echo ""
echo "📋 Y este environment para aprobación manual:"
echo "   Settings → Environments → New environment → 'production'"
echo "   Marca: Required reviewers → agrégate"
```

Hazlo ejecutable y córrelo:

```bash
chmod +x infra/bootstrap-oidc.sh
./infra/bootstrap-oidc.sh tunombre/dkron-aws    # ← cambia por TU repo
```

Salida esperada (primera vez):
```
🔧 Creando OIDC provider...
   ↳ creado
🔧 Creando rol github-actions-dkron...
   ↳ creado

✅ Setup completo.

📋 Configura este secret en GitHub:
   Name:  AWS_ROLE_ARN
   Value: arn:aws:iam::123456789012:role/github-actions-dkron
```

### 📋 (Opcional, documental) Módulo `cicd/` — versión Terraform-managed

Si prefieres que **otro entorno** (staging) reuse el OIDC sin volver a correr el script, puedes encapsularlo en un módulo Terraform. Es **opcional** (el bootstrap por script ya cumple). Útil para entornos múltiples.

Crea `infra/modules/cicd/main.tf`:

```hcl
# infra/modules/cicd/main.tf
# Módulo opcional. Si usaste bootstrap-oidc.sh, NO añadas este módulo
# a infra/envs/prod/main.tf — duplicarías recursos. Sirve como referencia
# o para staging si decides extenderlo.

variable "github_repo"  { type = string }
variable "project"      { type = string }

# Importa el provider existente (creado por el script) o créalo si no existe:
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "gha_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "gha" {
  name               = "github-actions-${var.project}-tf"
  assume_role_policy = data.aws_iam_policy_document.gha_assume.json
}

resource "aws_iam_role_policy_attachment" "gha_power" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "gha_iam" {
  role = aws_iam_role.gha.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["iam:*"]
      Resource = "*"
    }]
  })
}

output "gha_role_arn" { value = aws_iam_role.gha.arn }
```

> 📌 **Decisión documentada en el reporte B.5:** elegimos el patrón **script bootstrap** (no Terraform) para el OIDC porque (a) evita la paradoja huevo-gallina del primer apply, (b) mantiene la lógica de bootstrap simétrica con `bootstrap.sh` del bucket S3, (c) sobrevive a `terraform destroy` (no queremos perder el rol si el deploy falla — el destroy es para recursos costosos, no para infra de bootstrap).

## ❓ 7.2 ¿Cómo configuro los secretos en GitHub?

En tu repo: **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Valor | Origen |
|---|---|---|
| `AWS_ROLE_ARN` | `arn:aws:iam::...:role/github-actions-dkron` | output de `bootstrap-oidc.sh` |
| `ECR_REPO` | `123...dkr.ecr.us-east-1.amazonaws.com/dkron-dkron` | output de `terraform output -raw ecr_repository_url` |
| `TF_OWNER` | `tunombre` | el mismo que pusiste en `terraform.tfvars` |
| `SSH_PUBLIC_KEY` | contenido de tu `~/.ssh/id_ed25519.pub` | `cat ~/.ssh/id_ed25519.pub` |
| `ALERT_EMAIL` | `tu-correo@gmail.com` | tu email para SNS |
| `GRAFANA_ADMIN_PASSWORD` | password admin de Grafana | igual a la de `terraform.tfvars` |

> 🧠 **`TF_VAR_github_repo` no necesita secret** — lo derivamos del contexto del propio workflow con `${{ github.repository }}`.

### Environment de aprobación

- **Settings → Environments → New environment → `production`**
- Marca **Required reviewers** y agrégate.
- Esto hace que el job `apply` espere a tu approval antes de correr `terraform apply`.

## ❓ 7.3 El workflow principal: `.github/workflows/ci-cd.yaml`

```yaml
name: ci-cd
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read
  pull-requests: write

concurrency:
  group: tf-${{ github.ref }}
  cancel-in-progress: false

jobs:
  iac-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with: { terraform_version: 1.10.5 }
      - name: fmt
        run: terraform fmt -check -recursive
        working-directory: infra/envs/prod
      - name: init
        run: terraform init -backend=false
        working-directory: infra/envs/prod
      - name: validate
        run: terraform validate
        working-directory: infra/envs/prod
      - uses: terraform-linters/setup-tflint@v4
      - run: tflint --recursive
        working-directory: infra
      - uses: bridgecrewio/checkov-action@master
        with:
          directory: infra/
          quiet: true
          soft_fail: false

  ansible-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      # Creds AWS: el inventory aws_ec2.yml usa plugin amazon.aws.aws_ec2 + lookups SSM
      # que necesitan credenciales incluso para --syntax-check (Ansible evalúa el
      # inventory antes de parsear los playbooks).
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - name: Install ansible-lint, yamllint y boto3 (lookups AWS)
        run: |
          pip install "ansible-core==2.17.*" "ansible-lint==24.7.*" "yamllint==1.35.*" "boto3>=1.34" "botocore>=1.34"
          ansible-galaxy collection install -r ansible/requirements.yml
      - name: yamllint
        run: yamllint ansible/
      - name: ansible-lint
        run: ansible-lint ansible/
      - name: Syntax check de los playbooks
        working-directory: ansible
        run: |
          ansible-playbook playbooks/site.yml --syntax-check -i inventories/prod/aws_ec2.yml
          ansible-playbook playbooks/deploy.yml --syntax-check -i inventories/prod/aws_ec2.yml

  replicate-image:
    runs-on: ubuntu-latest
    needs: [iac-validate, ansible-validate]
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - uses: aws-actions/amazon-ecr-login@v2
      - name: Pull, tag, push
        run: |
          IMG=dkron/dkron:v4.0.9
          docker pull $IMG
          docker tag $IMG ${{ secrets.ECR_REPO }}:v4.0.9
          docker push ${{ secrets.ECR_REPO }}:v4.0.9

  trivy-scan:
    runs-on: ubuntu-latest
    needs: replicate-image
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - uses: aws-actions/amazon-ecr-login@v2
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.ECR_REPO }}:v4.0.9
          severity: HIGH,CRITICAL
          exit-code: '1'
          ignore-unfixed: true
          trivyignores: .trivyignore

  plan:
    runs-on: ubuntu-latest
    needs: trivy-scan
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - uses: hashicorp/setup-terraform@v3
        with: { terraform_version: 1.10.5 }
      - run: terraform init
        working-directory: infra/envs/prod
      - run: terraform plan -no-color
        working-directory: infra/envs/prod
        env:
          TF_VAR_owner:                  ${{ secrets.TF_OWNER }}
          TF_VAR_ssh_public_key:         ${{ secrets.SSH_PUBLIC_KEY }}
          TF_VAR_github_repo:            ${{ github.repository }}
          TF_VAR_alert_email:            ${{ secrets.ALERT_EMAIL }}
          TF_VAR_grafana_admin_password: ${{ secrets.GRAFANA_ADMIN_PASSWORD }}

  apply:
    runs-on: ubuntu-latest
    needs: trivy-scan
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: production
    outputs:
      ec2_instance_id: ${{ steps.tf.outputs.ec2_instance_id }}
      alb_dns_name:    ${{ steps.tf.outputs.alb_dns_name }}
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - uses: hashicorp/setup-terraform@v3
        with: { terraform_version: 1.10.5 }
      - run: terraform init
        working-directory: infra/envs/prod
      - id: tf
        name: terraform apply
        working-directory: infra/envs/prod
        env:
          TF_VAR_owner:                  ${{ secrets.TF_OWNER }}
          TF_VAR_ssh_public_key:         ${{ secrets.SSH_PUBLIC_KEY }}
          TF_VAR_github_repo:            ${{ github.repository }}
          TF_VAR_alert_email:            ${{ secrets.ALERT_EMAIL }}
          TF_VAR_grafana_admin_password: ${{ secrets.GRAFANA_ADMIN_PASSWORD }}
        run: |
          terraform apply -auto-approve
          echo "ec2_instance_id=$(terraform output -raw ec2_instance_id)" >> $GITHUB_OUTPUT
          echo "alb_dns_name=$(terraform output -raw alb_dns_name)"       >> $GITHUB_OUTPUT

  ansible-deploy:
    runs-on: ubuntu-latest
    needs: apply
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - name: Install Ansible + dependencias
        run: |
          pip install "ansible-core==2.17.*" "boto3>=1.34" "botocore>=1.34"
          ansible-galaxy collection install -r ansible/requirements.yml
          # Plugin SSM para Session Manager
          curl -o session-manager.deb "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
          sudo dpkg -i session-manager.deb
      - name: Esperar a que la EC2 esté Online en SSM
        run: |
          for i in {1..30}; do
            STATUS=$(aws ssm describe-instance-information \
              --filters "Key=InstanceIds,Values=${{ needs.apply.outputs.ec2_instance_id }}" \
              --query "InstanceInformationList[].PingStatus" --output text)
            [ "$STATUS" = "Online" ] && exit 0
            sleep 10
          done
          echo "EC2 no quedó Online en SSM tras 5 minutos"
          exit 1
      - name: Deploy con ansible-playbook
        working-directory: ansible
        run: |
          ansible-playbook playbooks/deploy.yml \
            --extra-vars "dkron_image_tag=v4.0.9"
      - name: Smoke test desde el ALB
        run: |
          ALB="${{ needs.apply.outputs.alb_dns_name }}"
          for i in {1..20}; do
            CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB/v1/jobs" || true)
            [ "$CODE" = "200" ] && exit 0
            sleep 10
          done
          echo "ALB nunca devolvió 200 tras 200s"
          exit 1
```

> Secrets necesarios en GitHub (los **6**): `AWS_ROLE_ARN`, `ECR_REPO`, `TF_OWNER`, `SSH_PUBLIC_KEY`, `ALERT_EMAIL`, `GRAFANA_ADMIN_PASSWORD`. Si te falta cualquiera, `terraform plan` revienta con `No value for required variable`. **Ya no hay `DB_PASSWORD`** — al eliminar el módulo storage (BoltDB local, ver PARTE 5.4) desapareció esa variable.

## ❓ 7.4 El workflow de destrucción: `.github/workflows/destruir.yaml`

```yaml
name: destruir
on:
  workflow_dispatch:
    inputs:
      confirmar:
        description: 'Escribe DESTRUIR para confirmar'
        required: true

permissions:
  id-token: write
  contents: read

jobs:
  destroy:
    if: ${{ inputs.confirmar == 'DESTRUIR' }}
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - uses: hashicorp/setup-terraform@v3
        with: { terraform_version: 1.10.5 }
      - run: terraform init
        working-directory: infra/envs/prod
      - run: terraform destroy -auto-approve
        working-directory: infra/envs/prod
        env:
          TF_VAR_owner:                  ${{ secrets.TF_OWNER }}
          TF_VAR_ssh_public_key:         ${{ secrets.SSH_PUBLIC_KEY }}
          TF_VAR_github_repo:            ${{ github.repository }}
          TF_VAR_alert_email:            ${{ secrets.ALERT_EMAIL }}
          TF_VAR_grafana_admin_password: ${{ secrets.GRAFANA_ADMIN_PASSWORD }}
```

## ❓ 7.5 ¿Cómo pruebo el pipeline?
1. Crea una rama: `git checkout -b feat/test-pipeline`.
2. Haz un cambio chico (un comentario en cualquier `.tf`).
3. `git commit -am "test pipeline"` y `git push`.
4. Abre PR a main: `gh pr create`.
5. Mira la pestaña **Actions**. Deberían correr `iac-validate`, `replicate-image`, `trivy-scan`, `plan`.
6. Si todo verde, mergea el PR.
7. En main, corre `apply` que pide aprobación. Apruébalo en la UI.

## 💥 Errores típicos en la PARTE 7

### Error 7.A: "Could not assume role with OIDC"
**Causa:** el trust policy del rol no incluye tu repo.
**Solución:** revisa que el `sub` del policy diga `repo:tuusuario/dkron-aws:*` exactamente (sin typo en el nombre del repo).

### Error 7.B: Trivy bloquea con vulnerabilidades CRITICAL
**Síntoma:** el scan falla con CVEs.
**Solución 1:** actualiza la imagen de Dkron a una versión más nueva.
**Solución 2:** agrega el CVE específico a `.trivyignore` **con justificación documentada en el mismo archivo**.

> 💡 El archivo `.trivyignore` ya vive en la raíz del repo desde el primer commit, **vacío con solo el header**. Eso evita que la action `aquasecurity/trivy-action` falle por `trivyignores: .trivyignore` apuntando a un archivo inexistente. Cuando aparezca el primer CVE que necesites ignorar, añade el bloque siguiendo el formato de abajo (comentario + CVE).

`.trivyignore` ejemplo:
```
# Justificación de excepciones — actualizado 2026-MM-DD
# Cada línea documenta CVE + razón + fecha de revisión

# CVE en runtime de Go de la imagen oficial. Sin parche upstream
# disponible al 2026-05-10. Riesgo aceptado por estar la imagen
# en subnet privada y no ser afectada por el vector de ataque
# (requeriría acceso de red local). Revisar en 30 días.
CVE-2023-39325

# Vulnerabilidad en libpng dentro de la imagen base. No usado
# por Dkron en runtime. Riesgo nulo. Revisar al actualizar imagen.
CVE-2023-4863
```

**Esto NO es un atajo:** la sección 5.3 punto 3 del PDF dice "el job falla si hay vulnerabilidades HIGH o CRITICAL **sin excepción documentada**". La excepción documentada está permitida. Documéntalo también en `REPORTE.md` sección C como "problema encontrado y solución aplicada".

### Error 7.C: terraform fmt -check falla en CI
**Causa:** localmente formateaste pero no commiteaste.
**Solución:** corre `terraform fmt -recursive` local y commit de nuevo.

### Error 7.D: dos PRs aplican a la vez
**Causa:** mal configurado `concurrency`.
**Solución:** asegura `concurrency.group` único por workflow + ref:
```yaml
concurrency:
  group: tf-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: false
```

### Error 7.E: Checkov falla con cientos de hallazgos
**Síntoma:** muchos warnings sobre cifrado, multi-AZ, etc.
**Solución:** **algunos son legítimos** (EBS no encrypted? agrégale `encrypted = true`). **Otros son por el alcance** (single-AZ — el PDF lo permite). Documenta los skips:
```hcl
# checkov:skip=CKV_AWS_157: multi-AZ no aplica al alcance del proyecto (sección 4 del PDF)
```

### Error 7.F: ansible-lint falla en CI con `name[casing]` o `risky-shell-pipe`
**Causa:** profile `production` de ansible-lint es estricto.
**Solución 1:** corrige el código (preferido). Por ejemplo, "Reiniciar docker" → "Reiniciar Docker" (start case).
**Solución 2:** documenta el skip en `ansible/.ansible-lint`:
```yaml
skip_list:
  - risky-shell-pipe   # solo donde justificado en comentario inline
```

### Error 7.G: el job `ansible-deploy` falla con "EC2 no quedó Online en SSM"
**Causa:** la EC2 acabó de crearse y el agent SSM tarda en registrarse.
**Solución:** el loop ya espera 5 minutos. Si sigue fallando, revisa el instance profile (Error 5.E).

### Error 7.H: ansible-playbook falla con "Failed to connect via aws_ssm"
**Causa A:** falta el plugin `session-manager-plugin` en el runner — revisar el step de `dpkg -i`.
**Causa B:** el runner no tiene credenciales activas — el step `aws-actions/configure-aws-credentials` debe estar antes del playbook.
**Causa C:** el bucket S3 `dkron-ansible-ssm-*` no existe (Terraform aún no lo creó) o el role no puede escribir en él.

### Error 7.I: ansible-deploy es exitoso pero el smoke test al ALB falla
**Causa:** el container arrancó pero el ALB target group aún no marca healthy.
**Solución:** el loop espera 200s. Si sigue rojo:

```bash
aws elbv2 describe-target-health --target-group-arn <arn>
```
Lee `Reason` del target. Si dice `Target.Timeout`, revisa el SG-app — debe permitir ingress en 8080 desde el SG del ALB.

### 🚫 Regla del PDF 5.3.8 — `continue-on-error: true` está prohibido en pasos críticos

> El PDF dice literalmente: *"Ningún paso crítico con `continue-on-error: true`. Si el pipeline necesita tolerar un error, la decisión se documenta."*

**Qué NO debes hacer:**
```yaml
- name: Trivy scan
  uses: aquasecurity/trivy-action@master
  continue-on-error: true   # ❌ esto invalida el escaneo de seguridad
```

**Qué SÍ está permitido (y cómo se documenta):**
```yaml
- name: Subir reporte de cobertura (no crítico)
  uses: codecov/codecov-action@v4
  continue-on-error: true   # ✅ cobertura es informativa, no bloqueante;
                            #    documentado en REPORTE.md sección C
```

Como **regla mental**: si el step VALIDA seguridad o calidad (Trivy, Checkov, ansible-lint, terraform validate, fmt), su falla DEBE bloquear el pipeline. Si el step solo OBSERVA (notificar Slack, subir artefactos, métricas de cobertura), `continue-on-error: true` es legítimo y se justifica una sola vez en el reporte.

> 📝 **Para el reporte sección C (problemas):** si encuentras un step que necesitas tolerar (ej. una API externa intermitente), documéntalo como "decisión consciente" con: por qué tolerar el error, qué pasa si el error persiste, cómo lo detectaríamos a posteriori (alarma, log, dashboard).

## 🎯 Lo que aprendiste:
- **Concepto B.3 del reporte:** Implementaste **Continuous Delivery**, no Deployment, porque el `apply` requiere aprobación manual en el environment "production". Eso es deliberado.
- **Concepto B.2 del reporte (cierre):** ahora tienes el comparativo completo. CI/CD con containers + Ansible deploy es: (1) build de la imagen una vez en ECR, (2) `terraform apply` declarativo, (3) `ansible-playbook` que solo hace `docker pull` + restart. La parte que toma minutos es el ECR push y la primera creación de Fargate; el deploy real (Ansible sobre la EC2 ya provisionada) tarda **30-60 segundos**. Si todo viviera en EC2 sin containers, ese deploy implicaría compilar Dkron en la VM, gestionar dependencias del SO, manejar `systemd`, hacer rollback manual: minutos por deploy y mucha superficie operativa.

---

<a id="parte-8"></a>
# PARTE 8 — Observabilidad: dashboards, SLOs y alertas

> **Arquitectura híbrida en este Caso D:** Dkron corre en **EC2 + Compose** (configurado por Ansible). Prometheus y Grafana corren en **ECS Fargate** con EFS persistente. El bridge entre los dos mundos lo explicamos en la sección 8.2 — Prometheus descubre la EC2 vía `file_sd_configs` que Terraform regenera con la IP privada actual.

## 🗺️ Diagrama: cómo viaja una métrica desde Dkron (EC2) hasta tu email (Prom/Grafana en Fargate)

```
  ┌─────────────────────────────────────────────────────────────────┐
  │                          VPC (subnet privada)                   │
  │                                                                 │
  │  ┌─────────────────────┐                                        │
  │  │  EC2 (Dkron host)   │                                        │
  │  │  Containers:        │                                        │
  │  │   • dkron       8080│                                        │
  │  │   • node_exporter   │                                        │
  │  │             :9100   │                                        │
  │  │  IP: 10.20.10.42    │                                        │
  │  └────────┬────────────┘                                        │
  │           │ HTTP GET /metrics cada 30s                          │
  │           │ (target estático escrito por Terraform en           │
  │           │  /etc/prometheus/targets/dkron.json)                │
  │           ▼                                                     │
  │  ┌─────────────────────────────────────────────┐                │
  │  │  ECS Service: Prometheus                    │                │
  │  │   ├─ container prometheus  :9090            │                │
  │  │   ├─ container alertmanager :9093           │                │
  │  │   └─ EFS volume: /prometheus, /alertmanager │                │
  │  └────────┬──────────────────────────┬─────────┘                │
  │           │ PromQL query             │ webhook (alerta)         │
  │           ▼                          ▼                          │
  │  ┌─────────────────┐         ┌────────────────────┐             │
  │  │  ECS Service:   │         │  Lambda            │             │
  │  │     Grafana     │         │  alertmgr-to-sns   │             │
  │  │  dashboards     │         └─────────┬──────────┘             │
  │  │  ALB :3000      │                   │ Publish                │
  │  └─────────────────┘                   ▼                        │
  └────────────────────────────────╔══════════════════╗─────────────┘
                                   ║  SNS Topic       ║
                                   ║  dkron-alerts    ║
                                   ╚════════╤═════════╝
                                            │
                                            ▼
                                     ┌──────────────┐
                                     │  📧 EMAIL    │
                                     │   a ti       │
                                     └──────────────┘
```

**Método RED para el dashboard** (tres números clave para servicios request-driven):
- **R**ate: cuántos jobs por minuto.
- **E**rrors: cuántos fallan.
- **D**uration: cuánto tardan (p95).

Dkron es scheduler, no servicio request-driven, pero RED aplica igual a la "ejecución de jobs": tasa de ejecuciones, tasa de errores, duración.

## ❓ 8.1 ¿Por qué Prometheus + Grafana y no solo CloudWatch?
La sección 5.4 del PDF deja tres caminos válidos. Tomamos **Camino 1 — Self-hosted Prometheus + Grafana** porque:
- **Métricas nativas de Dkron son Prometheus:** `/metrics` está en formato Prometheus, así que no hace falta adaptador ni EMF.
- **PromQL es portable:** las mismas queries que probaste en local (Parte 3) corren idénticas en AWS — cero retrabajo.
- **Grafana > CloudWatch dashboard:** plantillas, alertas, anotaciones, exportable como JSON al repo.
- **Es el estándar de la industria** en monitoreo de aplicaciones — vale más para tu CV y para el reporte (Concepto B.4).

**Desvío deliberado del Camino 1 oficial — IMPORTANTE para el reporte:** el PDF describe Camino 1 como *"Self-hosted Prometheus + Grafana + **Loki**"*. Nosotros sustituimos **Loki por CloudWatch Logs** (driver `awslogs` nativo, escrito desde el `docker-compose.yml.j2` que renderiza Ansible en la EC2). Razones:
- Docker en la EC2 ya escribe a CloudWatch Logs sin configuración extra (configurando `logging.driver: awslogs` en el compose) — es free tier hasta 5 GB/mes.
- Loki agregaría un cuarto container en Fargate + otro access point EFS + un agente promtail dentro del compose de la EC2 = +$8/mes y más superficie operativa.
- El requisito de 5.4 (último bullet) es *"logs centralizados y buscables con correlación a métricas"* — CloudWatch Logs Insights cumple ese criterio (ver 8.7).

### 🛡️ Guion para DEFENDER el desvío en el reporte (sección A)

> 💡 Esta es la razón por la que un evaluador estricto podría restar puntos si solo escribes "usé CloudWatch en vez de Loki". El criterio del PDF es **"qué se eligió, qué alternativas se consideraron y bajo qué condiciones la decisión se revisaría"** (sección 6.2 A). Aquí va el guion completo, listo para que lo escribas con tus palabras.

**Pregunta 1: ¿Por qué no Camino 2 puro (CloudWatch nativo)?**
Porque Dkron expone métricas en formato Prometheus nativo (`/metrics`). Camino 2 obligaría a:
- Convertir las métricas a EMF (CloudWatch Embedded Metric Format) o
- Usar el ADOT collector como sidecar para traducir Prometheus → CloudWatch Metrics.
Ambas opciones añaden un componente de traducción que **introduce un punto de fallo y rompe la portabilidad**. Las queries que escribes en local (PARTE 3 de la guía) dejarían de servir.

**Pregunta 2: ¿Por qué no Camino 3 (AMP + AMG managed)?**
Es la opción técnicamente más correcta para un entorno productivo real, pero:
- **AMG cuesta ~$9 por usuario activo/mes desde el día 1**, sin free tier. Para un proyecto académico con un usuario el costo es desproporcionado.
- AMP sí está cubierto por free tier para los primeros 50 millones de samples/mes, pero **emparejarlo con AMG** es donde el costo aparece.
- En un entorno productivo real con equipo de SRE, **migraríamos a AMP+AMG** para eliminar la operativa de containers de observabilidad.

**Pregunta 3: ¿Por qué Camino 1 PERO sin Loki?**
Porque el requisito real del PDF (5.4 último bullet) habla de **"logs centralizados y buscables con correlación a métricas en el mismo timeframe"** — y eso lo cumplimos con dos herramientas distintas:
- Métricas: Prometheus self-hosted (cumple "self-hosted" del Camino 1).
- Logs: CloudWatch Logs Insights, accesible desde Grafana vía el datasource oficial CloudWatch (`grafana-cloudwatch-datasource` viene preinstalado).

La correlación logs↔métricas se hace dentro de Grafana sin saltar de UI, igual que con Loki. La única diferencia técnica es **LogQL vs CloudWatch Insights query language** — ambos son potentes, ninguno es estándar industria fuera de su ecosistema.

**Pregunta 4: ¿Bajo qué condiciones revisaría esta decisión?**
Tres triggers concretos para migrar a Loki:
1. **Volumen >10 GB/mes de logs**: CloudWatch cobra $0.50/GB ingest + $0.03/GB stored. Loki en EFS sale más barato a partir de cierto volumen.
2. **Necesidad de queries con cardinality alta** sobre labels (ej. `job_id`, `tenant_id`): LogQL maneja labels como Prometheus, Insights regex es más caro computacionalmente.
3. **Eliminación de toda dependencia de servicios AWS** para portabilidad multi-cloud: si la organización decide salir de AWS, Loki+Prom+Grafana es portable, CloudWatch Logs Insights no.

**Pregunta 5: ¿Cómo es esto compatible con la regla de "no saltar entre escenarios" del PDF (sección 2)?**
Esa regla aplica a la elección de **escenario** (A/B/C/D), no al camino de observabilidad. La sección 5.4 explícitamente permite **elegir uno de los tres caminos** y, dentro del Camino 1, omitir Loki es un trade-off documentado, no un cambio de escenario.

### 📝 Plantilla de párrafo listo para tu sección A del reporte (no copies — reescribe con tus palabras)

> "Para la observabilidad opté por el Camino 1 de la sección 5.4 (Self-hosted Prom + Grafana) con un desvío respecto al stack canónico: sustituí Loki por CloudWatch Logs Insights. La razón es que Dkron y los containers que corren en la EC2 ya empujan logs vía el driver awslogs, así que añadir Loki implicaría un container adicional en Fargate, un access point de EFS dedicado y un agente promtail en el compose, sumando ~$8/mes y otra pieza que mantener. CloudWatch Logs Insights cumple el requisito del último bullet de la sección 5.4 ('logs centralizados y buscables') y permite correlación con las métricas vía el datasource oficial de Grafana, sin perder la capacidad de filtrar por job_id. Revisaría esta decisión si el volumen de logs supera 10 GB/mes (donde Loki se vuelve más barato) o si el equipo decide reducir dependencia de servicios AWS específicos. Camino 3 (AMP+AMG) habría sido más correcto en producción real, pero AMG cobra por usuario activo desde el día 1 sin free tier, lo que descarta esa opción para el alcance del bootcamp."

**Trade-offs adicionales que también van al reporte:**
- Costo: 2 tasks Fargate extra (~$14/mes 24/7 con 0.25 vCPU/0.5 GB c/u; con FARGATE_SPOT y destroy nocturno baja a ~$2/mes — ver PARTE 12.1).
- Operación: tú mantienes la pila Prom/Grafana; CloudWatch Logs es managed.
- Persistencia: necesitas EFS para que Prometheus no pierda los datos en cada redeploy del task.

> ⚠️ **Alternativa managed equivalente — Camino 3:** AMP + AMG. Misma semántica, sin operar containers. Lo descartamos por AMG ($9/usuario/mes sin free tier). Mencionarlo demuestra que conoces el espacio managed.

## ❓ 8.2 ¿Cómo despliego Prometheus y Grafana en ECS, y cómo descubren la EC2 con Dkron?
Vamos a crear **dos servicios ECS adicionales** en la misma VPC privada, con **EFS** para persistir datos. Crea `infra/modules/monitoring/`:

### 🖱️ Equivalente en AWS Console (mapa completo del módulo `monitoring/`)

> 🧠 **Esta sección crea ~15 recursos.** Antes de pegar el Terraform, mira la tabla — así sabes "dónde irías en consola" si tuvieras que debuggear algo a mano.

| Recurso Terraform | Servicio | Que harías click-a-click |
|---|---|---|
| `aws_efs_file_system.obs` | 🗂️ EFS | **EFS → Create file system → Customize** → Name: `dkron-obs` → VPC: dkron-vpc → **Encryption: Enabled** (default KMS). |
| `aws_efs_mount_target.obs` (×2 — `for_each` sobre `private_subnet_ids`) | 🗂️ EFS | El FS → **Network → Manage** → Add mount target por **cada** subnet privada → Security group: `dkron-efs`. |
| `aws_efs_access_point.prometheus` | 🗂️ EFS | **EFS → Access points → Create access point** → File system: `dkron-obs` → Root path: `/prometheus` → POSIX user: **uid 65534 / gid 65534** (`nobody`) → Creation info: owner 65534/65534, perms `0755`. |
| `aws_efs_access_point.grafana` | 🗂️ EFS | Mismo wizard → Root path: `/grafana` → POSIX user: **uid 472 / gid 472** (uid oficial de Grafana) → Creation info: owner 472/472, perms `0755`. |
| `aws_security_group.efs` | 🌐 VPC | **VPC → Security groups → Create** → Name: `dkron-efs` → VPC: dkron-vpc → Inbound: **NFS 2049** desde los SGs `dkron-prom-sg` Y `dkron-graf-sg` → Outbound: all → Create. |
| `aws_security_group.prometheus` | 🌐 VPC | **VPC → SGs → Create** → Name: `dkron-prom-sg` → Description: "Prometheus task — scrapea EC2 y llama Lambda URL" → VPC: dkron-vpc → **Sin ingress** → Outbound: all (necesita scrapear EC2 y llamar Lambda URL). |
| `aws_security_group.grafana` | 🌐 VPC | **VPC → SGs → Create** → Name: `dkron-graf-sg` → Description: "Grafana task — recibe del ALB en 3000, consulta Prometheus" → VPC: dkron-vpc → Inbound: TCP 3000 from `0.0.0.0/0` (el ALB filtrará; el SG-alb ya es restrictivo) → Outbound: all. |
| `aws_security_group_rule.app_from_prom_8080` y `.app_from_prom_9100` | 🌐 VPC | En **`dkron-app-sg`** (creado en 5.5): **Edit inbound rules → Add rule** dos veces → TCP **8080** from SG `dkron-prom-sg` (description "Prometheus scrape Dkron"), TCP **9100** from SG `dkron-prom-sg` (description "Prometheus scrape node_exporter"). |
| `aws_ssm_parameter.prometheus_yml` | 🔐 SSM | **Systems Manager → Parameter Store → Create parameter** → Name: `/dkron/prometheus/prometheus.yml` → Tier: **Advanced** → Type: String → Value: el YAML con `scrape_configs` apuntando a `file_sd_configs` de `/etc/prometheus/targets/{dkron,dkron-host}.json`. |
| `aws_ssm_parameter.prometheus_target_dkron` | 🔐 SSM | Mismo wizard → Name: `/dkron/prometheus/targets/dkron.json` → Type: String → Value: `[{"targets":["<ec2-private-ip>:8080"],"labels":{"job":"dkron","role":"scheduler"}}]`. |
| `aws_ssm_parameter.prometheus_target_host` | 🔐 SSM | Name: `/dkron/prometheus/targets/dkron-host.json` → Type: String → Value: idem con `:9100` y label `job=dkron-host`. |
| `aws_ssm_parameter.prometheus_rules` | 🔐 SSM | Name: `/dkron/prometheus/rules.yml` → Type: String → Value: las 3 alertas `DkronHighFailureRate`, `DkronNoJobsRunning`, `DkronTargetDown`. |
| `aws_ssm_parameter.alertmanager_yml` | 🔐 SSM | Name: `/dkron/alertmanager/alertmanager.yml` → Type: String → Value: route `receiver=sns` + webhook a la Function URL de la Lambda (la rellenas tras crear la Lambda). |
| `aws_ssm_parameter.grafana_admin_password` | 🔐 SSM | Name: `/dkron/prod/grafana/admin_password` → Type: **SecureString** → KMS: alias/aws/ssm → Value: el password admin de Grafana → Tags: `Name=dkron-graf-pass`. |
| `aws_ssm_parameter.grafana_datasource` | 🔐 SSM | Name: `/dkron/grafana/datasource.yml` → Type: String → Value: YAML con datasource Prometheus `url=http://prometheus.dkron.local:9090`. |
| `aws_ssm_parameter.grafana_dashboard` | 🔐 SSM | Name: `/dkron/grafana/dashboard.json` → Tier: **Advanced** → Type: String → Value: el JSON del dashboard `dkron-red.json`. |
| `aws_ssm_parameter.grafana_dashboard_provider` | 🔐 SSM | Name: `/dkron/grafana/dashboard_provider.yml` → Type: String → Value: YAML con `providers: [{name=dkron, folder=Dkron, type=file, options.path=/var/lib/grafana/dashboards}]`. Sin este parámetro Grafana no carga el JSON al arrancar. |
| `aws_ecs_cluster.obs` | 🐳 ECS | **ECS → Clusters → Create cluster** → Name: `dkron-obs` → Infrastructure: **AWS Fargate (serverless)** → Monitoring: **Container Insights: disabled** (ahorra costo). |
| `aws_ecs_cluster_capacity_providers.obs` | 🐳 ECS | El cluster → pestaña **Infrastructure → Capacity providers → Update** → marca **FARGATE** y **FARGATE_SPOT**. |
| `aws_service_discovery_private_dns_namespace.this` | 🧭 Cloud Map | **AWS Cloud Map → Create namespace** → Name: `dkron.local` → Type: **API calls and DNS queries in VPCs** → VPC: dkron-vpc. |
| `aws_service_discovery_service.prometheus` | 🧭 Cloud Map | El namespace → **Create service** → Name: `prometheus` → Service discovery configuration: A record, TTL 10s, Routing policy **MULTIVALUE** → Health check: Custom (failure threshold 1). Así Grafana resuelve `prometheus.dkron.local`. |
| `aws_cloudwatch_log_group.obs` | 📊 CloudWatch | **CloudWatch → Log groups → Create log group** → Name: `/dkron/ecs/obs` → Retention: **1 day**. Un **único** log group compartido por Prometheus, Alertmanager y Grafana (stream prefix los separa). |
| `aws_iam_role.exec` | 🔐 IAM | **IAM → Roles → Create role** → Trusted entity: AWS service → Use case: **Elastic Container Service → ECS Task** → Role name: `dkron-obs-exec` → Attach managed: `AmazonECSTaskExecutionRolePolicy` → luego **Create inline policy** → JSON: `ssm:GetParameter, ssm:GetParameters, kms:Decrypt` sobre `arn:aws:ssm:us-east-1:*:parameter/dkron/*`. |
| `aws_iam_role.task` | 🔐 IAM | Mismo wizard → Role name: `dkron-obs-task` → **Create inline policy** → JSON: `elasticfilesystem:ClientMount/ClientWrite/ClientRootAccess` sobre el ARN del file system `dkron-obs`. |
| `aws_iam_role.lambda` + policies | 🔐 IAM | **IAM → Roles → Create role** → Use case: **Lambda** → Role name: `dkron-alertmgr-lambda` → Attach managed: `AWSLambdaBasicExecutionRole` → **Create inline policy**: `sns:Publish` sobre el ARN del topic `dkron-alerts`. |
| `aws_ecs_task_definition.prometheus` | 🐳 ECS | **ECS → Task definitions → Create new task definition** → Family: `dkron-prometheus` → Launch type: **Fargate** → CPU: 0.25 vCPU, Memory: 0.5 GB → Execution role: `dkron-obs-exec`, Task role: `dkron-obs-task` → Containers: `config-init` (essential=false, `dependsOn=null`, lee SSM con awscli) + `prometheus:v2.54.1` (essential=true, `dependsOn config-init=SUCCESS`, puerto 9090) + `alertmanager:v0.27.0` (essential=true, puerto 9093) → Volume EFS `prom-data` con `transit_encryption=ENABLED` y access point `prometheus`. |
| `aws_ecs_service.prometheus` | 🐳 ECS | En el cluster `dkron-obs` → **Services → Create** → Launch type: FARGATE → Task definition: `dkron-prometheus` → Service name: `prometheus` → Desired count: 1 → Network: subnets **privadas**, SG `dkron-prom-sg`, **Assign public IP: DISABLED** → Service discovery: registra al servicio Cloud Map `prometheus.dkron.local`. |
| `aws_ecs_task_definition.grafana` | 🐳 ECS | **Task definitions → Create** → Family: `dkron-grafana` → Fargate, 0.25 vCPU / 0.5 GB → Execution+Task role: `dkron-obs-exec/task` → Containers: (a) `config-init` (`amazon/aws-cli:2.15.0`, essential=false, hace `aws ssm get-parameter` de datasource + dashboard_provider + dashboard.json y los escribe a `/var/lib/grafana/provisioning/{datasources,dashboards}/` y `/var/lib/grafana/dashboards/`) + (b) `grafana:11.2.0` (essential=true, `dependsOn config-init=SUCCESS`, port 3000) con env vars `GF_SECURITY_ADMIN_USER=admin`, `GF_USERS_ALLOW_SIGN_UP=false`, `GF_AUTH_ANONYMOUS_ENABLED=false`, **`GF_PATHS_PROVISIONING=/var/lib/grafana/provisioning`** y **secret** `GF_SECURITY_ADMIN_PASSWORD` desde el SSM SecureString `dkron-graf-pass` → Volume EFS `graf-data` con access point `grafana`. |
| `aws_ecs_service.grafana` | 🐳 ECS | **Services → Create** → Task definition: `dkron-grafana` → Desired count: 1 → Network: subnets privadas, SG `dkron-graf-sg` → Load balancing: ALB existente `dkron-alb`, target group `dkron-grafana`, container `grafana`, port 3000. |
| `aws_lb_target_group.grafana` | ⚖️ EC2 | **EC2 → Target groups → Create target group** → Target type: **IP addresses** (Fargate awsvpc) → Name: `dkron-grafana` → Protocol HTTP, Port 3000 → VPC: dkron-vpc → Health check path: `/api/health`, matcher 200. |
| `aws_lb_listener.grafana` | ⚖️ EC2 | En el ALB `dkron-alb` → **Listeners → Add listener** → Protocol HTTP, Port **3000** → Default action: Forward → Target group `dkron-grafana` → Add. |
| `aws_sns_topic.alerts` | 📢 SNS | **SNS → Topics → Create topic** → Type: **Standard** → Name: `dkron-alerts` → Create. |
| `aws_sns_topic_subscription.email` | 📢 SNS | El topic → **Create subscription** → Protocol: **Email** → Endpoint: tu correo. **Confirma desde tu inbox** antes de continuar. |
| `aws_lambda_function.alertmgr_to_sns` | λ Lambda | **Lambda → Create function** → Author from scratch → Function name: `dkron-alertmgr-to-sns` → Runtime: **Python 3.12** → Architecture: x86_64 → Execution role: usar el rol existente `dkron-alertmgr-lambda` → Sube el zip generado por Terraform (`alertmgr_to_sns.zip`) o pega el código del handler que itera `body["alerts"]` y publica en SNS → Configuration → Environment variables: `TOPIC_ARN = <arn del topic dkron-alerts>`. |
| `aws_lambda_function_url.alertmgr_to_sns` | λ Lambda | La función → **Configuration → Function URL → Create function URL** → Auth type: **NONE** → Save. La URL resultante es la que apunta Alertmanager en `alertmanager.yml` (solo Alertmanager dentro de la VPC la conoce). |

> 🎯 **Por qué hay tantos recursos:** Prometheus y Grafana no son "una EC2 con un docker compose" — los corremos como containers Fargate independientes para que **no compitan con Dkron por CPU/RAM** en la t3.micro. La complejidad extra (EFS, IAM roles, task definitions, SGs) es el precio de la separación. En el reporte sección A justifica esta decisión.

### 📦 Estructura del módulo `monitoring/` (8 archivos)

```
infra/modules/monitoring/
├── variables.tf      # 8.2.0 — variables del módulo
├── iam.tf            # 8.2.1 — IAM roles (exec, task, lambda)
├── sg.tf             # 8.2.2 — Security Groups (prom, graf, efs)
├── efs.tf            # 8.2.3 — EFS + access points (Paso 1)
├── cluster.tf        # 8.2.4 — ECS cluster + Cloud Map + log group
├── config.tf         # 8.2.5 — SSM params (prom.yml, rules.yml, etc.) (Paso 2)
├── prometheus.tf     # 8.2.6 — Task + Service Prometheus (Paso 4)
├── grafana.tf        # 8.2.7 — Task + Service Grafana + ALB :3000 (Paso 5)
├── lambda_sns.tf     # 8.2.8 — Lambda + SNS topic (Paso 6)
├── outputs.tf        # 8.2.9 — outputs del módulo
└── dashboards/
    └── dkron-red.json
```

### ⚠️ Antes de continuar — copia el dashboard JSON al path del módulo

> 🛑 **PASO OBLIGATORIO ANTES DE `terraform apply`** — el archivo `grafana.tf` (más abajo) referencia `file("${path.module}/dashboards/dkron-red.json")`. Si no existe, `terraform apply -target=module.monitoring` revienta con `Error: Invalid function argument: open ...: no such file or directory`.

```bash
mkdir -p infra/modules/monitoring/dashboards
cp compose/grafana/provisioning/dashboards/dkron-red.json infra/modules/monitoring/dashboards/dkron-red.json
```

Es el **mismo** JSON que ya pegaste en la Parte 3 (sección 3.2). Versionarlo aquí satisface el requisito PDF "dashboards versionados como código".

### 📋 8.2.0 `infra/modules/monitoring/variables.tf` (copy-paste)

```hcl
# infra/modules/monitoring/variables.tf
variable "project"               { type = string }
variable "environment"           { type = string }
variable "region"                { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_ids"    { type = list(string) }

# Inputs desde otros módulos
variable "alb_arn" {
  type        = string
  description = "ARN del ALB existente (módulo compute). Le añadimos listener :3000 para Grafana."
}
variable "ec2_private_ip" {
  type        = string
  description = "IP privada de la EC2 con Dkron — Prometheus la usa en file_sd_configs."
}
variable "app_security_group_id" {
  type        = string
  description = "SG de la EC2 con Dkron. Aquí abrimos 8080/9100 desde el SG de Prometheus."
}

# Configuración propia del módulo
variable "alert_email" {
  type        = string
  description = "Email destino del topic SNS de alertas."
}
variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Password del usuario admin de Grafana. Se guarda en SSM SecureString."
}
variable "prometheus_image" {
  type    = string
  default = "prom/prometheus:v2.54.1"
}
variable "alertmanager_image" {
  type    = string
  default = "prom/alertmanager:v0.27.0"
}
variable "grafana_image" {
  type    = string
  default = "grafana/grafana:11.2.0"
}
```

### 📋 8.2.1 `infra/modules/monitoring/iam.tf` (copy-paste)

```hcl
# infra/modules/monitoring/iam.tf

# ───── ECS Task Execution Role (lo usa Fargate para pull imagen + log) ─────
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"  identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}

resource "aws_iam_role" "exec" {
  name               = "${var.project}-obs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "exec_managed" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# El config-init container lee SSM con awscli — necesita ssm:GetParameter
resource "aws_iam_role_policy" "exec_ssm" {
  role = aws_iam_role.exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "kms:Decrypt"]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project}/*"
    }]
  })
}

# ───── ECS Task Role (lo usan los containers en runtime — EFS-IAM, etc.) ─────
resource "aws_iam_role" "task" {
  name               = "${var.project}-obs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy" "task_efs" {
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess"
      ]
      Resource = aws_efs_file_system.obs.arn
    }]
  })
}

# ───── Lambda role (Alertmanager → SNS) ─────
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"  identifiers = ["lambda.amazonaws.com"] }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project}-alertmgr-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sns:Publish"]
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}
```

### 📋 8.2.2 `infra/modules/monitoring/sg.tf` (copy-paste)

```hcl
# infra/modules/monitoring/sg.tf

# ───── SG de la task Prometheus ─────
resource "aws_security_group" "prometheus" {
  name        = "${var.project}-prom-sg"
  description = "Prometheus task — scrapea EC2 y llama Lambda URL"
  vpc_id      = var.vpc_id

  egress { from_port = 0  to_port = 0  protocol = "-1"  cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project}-prom-sg" }
}

# ───── SG de la task Grafana ─────
resource "aws_security_group" "grafana" {
  name        = "${var.project}-graf-sg"
  description = "Grafana task — recibe del ALB en 3000, consulta Prometheus"
  vpc_id      = var.vpc_id

  ingress {
    description = "ALB → Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # el ALB filtrará; el SG del ALB ya es restrictivo
  }
  egress { from_port = 0  to_port = 0  protocol = "-1"  cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project}-graf-sg" }
}

# ───── Reglas cross-módulo: abrir 8080/9100 en el SG-app desde el SG-prom ─────
# Patrón del 5.4: las reglas que cruzan módulos viven en aws_security_group_rule
# para evitar ciclos. Aquí monitoring "extiende" el SG-app de compute.
resource "aws_security_group_rule" "app_from_prom_8080" {
  type                     = "ingress"
  description              = "Prometheus scrape Dkron"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.app_security_group_id
  source_security_group_id = aws_security_group.prometheus.id
}

resource "aws_security_group_rule" "app_from_prom_9100" {
  type                     = "ingress"
  description              = "Prometheus scrape node_exporter"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = var.app_security_group_id
  source_security_group_id = aws_security_group.prometheus.id
}
```

### Paso 1 — EFS para datos persistentes
**`infra/modules/monitoring/efs.tf`:**
```hcl
resource "aws_efs_file_system" "obs" {
  creation_token = "dkron-obs"
  encrypted      = true
  tags           = { Name = "dkron-obs" }
}

resource "aws_efs_mount_target" "obs" {
  for_each        = toset(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.obs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "prometheus" {
  file_system_id = aws_efs_file_system.obs.id
  posix_user { uid = 65534, gid = 65534 }     # usuario `nobody` (Prometheus corre así)
  root_directory {
    path = "/prometheus"
    creation_info { owner_uid = 65534, owner_gid = 65534, permissions = "0755" }
  }
}

resource "aws_efs_access_point" "grafana" {
  file_system_id = aws_efs_file_system.obs.id
  posix_user { uid = 472, gid = 472 }          # uid oficial de Grafana
  root_directory {
    path = "/grafana"
    creation_info { owner_uid = 472, owner_gid = 472, permissions = "0755" }
  }
}

resource "aws_security_group" "efs" {
  name   = "dkron-efs"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id, aws_security_group.grafana.id]
  }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}
```

### Paso 1.5 — ECS cluster + Cloud Map + Log group + password Grafana

**`infra/modules/monitoring/cluster.tf`** (copy-paste):
```hcl
# infra/modules/monitoring/cluster.tf

# ───── ECS cluster Fargate para Prom/Graf ─────
resource "aws_ecs_cluster" "obs" {
  name = "${var.project}-obs"
  setting { name = "containerInsights" value = "disabled" }   # ahorra costo
}

resource "aws_ecs_cluster_capacity_providers" "obs" {
  cluster_name       = aws_ecs_cluster.obs.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

# ───── Cloud Map: DNS privado para que Grafana le hable a Prometheus ─────
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.project}.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config { failure_threshold = 1 }
}

# ───── Log group compartido para Prom/Alertmgr/Grafana ─────
resource "aws_cloudwatch_log_group" "obs" {
  name              = "/${var.project}/ecs/obs"
  retention_in_days = 1
}

# ───── Password admin de Grafana en SSM SecureString ─────
resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/${var.project}/${var.environment}/grafana/admin_password"
  type  = "SecureString"
  value = var.grafana_admin_password
  tags  = { Name = "${var.project}-graf-pass" }
}
```

### Paso 2 — Configuración de Prometheus en SSM
Sube los `prometheus.yml` y `rules.yml` como parámetros de SSM (versionados con el código):

**`infra/modules/monitoring/config.tf`:**
```hcl
resource "aws_ssm_parameter" "prometheus_yml" {
  name = "/dkron/prometheus/prometheus.yml"
  type = "String"
  tier = "Advanced"
  value = yamlencode({
    global = { scrape_interval = "30s", evaluation_interval = "30s" }
    rule_files = ["/etc/prometheus/rules.yml"]
    alerting = {
      alertmanagers = [{ static_configs = [{ targets = ["localhost:9093"] }] }]
    }
    scrape_configs = [
      # Dkron vive en EC2 (no en ECS). Usamos file_sd_configs: Terraform
      # genera /etc/prometheus/targets/dkron.json con la IP privada actual
      # y Prometheus lo recarga automáticamente cada 5m (default file_sd).
      {
        job_name        = "dkron"
        metrics_path    = "/metrics"
        file_sd_configs = [{ files = ["/etc/prometheus/targets/dkron.json"] }]
      },
      # node_exporter en la misma EC2 (puerto 9100) para CPU/RAM/disk del host
      {
        job_name        = "dkron-host"
        file_sd_configs = [{ files = ["/etc/prometheus/targets/dkron-host.json"] }]
      }
    ]
  })
}

# Targets por archivo. Terraform los regenera con la IP privada de la EC2.
resource "aws_ssm_parameter" "prometheus_target_dkron" {
  name = "/dkron/prometheus/targets/dkron.json"
  type = "String"
  value = jsonencode([{
    targets = ["${var.ec2_private_ip}:8080"]
    labels  = { job = "dkron", role = "scheduler" }
  }])
}

resource "aws_ssm_parameter" "prometheus_target_host" {
  name = "/dkron/prometheus/targets/dkron-host.json"
  type = "String"
  value = jsonencode([{
    targets = ["${var.ec2_private_ip}:9100"]
    labels  = { job = "dkron-host", role = "node_exporter" }
  }])
}

resource "aws_ssm_parameter" "prometheus_rules" {
  name = "/dkron/prometheus/rules.yml"
  type = "String"
  value = yamlencode({
    groups = [{
      name = "dkron.rules"
      rules = [
        {
          alert       = "DkronHighFailureRate"
          expr        = "increase(dkron_failed_jobs_total[5m]) > 5"
          for         = "2m"
          labels      = { severity = "warning" }
          annotations = { summary = "Más de 5 jobs fallidos en 5 min" }
        },
        {
          alert       = "DkronNoJobsRunning"
          expr        = "max_over_time(dkron_running_jobs[1h]) < 1"
          for         = "10m"
          labels      = { severity = "critical" }
          annotations = { summary = "Scheduler sin actividad — posible caída" }
        },
        {
          alert       = "DkronTargetDown"
          expr        = "up{job=\"dkron\"} == 0"
          for         = "2m"
          labels      = { severity = "critical" }
          annotations = { summary = "Dkron no responde a Prometheus" }
        }
      ]
    }]
  })
}

resource "aws_ssm_parameter" "alertmanager_yml" {
  name = "/dkron/alertmanager/alertmanager.yml"
  type = "String"
  value = yamlencode({
    route = {
      receiver        = "sns"
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = "1h"
    }
    receivers = [{
      name = "sns"
      webhook_configs = [{
        url           = "https://${aws_lambda_function_url.alertmgr_to_sns.url_id}.lambda-url.${var.region}.on.aws/"
        send_resolved = true
      }]
    }]
  })
}
```

### Paso 3 — Service Discovery cross-compute: Prometheus (ECS) → Dkron (EC2)

> Este es el "bridge" que mencionamos al inicio. Originalmente, una arquitectura "Fargate puro" usaría **Cloud Map** con `dns_sd_configs` apuntando a `dkron.dkron.local`. **Aquí no aplica** porque Dkron NO vive en una task ECS — vive en una EC2 con IP fija dentro de la subnet privada. Usamos **`file_sd_configs`** con la IP gestionada por Terraform.

**Flujo del descubrimiento:**
```
   Terraform crea EC2  ─────▶  Output: ec2_private_ip = 10.20.10.42
                                     │
                                     ▼
   El módulo monitoring/ recibe ec2_private_ip como var
   y escribe los SSM parameters:
     /dkron/prometheus/targets/dkron.json       → [{"targets":["10.20.10.42:8080"]}]
     /dkron/prometheus/targets/dkron-host.json  → [{"targets":["10.20.10.42:9100"]}]
                                     │
                                     ▼
   Task de Prometheus (config-init container) hace:
     aws ssm get-parameter --name /dkron/prometheus/targets/dkron.json \
       > /etc/prometheus/targets/dkron.json
                                     │
                                     ▼
   prometheus.yml referencia:
     scrape_configs:
       - job_name: dkron
         file_sd_configs:
           - files: [/etc/prometheus/targets/dkron.json]
                                     │
                                     ▼
   Prometheus recarga el archivo automáticamente cada 5m.
   Si la IP cambia (ej. terraform taint en la EC2), basta con hacer
   apply + force-new-deployment del task de Prom para re-leer SSM.
```

**¿Por qué no usar `ec2_sd_configs` nativo de Prometheus?** Sería elegante pero requeriría darle a la task de Prometheus permisos `ec2:DescribeInstances` y resolver IAM cross-cuenta. La opción de `file_sd_configs` mantiene el path de permisos limitado a SSM (mínimo privilegio, B.5 del reporte).

**Nada que añadir al módulo `compute/`** — el bridge ya queda completamente implementado:
- Los dos `aws_ssm_parameter` con la IP de la EC2 (Paso 2 — `config.tf`).
- Las reglas SG cross-módulo `app_from_prom_8080` y `app_from_prom_9100` (8.2.2 — `sg.tf`).
- Las vars `ec2_private_ip`, `app_security_group_id`, `alb_arn`, etc. (declaradas en 8.2.0 — `variables.tf`).

La instanciación de `module "monitoring"` en `envs/prod/main.tf` y el `apply -target=module.monitoring` van **al final** de la sección 8.2 (tras Paso 6 + outputs).

<!-- buried block obsoleto removido — el contenido vive ahora en 8.2.0, 8.2.2 y al final de 8.2 -->
<details>
<summary>Referencia histórica (puedes ignorar)</summary>

> **Variables necesarias en el módulo `monitoring/`:**
> ```hcl
> variable "ec2_private_ip" {
>   type        = string
>   description = "IP privada de la EC2 donde corre Dkron — viene de module.compute"
> }
> variable "app_security_group_id" {
>   type        = string
>   description = "SG de la EC2; aquí se le abren puertos 8080/9100 al SG de Prom"
> }
> ```
> Reglas de SG **dentro** del módulo `monitoring/main.tf` (sin ciclo):
> ```hcl
> resource "aws_security_group_rule" "app_from_prom_8080" {
>   type                     = "ingress"
>   from_port                = 8080
>   to_port                  = 8080
>   protocol                 = "tcp"
>   security_group_id        = var.app_security_group_id
>   source_security_group_id = aws_security_group.prometheus.id
> }
> resource "aws_security_group_rule" "app_from_prom_9100" {
>   type                     = "ingress"
>   from_port                = 9100
>   to_port                  = 9100
>   protocol                 = "tcp"
>   security_group_id        = var.app_security_group_id
>   source_security_group_id = aws_security_group.prometheus.id
> }
> ```
> Y en `infra/envs/prod/main.tf`:
> ```hcl
> module "monitoring" {
>   source                = "../../modules/monitoring"
>   # ... resto de vars
>   ec2_private_ip        = module.compute.ec2_private_ip
>   app_security_group_id = module.compute.app_sg_id
> }
> ```

</details>

### Paso 4 — Task Definition de Prometheus + Alertmanager
**`infra/modules/monitoring/prometheus.tf`:**
```hcl
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "dkron-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  volume {
    name = "prom-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.obs.id
      transit_encryption = "ENABLED"
      authorization_config { access_point_id = aws_efs_access_point.prometheus.id, iam = "ENABLED" }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "config-init"
      image     = "amazon/aws-cli:2.15.0"
      essential = false
      command = ["sh", "-c", <<-EOT
        mkdir -p /etc/prometheus/targets
        aws ssm get-parameter --name /dkron/prometheus/prometheus.yml --query Parameter.Value --output text > /etc/prometheus/prometheus.yml
        aws ssm get-parameter --name /dkron/prometheus/rules.yml      --query Parameter.Value --output text > /etc/prometheus/rules.yml
        aws ssm get-parameter --name /dkron/prometheus/targets/dkron.json      --query Parameter.Value --output text > /etc/prometheus/targets/dkron.json
        aws ssm get-parameter --name /dkron/prometheus/targets/dkron-host.json --query Parameter.Value --output text > /etc/prometheus/targets/dkron-host.json
        aws ssm get-parameter --name /dkron/alertmanager/alertmanager.yml --query Parameter.Value --output text > /etc/alertmanager/alertmanager.yml
      EOT
      ]
      mountPoints = [
        { sourceVolume = "prom-data", containerPath = "/etc/prometheus" },
        { sourceVolume = "prom-data", containerPath = "/etc/alertmanager" }
      ]
    },
    {
      name      = "prometheus"
      image     = "prom/prometheus:v2.54.1"
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{ containerPort = 9090, protocol = "tcp" }]
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--storage.tsdb.retention.time=15d",
        "--web.enable-lifecycle"
      ]
      mountPoints = [
        { sourceVolume = "prom-data", containerPath = "/prometheus" },
        { sourceVolume = "prom-data", containerPath = "/etc/prometheus" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    },
    {
      name      = "alertmanager"
      image     = "prom/alertmanager:v0.27.0"
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{ containerPort = 9093, protocol = "tcp" }]
      command = ["--config.file=/etc/alertmanager/alertmanager.yml"]
      mountPoints = [{ sourceVolume = "prom-data", containerPath = "/etc/alertmanager" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "alertmanager"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = aws_ecs_cluster.obs.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.prometheus.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }
}
```

### Paso 5 — Grafana con dashboards provisionados
**`infra/modules/monitoring/grafana.tf`:**
```hcl
resource "aws_ssm_parameter" "grafana_datasource" {
  name = "/dkron/grafana/datasource.yml"
  type = "String"
  value = yamlencode({
    apiVersion = 1
    datasources = [{
      name      = "Prometheus"
      type      = "prometheus"
      access    = "proxy"
      url       = "http://prometheus.dkron.local:9090"
      isDefault = true
    }]
  })
}

resource "aws_ssm_parameter" "grafana_dashboard" {
  name  = "/dkron/grafana/dashboard.json"
  type  = "String"
  tier  = "Advanced"
  value = file("${path.module}/dashboards/dkron-red.json")   # mismo JSON que en compose/grafana/provisioning/dashboards/
}

# Provider que le dice a Grafana DÓNDE buscar dashboards .json (autoload).
resource "aws_ssm_parameter" "grafana_dashboard_provider" {
  name = "/dkron/grafana/dashboard_provider.yml"
  type = "String"
  value = yamlencode({
    apiVersion = 1
    providers = [{
      name    = "dkron"
      folder  = "Dkron"
      type    = "file"
      options = { path = "/var/lib/grafana/dashboards" }
    }]
  })
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "dkron-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  volume {
    name = "graf-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.obs.id
      transit_encryption = "ENABLED"
      authorization_config { access_point_id = aws_efs_access_point.grafana.id, iam = "ENABLED" }
    }
  }

  container_definitions = jsonencode([
    # Init container: baja datasource + dashboard + provider de SSM al EFS
    # ANTES de que arranque Grafana. Sin esto, Grafana arranca vacío.
    {
      name      = "config-init"
      image     = "amazon/aws-cli:2.15.0"
      essential = false
      command = ["sh", "-c", <<-EOT
        set -e
        mkdir -p /var/lib/grafana/provisioning/datasources
        mkdir -p /var/lib/grafana/provisioning/dashboards
        mkdir -p /var/lib/grafana/dashboards
        aws ssm get-parameter --name /dkron/grafana/datasource.yml          --query Parameter.Value --output text > /var/lib/grafana/provisioning/datasources/prometheus.yml
        aws ssm get-parameter --name /dkron/grafana/dashboard_provider.yml  --query Parameter.Value --output text > /var/lib/grafana/provisioning/dashboards/dkron.yml
        aws ssm get-parameter --name /dkron/grafana/dashboard.json          --query Parameter.Value --output text > /var/lib/grafana/dashboards/dkron-red.json
        # Grafana corre como uid 472 — el access point EFS ya pone owner 472:472, pero forzamos por si acaso
        chown -R 472:472 /var/lib/grafana/provisioning /var/lib/grafana/dashboards || true
      EOT
      ]
      mountPoints = [{ sourceVolume = "graf-data", containerPath = "/var/lib/grafana" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "grafana-init"
        }
      }
    },
    {
      name      = "grafana"
      image     = "grafana/grafana:11.2.0"
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER",      value = "admin" },
        { name = "GF_USERS_ALLOW_SIGN_UP",      value = "false" },
        { name = "GF_AUTH_ANONYMOUS_ENABLED",   value = "false" },
        # Le dice a Grafana que las definiciones de provisioning están en EFS
        # (path por defecto es /etc/grafana/provisioning, lo movemos a /var/lib/grafana)
        { name = "GF_PATHS_PROVISIONING",       value = "/var/lib/grafana/provisioning" }
      ]
      secrets = [
        { name = "GF_SECURITY_ADMIN_PASSWORD", valueFrom = aws_ssm_parameter.grafana_admin_password.arn }
      ]
      mountPoints = [{ sourceVolume = "graf-data", containerPath = "/var/lib/grafana" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.obs.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.grafana.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }
}

# Listener adicional en el ALB para Grafana en puerto 3000
resource "aws_lb_listener" "grafana" {
  load_balancer_arn = var.alb_arn
  port              = 3000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_target_group" "grafana" {
  name        = "dkron-grafana"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check { path = "/api/health", matcher = "200" }
}
```

> ℹ️ **Recordatorio:** ya copiaste `compose/grafana/provisioning/dashboards/dkron-red.json` → `infra/modules/monitoring/dashboards/dkron-red.json` antes de empezar 8.2.0 (es el JSON que `grafana.tf` arriba lee con `file(...)`).

### Paso 6 — Lambda que traduce webhooks de Alertmanager a SNS
**`infra/modules/monitoring/lambda_sns.tf`:**
```hcl
resource "aws_sns_topic" "alerts" {
  name = "dkron-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

data "archive_file" "alertmgr_to_sns" {
  type        = "zip"
  output_path = "${path.module}/build/alertmgr_to_sns.zip"
  source { filename = "index.py", content = <<-EOT
    import json, os, boto3
    sns = boto3.client("sns")
    TOPIC = os.environ["TOPIC_ARN"]
    def handler(event, _):
        body = json.loads(event.get("body") or "{}")
        for alert in body.get("alerts", []):
            sns.publish(
              TopicArn = TOPIC,
              Subject  = f"[{alert['status'].upper()}] {alert['labels'].get('alertname','dkron')}",
              Message  = json.dumps(alert, indent=2)
            )
        return { "statusCode": 200, "body": "ok" }
  EOT
  }
}

resource "aws_lambda_function" "alertmgr_to_sns" {
  function_name    = "dkron-alertmgr-to-sns"
  runtime          = "python3.12"
  handler          = "index.handler"
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.alertmgr_to_sns.output_path
  source_code_hash = data.archive_file.alertmgr_to_sns.output_base64sha256
  environment { variables = { TOPIC_ARN = aws_sns_topic.alerts.arn } }
}

resource "aws_lambda_function_url" "alertmgr_to_sns" {
  function_name      = aws_lambda_function.alertmgr_to_sns.function_name
  authorization_type = "NONE"   # OK porque solo Alertmanager (en la VPC) conoce la URL
}
```

### 📋 8.2.9 `infra/modules/monitoring/outputs.tf` (copy-paste)

```hcl
# infra/modules/monitoring/outputs.tf
output "ecs_cluster_name"          { value = aws_ecs_cluster.obs.name }
output "prometheus_service_name"   { value = aws_ecs_service.prometheus.name }
output "grafana_service_name"      { value = aws_ecs_service.grafana.name }
output "grafana_target_group_arn"  { value = aws_lb_target_group.grafana.arn }
output "sns_topic_arn"             { value = aws_sns_topic.alerts.arn }
output "lambda_function_url"       { value = aws_lambda_function_url.alertmgr_to_sns.function_url }
output "log_group_obs"             { value = aws_cloudwatch_log_group.obs.name }
```

### 🔌 Instancia el módulo en `infra/envs/prod/main.tf` (copy-paste)

> 📌 **Antes**: añade al `variables.tf` del entorno una nueva var `grafana_admin_password` (sensitive) y al `terraform.tfvars` un valor real. Es la **única** variable sensible que queda en el proyecto (antes había también `db_password`; se eliminó al pasar Dkron a BoltDB local — ver PARTE 5.4).

```hcl
# infra/envs/prod/variables.tf  (añadir)

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Password admin de Grafana — se guarda en SSM SecureString."
}
```

```hcl
# infra/envs/prod/terraform.tfvars  (añadir — gitignored)

grafana_admin_password = "Cambia-Esto-También-Por-Algo-Largo-123!"
```

```hcl
# infra/envs/prod/main.tf  (añadir)

module "monitoring" {
  source                 = "../../modules/monitoring"
  project                = var.project
  environment            = var.environment
  region                 = var.region
  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  alb_arn                = module.compute.alb_arn
  ec2_private_ip         = module.compute.ec2_private_ip
  app_security_group_id  = module.compute.app_sg_id
  alert_email            = var.alert_email
  grafana_admin_password = var.grafana_admin_password
}
```

> 📌 `module.compute.alb_arn` ya está declarado en `infra/modules/compute/outputs.tf` (5.5). Añade estos outputs al entorno:
>
> ```hcl
> # infra/envs/prod/outputs.tf  (añadir)
> output "grafana_url" {
>   value = "http://${module.compute.alb_dns_name}:3000"
> }
> output "sns_topic_arn"       { value = module.monitoring.sns_topic_arn }
> output "lambda_function_url" { value = module.monitoring.lambda_function_url }
> ```

### 🧪 Aplica solo el módulo monitoring para validar incrementalmente

```bash
cd infra/envs/prod
terraform apply -target=module.monitoring -auto-approve
```

Tarda ~5–8 min (EFS ~30s, ECS services ~3-5 min cada uno).

Verifica:
```bash
# 1) El cluster ECS existe y los services están RUNNING
aws ecs describe-services \
  --cluster $(terraform output -raw monitoring.ecs_cluster_name 2>/dev/null || echo dkron-obs) \
  --services prometheus grafana \
  --query "services[].{Service:serviceName,Desired:desiredCount,Running:runningCount}" --output table

# 2) Grafana responde en el ALB :3000
curl -sI "$(terraform output -raw grafana_url)/api/health"
# Esperado: HTTP/1.1 200 OK

# 3) Llegó email "Confirm subscription" del topic SNS — confírmalo
echo "Revisa tu bandeja: $(terraform output -raw alert_email 2>/dev/null || echo tu-correo)"
```

> ✅ **Resumen del flujo incremental completo (Partes 5 + 8):**
> 1. `apply -target=module.network`     (~2 min)
> 2. `apply -target=module.ecr`         (~30 s) + `docker push`
> 3. `apply -target=module.compute`     (~2-3 min)
> 4. (PARTE 6) `ansible-playbook site.yml` para poblar la EC2
> 5. `apply -target=module.monitoring`  (~5-8 min)
> 6. (8.4) Confirma email SNS, dispara alerta intencional, captura evidencias
>
> (Antes había un paso `apply -target=module.storage` para RDS — eliminado en PARTE 5.4.)

## ❓ 8.3 ¿Cómo defino mis 2 SLOs en PromQL?

| SLO | SLI (PromQL) | Objetivo | Justificación tuya |
|---|---|---|---|
| **SLO 1 — Disponibilidad del scheduler** | `avg_over_time(up{job="dkron"}[7d])` | ≥ 99% en 7d | Un scheduler caído ≡ jobs no se ejecutan. 99% = 1h40min de downtime al mes, razonable. |
| **SLO 2 — Tasa de éxito** | `sum(rate(dkron_succeeded_jobs_total[24h])) / sum(rate(dkron_succeeded_jobs_total[24h]) + rate(dkron_failed_jobs_total[24h]))` | ≥ 95% en 24h | Tolera fallos transitorios pero detecta degradación. |

Estas queries van directas a un panel de Grafana de tipo **stat** con threshold rojo/verde en el objetivo.

Esto responde al **Concepto B.4 del reporte**.

## ❓ 8.4 ¿Cómo verifico el dashboard y disparo la alerta?

### Dashboard
1. Apunta tu navegador a `http://<alb-dns>:3000` (el listener de Grafana).
2. Login con `admin` y la password del SSM Parameter Store.
3. *Dashboards → Dkron → Dkron — RED* — el dashboard se provisionó solo desde el JSON.
4. Si los paneles dicen "No data": ve a `http://<alb-dns>:3000/connections/datasources` y prueba el datasource Prometheus.

### Verificar reglas de alerta en Prometheus
```bash
# Túnel SSM al task de Prometheus (no expongas 9090 al ALB público):
aws ssm start-session --target ecs:CLUSTER_NAME_TASK_ID \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["19090"]}'

# En otra terminal:
open http://localhost:19090/alerts
```
Deberías ver las 3 reglas: `DkronHighFailureRate`, `DkronNoJobsRunning`, `DkronTargetDown` en estado `OK` (verde).

## ❓ 8.5 ¿Cómo confirmo el email de SNS?
Cuando aplicas, AWS te manda un email con un link "Confirm subscription". **Haz clic** o nunca recibirás alertas.

## ❓ 8.6 ¿Cómo provoco la alerta intencional?
La sección 5.4 del PDF lo exige. Crea un job que falle:
```bash
ALB=$(terraform output -raw alb_dns_name)

curl -X POST http://$ALB/v1/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "name": "fallar-a-proposito",
    "schedule": "@every 30s",
    "executor": "shell",
    "executor_config": { "command": "exit 1" }
  }'
```

Espera ~7-10 minutos (Prometheus evalúa la regla cada 30s, `for: 2m` la confirma, Alertmanager agrupa 30s antes de disparar). El flujo será:
1. En Prometheus (`/alerts`) verás `DkronHighFailureRate` pasar a **PENDING** y luego a **FIRING**.
2. En Grafana, el panel de "failures/min" se va al cielo.
3. Alertmanager dispara el webhook → Lambda → SNS → **email a tu bandeja**: asunto `[FIRING] DkronHighFailureRate`.

**Captura el email y la pantalla de Prometheus en FIRING** — van en `docs/evidencias.md`.

Después borra el job:
```bash
curl -X DELETE http://$ALB/v1/jobs/fallar-a-proposito
```

Espera ~2 min más y llegará un segundo email `[RESOLVED]` (porque `send_resolved: true`).

## 💥 Errores típicos en la PARTE 7 (Prometheus + Grafana)

### Error 7.A: Prometheus se reinicia y pierde todos los datos
**Causa:** olvidaste el volumen EFS o `--storage.tsdb.path` apunta a `/tmp`.
**Diagnóstico:** `aws logs tail /ecs/dkron-obs --filter-pattern "prometheus" --since 10m`
**Solución:** verifica el `mountPoints` del container `prometheus` y que el `aws_efs_access_point.prometheus` apunte a `/prometheus` con uid 65534. Las TSDB de Prometheus se corrompen si las escribe otro usuario.

### Error 7.B: Prometheus muestra el target Dkron como `DOWN`
**Causa más común en arquitectura híbrida EC2+Fargate**: el `file_sd_configs` apunta a un IP que ya no existe (la EC2 fue reemplazada por `terraform taint`).
**Diagnóstico:** desde un task del cluster:
```bash
aws ecs execute-command --cluster dkron-obs --task <task-id> --container prometheus \
  --interactive --command "cat /etc/prometheus/targets/dkron.json"
# Debe mostrar la IP privada actual de la EC2.
```
**Solución 1 (IP cambió):** `terraform apply -target=module.monitoring` para regenerar los SSM target files con la IP nueva, luego:
```bash
aws ecs update-service --cluster dkron-obs --service prometheus --force-new-deployment
```
El config-init container relee SSM al arrancar.
**Solución 2 (SG restrictivo):** verifica que `aws_security_group_rule.app_from_prom_8080` (módulo `monitoring/sg.tf`) exista; sin esa regla, el SG-app rechaza el scrape.

### Error 7.C: Grafana arranca pero el dashboard no aparece
**Causa:** `GF_PATHS_PROVISIONING` no está en `/etc/grafana/provisioning` o no montaste el archivo de provisioning ahí.
**Solución:** la imagen oficial busca `provisioning/dashboards/*.yml` en `/etc/grafana/provisioning`. Monta tu config ahí o usa la API:
```bash
curl -u admin:$PASSWORD -X POST http://<alb>:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @infra/modules/monitoring/dashboards/dkron-red.json
```

### Error 7.D: La alerta dispara en Prometheus pero el email no llega
**Causa:** ruptura del puente Alertmanager → webhook → Lambda → SNS. Diagnostícalo paso a paso:
1. `http://<prom>:9090/alerts` → ¿está en FIRING? Si no, revisa la regla.
2. `http://<prom>:9093` (Alertmanager UI) → ¿llegó la alerta? Si no, revisa `prometheus.yml` sección `alerting`.
3. CloudWatch Logs de la Lambda `dkron-alertmgr-to-sns` → ¿se invocó? ¿qué respondió?
4. SNS console → ¿la suscripción está `Confirmed`?

### Error 7.E: El email de confirmación de SNS no llega
**Causa:** filtro spam. **Solución:** revisa spam, o agrega `noreply@sns.amazonaws.com` a contactos antes.

### Error 7.F: Demasiadas alertas (alert fatigue)
**Causa:** umbrales muy agresivos. **Solución:** ajusta `for:` y los umbrales en `rules.yml` con datos reales. Ej: sube `DkronHighFailureRate` de `> 5` a `> 20` si tienes muchos jobs legítimamente fallidos.

### Error 7.G: EFS mount falla — task se queda en `PROVISIONING`
**Síntoma:** evento de ECS: `failed to invoke EFS utils commands to set up EFS volumes`.
**Causa:** SG de EFS no permite ingress 2049 desde los SG de Prometheus/Grafana.
**Solución:** verifica `aws_security_group.efs` — debe tener un `ingress` con `security_groups = [aws_security_group.prometheus.id, aws_security_group.grafana.id]`.

### Error 7.H: Grafana cuesta más de lo esperado
**Causa:** lo dejaste corriendo el fin de semana.
**Solución:** baja `desired_count` a 0 cuando no trabajas, sube a 1 cuando retomas. Los datos persisten en EFS.

## ❓ 8.7 ¿Cómo demuestro que mis logs son "centralizados y buscables"?
La sección 5.4 del PDF lo exige: "Logs centralizados y buscables. Es posible buscar un identificador (por ejemplo `request_id`, `job_id` o equivalente) y correlacionarlo con un evento en las métricas del mismo timeframe."

Aunque las **métricas** viven en Prometheus, **los logs siguen yendo a CloudWatch Logs**. Aquí los caminos son distintos según el cómputo:
- **Prometheus + Grafana (ECS Fargate):** driver `awslogs` en la task definition → log group `/dkron/obs`.
- **Dkron + node_exporter (EC2 + Compose):** el `docker-compose.yml.j2` que renderiza Ansible incluye `logging.driver: awslogs` en cada service. Los containers escriben directo a CloudWatch Logs vía la API (necesita el `CloudWatchAgentServerPolicy` que ya pusiste en el instance profile). Log groups: `/dkron/ec2/dkron` y `/dkron/ec2/compose`.

Resultado: los **cuatro flujos de log** (Dkron, node_exporter, Prometheus, Grafana) terminan en CloudWatch Logs, así que un solo Insights query los recorre todos.

**Cómo se ve eso en CloudWatch Logs Insights:**
1. Console AWS → CloudWatch → **Logs Insights**.
2. Selecciona los log groups `/dkron/ec2/dkron`, `/dkron/ec2/compose` y `/dkron/obs` (puedes elegir varios a la vez).
3. Pega esta query:
   ```
   fields @timestamp, @logStream, @message
   | filter @message like /job_id/
   | parse @message /job_id=(?<job_id>\S+)/
   | filter job_id = "saludo"
   | sort @timestamp desc
   | limit 50
   ```
4. Run query. Verás todas las ejecuciones del job `saludo` con su timestamp.

**Captura esa pantalla** y agrégala a `docs/evidencias.md` — es prueba directa del requisito de "logs buscables".

**Para correlacionar logs ↔ métricas:**
1. Anota el timestamp del email de Alertmanager (`[FIRING]`).
2. En Logs Insights, filtra por ese timeframe ± 2 min.
3. En Grafana, abre el dashboard *Dkron — RED* y arrastra para seleccionar exactamente ese rango.
4. Ambas vistas muestran el mismo evento — eso es **correlación**.

> 💡 **Bonus para el reporte:** Grafana también puede mostrar logs vía el datasource **CloudWatch Logs** — añádelo en *Connections → Data sources → AWS CloudWatch* (necesita un IAM role attach al task de Grafana). Así tienes métricas y logs lado a lado en un solo panel.

## ❓ 8.8 ¿Y las migraciones de schema de Dkron al actualizar versión?
La sección 3 paso 2 del PDF lo menciona: "esquema de migraciones de base de datos cuando aplica". Para Dkron con **BoltDB embebido**:
- En el primer arranque, Dkron inicializa el archivo BoltDB en `/dkron.data` con su estructura interna (no hay tablas SQL — BoltDB es key-value).
- Al **actualizar Dkron** (de `v4.0.9` a una versión futura), si la nueva versión cambia el formato del store, Dkron aplica la migración automáticamente al arrancar leyendo el archivo BoltDB existente.
- **Riesgo:** si la migración tarda y el ALB tiene `healthy_threshold` corto, el target queda unhealthy.
- **Mitigación específica para EC2 + Compose:** el playbook `deploy.yml` hace `docker_compose_v2 ... pull: missing` y luego `wait_for: port=8080 timeout=90` antes del smoke test. Si la migración requiere más de 90s, ajusta el `timeout` del playbook **antes** de un upgrade mayor. Documenta esto en el runbook.
- **Recomendación adicional para upgrades mayores:** toma un snapshot del volumen EBS (ver runbook R1) **antes** del upgrade. Si la migración falla, puedes restaurar el snapshot y volver a la versión anterior con `dkron_image_tag` previo.

**Qué documentar en el reporte:** "Las migraciones del store BoltDB las gestiona Dkron en runtime al arrancar. No hay un proceso separado de migrate; el riesgo se mitiga con un wait_for en el playbook de Ansible, health-check tolerante en el ALB durante upgrades y snapshot manual del EBS antes de un upgrade mayor."

---

<a id="parte-9"></a>
# PARTE 9 — Responder las 5 preguntas de decisión técnica del Caso D

> Aquí cerramos las preguntas obligatorias de la página 11 del PDF. Responderás en el reporte con TUS palabras, pero te doy el marco.

## 🗺️ Diagrama: árbol de decisiones del Caso D

```
                    ┌──────────────────────────┐
                    │  Decisión 1:             │
                    │  ¿1 nodo o cluster?      │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
        ¿alcance del                          ¿necesitas HA
         proyecto pide                         multi-AZ?
         multi-AZ?                                  │
              │                                     │
            NO ───▶ 1 nodo (EC2 + Compose)        SÍ ─▶ Cluster (3 nodos)
                                                  NO ─▶ 1 nodo

                    ┌──────────────────────────┐
                    │  Decisión 2:             │
                    │  ¿BoltDB o PostgreSQL?   │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
       ¿Dkron OSS soporta                     ¿estás usando
        el flag --store=postgres?              Dkron Pro?
              │                                     │
       NO (solo Pro lo soporta)              SÍ → Postgres válido
              │                                     │
              └─────────────┬───────────────────────┘
                            ▼
                   BoltDB embebido sobre EBS gp3 encriptado
                   (mitigación durabilidad: snapshots EBS via DLM)
                   Postgres NO es opción real en Dkron OSS v4.

                    ┌──────────────────────────┐
                    │  Decisión 3:             │
                    │  ¿Cómo mido el drift?    │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
       ¿Dkron expone                          ¿hay otra forma?
        métrica nativa                              │
        de drift?                              Custom metric
              │                                vía Lambda que
        Generalmente NO                        consulta API
              │                                     │
              └─────────────┬───────────────────────┘
                            ▼
                   Custom Metric `dkron_drift_seconds`
                   publicada por Lambda → Pushgateway
                   (scrapeada por Prometheus)

                    ┌──────────────────────────┐
                    │  Decisión 4:             │
                    │  ¿Cómo evito duplicados? │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
        Capa Dkron:                            Capa script:
        concurrency: forbid                    idempotente
        en el job                              (lock en DB / S3)
              │                                     │
              └─────────────┬───────────────────────┘
                            ▼
                       AMBAS combinadas

                    ┌──────────────────────────┐
                    │  Decisión 5:             │
                    │  ¿Política de timeout?   │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
        Default                              Por tipo de job
        conservador                          (rápidos / medios / largos)
        10 minutos                           con justificación
              │                                     │
              └─────────────┬───────────────────────┘
                            ▼
                  Al exceder: SIGTERM → SIGKILL
                  + métrica failed{reason="timeout"}
                  + alerta si crítico
```

**Cómo se usa este árbol:** para cada decisión del PDF, sigue las flechas con las condiciones del proyecto. La hoja al final es la respuesta defendible. **Pero la justificación numérica y de palabras debe ser TUYA en el reporte.**



## ❓ 9.1 ¿Un único nodo Dkron o un cluster?
**Marco:**
- **Cluster (3+ nodos):** tolerancia a fallos vía Serf gossip. Si uno cae, los otros siguen.
- **Nodo único:** simple, barato. Si la EC2 reinicia, ventana de minutos sin scheduler.
- **Para el alcance** (sección 4: 1 región, 1 AZ): nodo único es defensible. Una EC2 + Auto Recovery (CloudWatch alarm + recovery action) cubre la mayoría de casos.

**Respuesta tipo:** "Elegí un único nodo Dkron sobre EC2. El alcance descarta multi-AZ y la operación cluster exige Serf entre nodos, lo que añade complejidad operativa sin ganancia real en una sola AZ. La recuperación tras fallo se delega a EC2 Auto Recovery (alarma `StatusCheckFailed_System`) que reinicia la instancia en hardware sano en ~3 min. Documento el RTO esperado."

## ❓ 9.1bis ¿Server y agent en el mismo proceso o separados? (decisión sugerida por la topología del PDF)

> 🧭 **Por qué esta pregunta vive aquí:** la imagen de la página 11 del PDF dibuja explícitamente `Server (scheduler)` y `Agent (executor)` como dos bloques distintos dentro del recuadro "Dkron", con la nota literal *"opcional · puede ser el mismo nodo"*. El PDF deja la decisión al proyecto, así que la tomamos con argumentos.

**Marco:**
- **Mismo proceso (un solo container `dkron --server`):** el binario de Dkron actúa simultáneamente como scheduler y como ejecutor. Es lo más simple operativamente y lo que la documentación oficial muestra primero.
- **Separados (container `dkron-server` + container `dkron-agent`):** el server solo agenda y mantiene estado en BoltDB local; los agents reciben dispatch por Serf y corren los runs. Permite escalar el ejecutor horizontalmente sin tocar el scheduler y aislar fallos del ejecutor (un agent que cuelga no afecta al scheduler).

**Trade-offs del Caso D:**

| Aspecto                  | Mismo proceso              | Separados                                     |
|--------------------------|----------------------------|-----------------------------------------------|
| Complejidad operativa    | Baja                       | Media — dos services en el compose, Serf cluster |
| Aislamiento de fallos    | Si el run se cuelga, puede afectar al scheduler | Aislamiento real                         |
| Escalado del ejecutor    | No escalable               | Sumar agents sin tocar el server              |
| Costo (alcance 1 nodo)   | Igual (1 EC2)              | Igual (1 EC2) — ambos containers en la misma EC2 |
| Fit con el alcance       | Excelente                  | Sobre-engineering para 1 AZ y 1 nodo          |

**Respuesta tipo:** "El binario de Dkron expone los roles `server` y `agent`. Para el alcance (1 EC2, 1 AZ), corro **un solo container** que actúa como ambos (`dkron --server`), tal como la documentación oficial recomienda para single-node. La topología del PDF marca el agent como opcional precisamente para este caso. Si en una iteración futura necesitara aislar el ejecutor (jobs largos que arriesgan al scheduler) o escalar agents detrás del mismo server, partiría el compose en dos services apuntando al mismo BoltDB compartido (o, si la complejidad lo justifica, migrando a Dkron Pro con backend Postgres) y descubriéndose por Serf — pero esa complejidad hoy no se justifica."

> **Si decides separarlos**, ajusta el `docker-compose.yml` de la PARTE 3 con dos services (`dkron-server` con flag `--server` y `dkron-agent` apuntando al server por Serf en puerto 8946) y documenta el cambio en el reporte. El resto de la infraestructura no cambia.

## ❓ 9.2 ¿BoltDB local o PostgreSQL?

**Marco (con dato duro descubierto en producción):**
- El PDF deja la elección al proyecto: "BoltDB local **o** PostgreSQL".
- **Pero Dkron OSS v4 no soporta backend Postgres.** Los flags `--store=postgres`, `--backend=postgres` y `--dsn=...` solo existen en **Dkron Pro** (la versión comercial). Si pasas `--store=postgres` al binario OSS, el container imprime el listado completo de `dkron agent --help` y sale con código 1. Verificación directa: `docker run --rm dkron/dkron:v4.0.9 agent --help | grep -iE 'store|backend|dsn|postgres'` devuelve **vacío**.
- Esto reduce la decisión real a **BoltDB sí o sí**, con la pregunta secundaria de **cómo mitigar la durabilidad**.

**Opciones de durabilidad con BoltDB:**
- **BoltDB sobre el filesystem del container (sin volumen):** se pierde con `docker compose down -v`, con un `restart` del container si la imagen cambia el path, y obviamente al destruir la EC2.
- **BoltDB sobre un bind mount al host (`/var/lib/dkron-data`) sobre el volumen root EBS de la EC2 (gp3, encriptado):** sobrevive `docker compose down/up`, sobrevive reinicios de la EC2. Lo pierdes si destruyes la EC2 sin haber tomado un snapshot del EBS. ← **es lo que hacemos**.
- **BoltDB sobre EBS dedicado adicional, con DLM (Data Lifecycle Manager) snapshots diarios:** sobrevive incluso a la destrucción de la EC2 (puedes adjuntar el snapshot al volumen de una EC2 nueva). Costo extra: ~$0.05/mes por snapshot + el EBS extra. **Mitigación recomendable para producción real.**

**Trade-offs frente a la opción Postgres (la que NO podemos tomar en OSS):**

| Aspecto | BoltDB en EBS (lo que hacemos) | PostgreSQL en RDS (Dkron Pro) |
|---|---|---|
| Soporte en Dkron OSS | ✅ default | ❌ feature de Pro |
| Costo | $0 (EBS root ya pagado) | ~$15/mes (db.t3.micro) |
| Sobrevive destruir EC2 | Solo con snapshot del EBS | Sí (RDS es independiente) |
| Backups automáticos | Manual o DLM opcional | Snapshots automáticos RDS |
| Complejidad infra | Mínima | Módulo storage + SG-db + SSM SecureString del DSN |

**Respuesta tipo:** "BoltDB embebido sobre un volumen EBS gp3 encriptado de la propia EC2 (`/var/lib/dkron-data` → `/dkron.data` en el container). La pregunta del PDF plantea BoltDB o PostgreSQL, pero al validar la matriz de features de **Dkron OSS v4** confirmé que el flag `--store=postgres` solo existe en **Dkron Pro**. Mi proyecto usa el binario OSS, así que la elección real era cómo mitigar la durabilidad de BoltDB. La estrategia fue: (1) montar el data-dir sobre el EBS root de la EC2, que es gp3 + encriptado, para que sobreviva reinicios y `docker compose down/up`; (2) dejar el `terraform destroy` con `delete_on_termination = true` porque el alcance es de proyecto y la recreación limpia es deseable; (3) documentar en el runbook (R1) cómo activar DLM con snapshots diarios si pasara a producción real. El precio operativo: un `terraform taint aws_instance.dkron` borra el histórico — riesgo aceptable contra el ahorro de RDS y un módulo Terraform completo. **Antes de tomar esta decisión gasté un sprint diseñando el módulo `storage/` con RDS y SSM SecureString del DSN; descubrí la incompatibilidad debugeando el container en `Restarting (1)` infinito (PARTE 11.2) — esto es lo que documento en el reporte como evidencia del concepto B.7 'trade-offs del componente de estado': validar matriz OSS vs Pro **antes** de aprovisionar.""

## ❓ 9.3 ¿Cómo se mide el drift? ¿Qué métrica registra ese delta?
**Marco:** Dkron registra `started_at` y `scheduled_at` por execution. Drift = diferencia entre ambos.

Métricas nativas de Dkron no exponen el drift directo. Soluciones:
1. **Custom metric `dkron_drift_seconds`** publicada por una Lambda agendada que consulta la API.
2. **Métrica de aplicación calculada**: `dkron_jobs_completed_with_drift_p95`.

**Respuesta tipo:** "Defino una Custom Metric `dkron_drift_seconds`. Una Lambda corre cada 60s, consulta `/v1/jobs/<job>/executions?since=now-1m`, calcula `started_at - scheduled_at` por execution y publica el p95 a CloudWatch. La alerta dispara si p95 > 30s sostenido por 10 min."

## ❓ 9.4 ¿Cómo se previene la ejecución duplicada si Dkron reinicia?
**Marco:** dos riesgos:
- Job estaba corriendo cuando el container reinicia (Ansible deploy nuevo, EC2 reboot) → al volver, Dkron reagenda y el job corre 2 veces.
- Mitigaciones:
  1. **`concurrency: forbid`** en la definición del job: Dkron no permite dos ejecuciones simultáneas del mismo job.
  2. **Idempotencia en el script ejecutado**: el script comprueba si ya corrió (lock en DB, archivo en S3 con la fecha).
  3. **Persistir executions en BoltDB sobre EBS**: al reiniciar el container o la EC2, el archivo BoltDB queda y Dkron ve el histórico al volver.

**Respuesta tipo:** "Combiné dos capas: (1) `concurrency: forbid` en cada job; (2) idempotencia obligatoria en el script ejecutado con un lock externo (ej. condición `aws s3api put-object --if-none-match` sobre un marker en S3 o un `INSERT ... ON CONFLICT` si el script ataca una BD propia). La persistencia en BoltDB sobre EBS asegura que el histórico sobreviva al reinicio del container o de la EC2. Específico de mi setup con Ansible: el `deploy.yml` hace `up -d` con `restart: unless-stopped` y wait_for, así que Dkron pierde como máximo una ventana de 30-60s en deploy."

## ❓ 9.5 ¿Qué política de timeout y qué pasa si la excede?
**Marco:** Dkron tiene `timeout: "10m"` en cada job. Al excederlo:
- Envía SIGTERM al proceso, espera unos segundos, luego SIGKILL.
- Marca la execution como `failed`.
- Incrementa `dkron_failed_jobs_total{reason="timeout"}`.

**Respuesta tipo:** "Defino timeout por tipo de job: rápidos (<30s), medios (10m default), largos (1h con justificación documentada). Al exceder: SIGTERM y, si no responde en 30s, SIGKILL. El script debe ser idempotente para absorber la limpieza del estado parcial."

## ❓ 9.6 ¿Persistir los outputs en S3 o no? (decisión sugerida por la topología del PDF)

> 🧭 **Por qué esta pregunta vive aquí:** la imagen del PDF (página 11) muestra **S3 outputs de jobs** dentro del bloque "Almacenamiento (opcional)" — la palabra "opcional" es literal, igual que en la sección "Componentes mínimos a desplegar" del Escenario D (PDF página 10: *"(Opcional) Storage S3 para los outputs"*). Tomar o no tomar S3 es decisión del proyecto y entra en el reporte.

**Marco:**
- **Sin S3:** stdout/stderr de cada job queda en el archivo BoltDB local (Dkron trunca a unos cuantos KB por defecto) y, vía el driver `awslogs` del container, en **CloudWatch Logs**. Suficiente para jobs cortos y outputs pequeños.
- **Con S3:** un job que ejecuta un script puede subir su output completo al bucket `dkron-outputs/<job>/<execution_id>.log`. Útil para jobs largos, reportes, dumps de base de datos.

**Trade-offs:**

| Aspecto              | Sin S3 (default)               | Con S3 (`dkron-outputs`)                 |
|----------------------|--------------------------------|-------------------------------------------|
| Costo               | $0                              | ~$0.023/GB-mes + requests (centavos)      |
| Setup               | Nada extra                      | Bucket + IAM policy + lógica en el script |
| Tamaño de output    | Limitado por BoltDB y CloudWatch | Sin límite práctico                      |
| Búsqueda           | Logs Insights sobre CloudWatch  | Aparte: `aws s3 cp` o `aws s3 select`     |
| Retención          | Configurable en CloudWatch (mín 1 día) | S3 lifecycle (Glacier después de N días) |

**Respuesta tipo (si decides NO usar S3):** "El alcance del proyecto no maneja jobs que generen outputs grandes — los runs son `curl` a un health endpoint y un dump corto de logs. CloudWatch Logs con retención de 7 días es suficiente y elimina un componente del diagrama. Si en el futuro hubiera jobs que produjeran archivos (backups, exports), añadiría el bucket `dkron-outputs` con un lifecycle a Glacier en 30 días."

**Respuesta tipo (si decides SÍ usar S3):** "Activé el bucket `dkron-outputs` con versionado, encriptación SSE-S3 y bloqueo de acceso público. El IAM Task Role del agent tiene `s3:PutObject` solo sobre `arn:aws:s3:::dkron-outputs/*`. Cada script ejecutado por Dkron termina con `aws s3 cp $LOG s3://dkron-outputs/$JOB/$EXEC.log`. Lifecycle: transition a Glacier IR a los 30 días, expiración a los 90. Decisión documentada como protección frente a outputs grandes que saturarían CloudWatch Logs."

---

<a id="parte-10"></a>
# PARTE 10 — Runbook, README y REPORTE

## ❓ 10.1 ¿Qué pongo en `docs/runbook.md`?

```markdown
# Runbook — Dkron Prod

## R1: Backup / restore del volumen EBS con BoltDB (persistencia de Dkron)

> 🧠 **Contexto:** Dkron OSS persiste en BoltDB local sobre `/var/lib/dkron-data` en la EC2 (volumen root EBS gp3 encriptado). No hay RDS. La recuperación se hace con snapshots de EBS.

### Snapshot manual (rápido, antes de un cambio riesgoso)

```bash
EC2_ID=$(cd infra/envs/prod && terraform output -raw ec2_instance_id)
VOL_ID=$(aws ec2 describe-instances --instance-ids "$EC2_ID" \
  --query "Reservations[].Instances[].BlockDeviceMappings[?DeviceName=='/dev/xvda'].Ebs.VolumeId" \
  --output text)
aws ec2 create-snapshot --volume-id "$VOL_ID" --description "Manual snapshot - dkron-prod $(date -Iseconds)"
```

### Snapshots automáticos via DLM (recomendado para prod real)

Crea una `aws_dlm_lifecycle_policy` que tome un snapshot diario del volumen tag `Role=dkron-server` con retención 7 días. Costo: ~$0.05/mes/snapshot.

### Restore desde un snapshot

1. Localiza el snapshot:
   ```
   aws ec2 describe-snapshots --owner-ids self \
     --filters "Name=tag:Role,Values=dkron-server" \
     --query "Snapshots[*].[SnapshotId,StartTime,Description]" --output table
   ```
2. Crea un volumen nuevo desde el snapshot, en la misma AZ que la EC2:
   ```
   aws ec2 create-volume --snapshot-id <snap-id> \
     --availability-zone us-east-1a --volume-type gp3 --encrypted
   ```
3. **Opción A — restore in-place** (si la EC2 sigue viva):
   - `docker compose down` (detiene Dkron, libera el bind mount).
   - Reemplaza el contenido de `/var/lib/dkron-data` con el contenido del volumen restaurado (mountalo temporalmente, `rsync -a /mnt/restore/ /var/lib/dkron-data/`).
   - `docker compose up -d` → Dkron arranca con el BoltDB restaurado.
4. **Opción B — restore en EC2 nueva** (si destruiste la EC2): después de `terraform apply` que recrea la EC2, monta el volumen restaurado en `/var/lib/dkron-data` antes de correr `ansible-playbook site.yml`.

### Verificación
- `curl http://$ALB/v1/jobs` debe responder con 200 y devolver la lista de jobs previos.

---

## R2: Rollback de un deploy fallido

> Modelo de rollback: nuestro deploy es **una imagen + un compose template + un .env**. La imagen va por `dkron_image_tag`. El rollback consiste en re-ejecutar el playbook fijando el tag anterior.

### Pasos
1. Identifica el tag de la imagen anterior — por commit SHA o por tag semver:
   ```
   aws ecr list-images --repository-name dkron-dkron --query 'imageIds[].imageTag'
   ```
2. Re-ejecuta el playbook fijando ese tag:
   ```
   cd ansible
   ansible-playbook playbooks/deploy.yml \
     --extra-vars "dkron_image_tag=<tag-anterior>"
   ```
3. Espera al smoke test del playbook (`wait_for: port=8080`) y luego al ALB target healthy.
4. Si el rollback no resuelve, escala a R3 (recreación de la EC2).

### Prevención
- Los tags inmutables en ECR (`tag_mutability = "IMMUTABLE"`) garantizan que cada `v4.0.9` apunta a una imagen fija. Configúralo en `aws_ecr_repository`.

---

## R3: Recreación completa de la EC2 (host comprometido o config corrupta)

### Síntoma
- La EC2 responde pero el container de Dkron no levanta tras varios deploys.
- Logs del CW agent o de Docker apuntan a un disco lleno, kernel panic intermitente, o servicios sistémicos rotos por una intervención manual.

### Pasos
1. Marca la EC2 para recreación en Terraform:
   ```
   cd infra/envs/prod
   terraform taint module.compute.aws_instance.dkron
   ```
2. Apply: Terraform destruye y recrea la EC2 con una IP nueva.
   ```
   terraform apply -auto-approve
   ```
3. Como la IP cambia, el módulo `monitoring/` regenera los SSM target files; force-redeploy el task de Prometheus para que el config-init re-sincronice:
   ```
   aws ecs update-service --cluster dkron-obs --service prometheus --force-new-deployment
   ```
4. Re-ejecuta Ansible site.yml (bootstrap completo en EC2 nueva):
   ```
   cd ansible
   ansible-playbook playbooks/site.yml
   ```
5. Verifica:
   ```
   curl http://$(cd ../infra/envs/prod && terraform output -raw alb_dns_name)/v1/jobs   # debe ser 200
   ```

### Tiempo esperado
- Terraform recreate EC2: ~2 min.
- Ansible site.yml: ~3-5 min.
- ALB pasa a healthy: 30-60s tras el smoke test.
- **RTO total: ~7-10 minutos**.

### Notas sobre persistencia (importante)
- ⚠️ **Los jobs definidos y el historial de executions viven en BoltDB sobre el EBS root de la EC2.** Si `terraform taint` destruye la EC2, el EBS se destruye con ella (`delete_on_termination = true`) → **pierdes el histórico**.
- Mitigación: **antes** de hacer `terraform taint`, toma un snapshot manual del volumen (ver R1) o ten DLM activo. Después de `terraform apply` y antes de `ansible-playbook site.yml`, monta el snapshot restaurado en `/var/lib/dkron-data` (ver R1 opción B).
- Los logs de container previos viven en CloudWatch Logs por el driver `awslogs`, así que esa historia no se pierde aunque destruyas la EC2.
```

## ❓ 10.2 ¿Qué va en el README.md?

```markdown
# Dkron en AWS — Caso D

Despliegue del scheduler distribuido [Dkron](https://dkron.io) (versión `v4.0.9`)
en AWS sobre **EC2 + Docker Compose** gestionado por **Ansible**, con persistencia
local en **BoltDB sobre EBS** (Dkron OSS no soporta Postgres — ver REPORTE.md y
GUIA.md PARTE 5.4), ALB público, observabilidad híbrida (Prometheus + Grafana en
ECS Fargate) y CI/CD con GitHub Actions (Terraform apply + ansible-playbook deploy).

## Arquitectura
![diagrama](docs/arquitectura.png)

## Levantar local
```bash
cd compose
cp .env.example .env
docker compose up -d
open http://localhost:8080/dashboard   # Dkron
open http://localhost:9090             # Prometheus
open http://localhost:3000             # Grafana (admin/admin)
```

## Desplegar a AWS (paso a paso)
1. Crear bucket del tfstate (una vez):
   ```
   chmod +x infra/bootstrap.sh
   ./infra/bootstrap.sh
   ```
   Si es tu primer deploy, también crea el OIDC + rol GHA (una vez):
   ```
   chmod +x infra/bootstrap-oidc.sh
   ./infra/bootstrap-oidc.sh
   ```
2. Aplicar la infraestructura:
   ```
   cd infra/envs/prod
   cp terraform.tfvars.example terraform.tfvars
   # Edita terraform.tfvars con tus valores reales
   terraform init
   terraform apply
   ```
3. Replicar la imagen oficial a ECR (la primera vez):
   ```
   ECR=$(terraform output -raw ecr_repository_url)
   aws ecr get-login-password | docker login --username AWS --password-stdin $ECR
   docker pull dkron/dkron:v4.0.9
   docker tag  dkron/dkron:v4.0.9 $ECR:v4.0.9
   docker push $ECR:v4.0.9
   ```
4. Configurar la EC2 con Ansible (bootstrap):
   ```
   cd ../ansible
   ansible-galaxy collection install -r requirements.yml
   ansible-playbook playbooks/site.yml
   ```
5. Verificar:
   ```
   curl http://$(cd ../infra/envs/prod && terraform output -raw alb_dns_name)/v1/jobs
   ```

## Variables requeridas
- `TF_VAR_ssh_public_key` — pública SSH (key pair AWS).
- `TF_VAR_alert_email` — email para recibir las alertas SNS.
- `TF_VAR_grafana_admin_password` — password admin de Grafana.
- Secrets en GitHub: `AWS_ROLE_ARN`, `ECR_REPO`, `SSH_PUBLIC_KEY`, `GRAFANA_ADMIN_PASSWORD`, `ALERT_EMAIL`, `TF_OWNER`.

## Evidencias
Ver `docs/evidencias.md`.

## Versiones pinneadas
- Dkron: `v4.0.9` (OSS — persistencia BoltDB embebida, sin Postgres)
- node_exporter: `v1.8.2`
- Prometheus: `v2.54.1`
- Alertmanager: `v0.27.0`
- Grafana: `11.2.0`
- Terraform: `1.7.5`
- Provider AWS: `~> 5.0`
- ansible-core: `2.17.x`
- community.docker: `>=3.10`
- amazon.aws: `>=8.0`
```

## ❓ 10.3 ¿Qué evidencias capturar?

> 📝 **El PDF (sección 6.4) lista exactamente 4 capturas obligatorias.** Cada una con timestamp visible y "contexto suficiente para reconocer el recurso (URL, nombre del workflow, identificador de la task, nombre del dashboard)". Esta es la lista canónica:

En `docs/evidencias.md` (o sección "Evidencias" del README.md):

1. **Listado de ejecuciones recientes del workflow en la pestaña Actions de GitHub** — debe mostrar un pull request validado, merge a `main`, y un deploy automatizado posterior. URL del repo visible. *(PDF 6.4 punto 1)*
2. **La aplicación atendiendo un caso de uso del escenario** — para Caso D, eso es: respuesta de `GET /v1/jobs` desde curl al ALB, o screenshot del dashboard web de Dkron en `http://<alb>/dashboard` mostrando un job programado. *(PDF 6.4 punto 2)*
3. **El dashboard de observabilidad con los SLOs definidos y su estado saludable** — Grafana en su panel RED + paneles de los 2 SLOs (Disponibilidad ≥99% y Tasa de éxito ≥95%) en verde. Nombre del dashboard visible. *(PDF 6.4 punto 3)*
4. **La alerta disparada de forma intencional, junto con descripción breve de cómo se generó la violación del SLO** — regla en `FIRING` en Prometheus + email de SNS recibido (asunto `[FIRING] DkronHighFailureRate`) + texto que explique qué hiciste para provocarla (ver 8.6). *(PDF 6.4 punto 4)*

> 💡 **Captura sugerida adicional (no exigida pero útil para sección C del reporte):** pantalla de Prometheus `/targets` con `job=dkron` en `UP` desde la EC2. Demuestra que el bridge cross-compute (Fargate scrape EC2 vía file_sd) funciona. La incluyes como evidencia complementaria, no la cuentes como una de las 4 obligatorias.

## ❓ 10.4 ¿Cómo escribo el REPORTE.md?

> 🚨 **REGLA: SIN IA**. La IA puede ayudarte SOLO con ortografía/gramática (sección 10 FAQ del PDF).

Estructura (2.000–5.000 palabras), 5 secciones (sección 6.2 del PDF):

### A — El problema y la arquitectura (~1 página)
- Justifica Dkron, AWS, y la **Opción B (EC2 + Compose + Ansible)** del PDF para el cómputo de Dkron.
- Justifica la **arquitectura híbrida**: por qué Dkron va en EC2 pero Prometheus/Grafana van en Fargate.
- Por cada uno de los **5 bloques que pide el PDF §6.2 A** — **cómputo**, **base de datos**, **cache o cola**, **observabilidad**, **CI/CD** — escribe: qué elegiste, por qué, qué alternativas consideraste, bajo qué condiciones revisarías la decisión.
  - 💡 Para el bloque **cache/cola** en Caso D: el PDF lo lista como bloque obligatorio del reporte, pero Dkron no necesita un componente asíncrono separado. Aun así escríbelo (no lo omitas): *"No aplica al escenario — Dkron no requiere cache distribuido ni cola de eventos; la cola interna de jobs y el histórico viven en BoltDB embebido sobre el volumen EBS de la propia EC2 (Dkron OSS no soporta backend Postgres — ver PARTE 9.2). Revisaría la decisión si el throughput de jobs supera los 1.000/min sostenidos (cuando BoltDB empezaría a dominar la latencia y tendría sentido migrar a Dkron Pro con Postgres) o si introdujera fan-out a workers paralelos."*

### B — Conceptos clave (~2-3 páginas, ~½ página por concepto — los **7 obligatorios** del PDF sección 6.2 B)
1. **IaC vs gestión de configuración** — Terraform vs Ansible. **Aquí tienes ejemplo concreto:** Terraform crea EC2/IAM/SG/ALB/ECR; Ansible instala Docker, copia el compose, hace `docker pull` + restart. La frontera la cruzas en `output ec2_private_ip` (Terraform) → `aws_ec2.yml` (Ansible).
2. **Containerización vs EC2 + Ansible** — Tu proyecto vivió las DOS cosas. Containers en local (Parte 3) y en producción (la imagen `dkron:v4.0.9` es bit-a-bit la misma). Pero la EC2 sigue necesitando Docker instalado, kernel actualizado, daemon configurado — eso lo hace Ansible. Justifica con datos del proyecto.
3. **CI / CD-delivery / CD-deployment** — Implementaste delivery (con aprobación manual antes de `terraform apply` y de `ansible-playbook deploy.yml`). Justifica el nivel elegido.
4. **SLI / SLO / error budget** — Tus 2 SLOs (disponibilidad ≥99% y tasa de éxito ≥95%), justificación numérica de cada umbral.
5. **Mínimo privilegio en IAM** — instance profile de EC2 (los managed `SSMManagedInstanceCore`/`CloudWatchAgentServerPolicy` + dos inline acotadas a SSM por ARN), role del runner GHA via OIDC, role de las tasks de Prom/Grafana. Qué permiso tuviste que ampliar y por qué (probablemente s3:* sobre el bucket `ansible-ssm`).
6. **State remoto y locking en Terraform** — Qué pasa con un `apply` concurrente sin lock (ya lo respondiste en Pregunta 4.3).
7. **Trade-offs del componente de estado/scheduler introducido por el escenario** — Para Caso D, esto es **Dkron como scheduler distribuido + BoltDB embebido en EBS como almacén persistente** (NO RDS — descubrimos en producción que Dkron OSS no soporta Postgres, ver PARTE 5.4 y 11.2). Qué problema resuelve (programación distribuida y durable) y qué problemas operativos NUEVOS introduce: drift entre hora programada y real, riesgo de ejecución duplicada al reiniciar, **acoplamiento del estado al ciclo de vida de la EC2** (si destruyes la EC2 sin snapshot del EBS, pierdes histórico de jobs — mitigado con DLM y procedimiento R1 del runbook), complejidad de migraciones de schema en upgrades. Esta es la pregunta exacta que pide el PDF (sección 6.2 B punto 7).

### C — Problemas encontrados (~1 página) — entre 3 y 5 problemas REALES
Por cada uno: síntoma → método de investigación → causa raíz → solución → prevención.

**Aquí van los errores que SI te pasaron** (todos los marcados como 💥 en esta guía). Ejemplos:
- **Problema:** ALB target unhealthy y el container de Dkron en `Restarting (1)` infinito. **Investigación:** `docker logs dkron` mostró que el binario imprimía el listado de flags y salía con código 1. **Causa raíz:** habíamos puesto `--store=postgres` en el `command` del compose, pero Dkron OSS no soporta backends externos (es feature de Dkron Pro). **Solución:** eliminar `--store=postgres`, añadir `--data-dir=/dkron.data` con bind mount al volumen EBS de la EC2, eliminar el módulo Terraform `storage/` con todo su RDS + SSM + SG. **Prevención:** verificar la matriz de features OSS vs Pro de cualquier componente externo **antes** de diseñar la infra a su alrededor. Detalle completo en PARTE 11.2.
- **Problema:** Trivy bloqueó CVE en imagen oficial. **Investigación:** revisé el CVE en NVD. **Causa raíz:** versión de Go en la imagen tenía vulnerabilidad sin fix upstream. **Solución:** agregué a `.trivyignore` con justificación. **Prevención:** alarma para revisar `.trivyignore` cada mes.

### D — Costos (~½ página)
Tabla de costos mensuales (estimado con [AWS Pricing Calculator](https://calculator.aws) o [Infracost](https://www.infracost.io/) — el PDF acepta cualquiera de los dos). Usa **dos columnas**: el costo "honesto 24/7" y el optimizado del proyecto.

| Recurso | Configuración | 24/7 sin optimizar | Optimizado (free tier + destroy nocturno + NAT Inst) |
|---|---|---|---|
| **EC2 — Dkron host** | t3.small → t3.micro | $15 | $0 (free tier 750h) |
| EBS gp3 (raíz EC2) | 20 GB | $1.60 | $0.30 |
| ECS Fargate — Prometheus + Alertmanager | 0.25 vCPU + 0.5 GB | $7 | $1.20 (FARGATE_SPOT × 85h) |
| ECS Fargate — Grafana | 0.25 vCPU + 0.5 GB | $7 | $1.20 |
| ~~RDS PostgreSQL~~ | ~~db.t3.micro single-AZ~~ | **eliminado** ($0) | **eliminado** ($0) |
| ALB | 1 LCU promedio | $20 | $1.70 (85h activo) |
| NAT | NAT Gateway 24/7 vs NAT Instance t3.nano | $32 | $0.30 (t3.nano × 85h) |
| EFS (Prometheus + Grafana) | 2 GB | $0.60 | $0.60 |
| ECR | 1 GB storage | $0.10 | $0.10 |
| S3 (tfstate + ansible-ssm) | <1 GB | $0.05 | $0.05 |
| Lambda alertmgr-to-sns | <100 invocaciones/mes | $0 (free tier) | $0 |
| CloudWatch Logs | retención 7d → 1d, ~3 GB | $4 | $1 |
| **Total** | | **~$87** | **~$6-8** |

> 💡 Antes el total 24/7 era ~$102 contando RDS. Al cambiar Dkron a BoltDB embebido (ver PARTE 5.4) se cayó RDS y la cifra bajó a ~$87/mes 24/7.

**Optimizaciones concretas para producción real** (el PDF pide DOS — elige las dos más fundamentales):
1. **Savings Plan** o Reserved Instances para EC2/Fargate — ahorro ~30% sobre el costo on-demand.
2. **Reemplazar NAT Gateway** por VPC Endpoints (ECR, SSM, CloudWatch Logs) + NAT Instance pequeña para egress puntual. Ahorro ~$28/mes y reduce latencia.

> 💡 Las técnicas de *desarrollo* (free tier, destroy nocturno, FARGATE_SPOT) van en la sección E del reporte como "lo que aplicamos durante el bootcamp", no como producción real. Diferéncialas claramente.

### E — Reflexión (~½ página)
- **Para una segunda iteración**: HA multi-AZ con un Auto Scaling Group de 2-3 EC2s y Dkron en modo cluster (Serf), blue-green deploys con dos target groups, AMI custom horneada con Packer en vez de bootstrap con Ansible cada vez.
- **Componente que mejor demuestra DevOps Mid**: la **separación Terraform↔Ansible**: dos herramientas, dos capas, una sola fuente de verdad. El reporte explica esa frontera, no solo el código.
- **Qué sustituirías en producción real**: Dkron por **AWS Step Functions** + **EventBridge Scheduler** para eliminar la EC2 y la operativa de Ansible, ganando managed y serverless. La excepción: si necesitas ejecutar scripts arbitrarios on-prem o con dependencias específicas, Dkron sigue ganando.

## ❓ 10.5 Checklist final antes de entregar

- [ ] `terraform fmt -check` pasa local
- [ ] `terraform validate` pasa local
- [ ] `ansible-lint` y `yamllint` pasan local
- [ ] `ansible-playbook --syntax-check` pasa para `site.yml` y `deploy.yml`
- [ ] Pipeline en `main` está verde (incluyendo el job `ansible-deploy`)
- [ ] **Ningún step crítico tiene `continue-on-error: true`** (regla PDF 5.3.8)
- [ ] Trivy no tiene HIGH/CRITICAL sin documentar
- [ ] ALB devuelve 200 en `/v1/jobs`
- [ ] El playbook es **idempotente**: corre `ansible-playbook site.yml` dos veces seguidas y la segunda termina con `changed=0`
- [ ] Dashboard de Grafana muestra datos (paneles RED + SLOs en verde)
- [ ] Prometheus tiene `up{job="dkron"} == 1` y reglas en estado `OK`
- [ ] Alerta llegó al email cuando la provocaste — el flujo Prometheus FIRING → Alertmanager → Lambda → SNS funciona end-to-end (capturada en evidencias)
- [ ] `docs/runbook.md` tiene 3 procedimientos: R1 (backup/restore del EBS con BoltDB), R2 (rollback Ansible), R3 (recreación EC2)
- [ ] `REPORTE.md` está completo (>2.000 palabras), escrito por TI, con frontera Terraform↔Ansible explicada
- [ ] Todas las imágenes pinneadas (`v4.0.9`, no `latest`)
- [ ] Versión de `ansible-core` y de las colecciones documentadas en README
- [ ] No hay secretos en el repo: `git log -p | grep -iE "password|secret|key" | head`
- [ ] Tags `Project, Environment, Owner, ManagedBy` en TODOS los recursos
- [ ] `terraform destroy` deja todo limpio (pruébalo y vuelve a `apply` + `ansible-playbook`)
- [ ] README explica cómo levantar local Y desplegar a AWS (terraform + ansible)
- [ ] Evidencias en `docs/evidencias.md` con timestamps (las **4 obligatorias** del PDF 6.4)

## ❓ 10.6 Video explicativo (opcional pero recomendado — PDF 6.5)

> El PDF (sección 6.5) dice: *"Como complemento opcional al material principal, se sugiere grabar un video de al menos 10 minutos donde el estudiante recorra el proyecto y fundamente sus decisiones. La ausencia de este entregable no afecta la calificación; presentarlo refuerza la evidencia de comprensión personal y puede inclinar la evaluación a favor del estudiante en casos limítrofes, especialmente sobre la sección de conceptos clave del reporte."*

**Decide pronto** si lo vas a hacer. Si tu sección C del reporte (problemas reales) quedó floja, el video puede salvarte 2-3 puntos. Si tu reporte es sólido, el video es ganancia marginal.

**Estructura sugerida (PDF 6.5):**
1. **Recorrido por la arquitectura desplegada** (~2 min) — mostrar el diagrama de `docs/arquitectura.md` y la consola AWS con los recursos creados (VPC, EC2 + su EBS con BoltDB, ALB, ECR, SSM Parameters, Fargate cluster). Si el evaluador pregunta por la BD, explica que no hay RDS — la persistencia es BoltDB local sobre EBS porque Dkron OSS no soporta Postgres (PARTE 9.2).
2. **Pipeline ejecutándose end-to-end** (~3 min) — abrir un PR en vivo, mostrar las validaciones (fmt, validate, tflint, Checkov, ansible-lint, Trivy), merge a main, aprobar el environment "production", y mostrar Terraform apply + Ansible deploy ejecutándose.
3. **Dashboard de observabilidad y SLOs definidos** (~2 min) — Grafana abierto, paneles RED, los 2 SLOs en verde, comentar las queries PromQL.
4. **Generación intencional de violación del SLO + entrega de la alerta** (~2 min) — replicar el procedimiento de 8.6 en vivo, mostrar el email recibido, abrir Logs Insights y correlacionar con el `job_id`.
5. **Reflexión sobre los desafíos durante la operación y cómo los resolviste** (~1 min) — 2 ó 3 momentos donde te trabaste y la solución que aplicaste.

**Forma de entrega:**
- Publicar como **enlace privado** en YouTube (no listado), Vimeo o Loom.
- Agregar el enlace en el README.md (sección "Video explicativo").
- **No requiere edición ni producción profesional** — el objetivo es la explicación, no el formato.

> ⚠️ **Reglas del video que vienen heredadas del reporte:**
> - El video TIENE que ser tú hablando con tus palabras (no leyendo un guion generado por IA).
> - Se aplican las mismas reglas anti-IA del reporte: si el evaluador detecta tono uniformemente impersonal o ausencia de errores típicos del español del autor, puede ser invalidado igual que el reporte.
> - El video NO sustituye el reporte: es complemento, no reemplazo.

## ❓ 10.7 Pesos de evaluación — dónde invertir cada hora (PDF sección 8)

> **Tabla literal del PDF (sección 8):**

| Bloque | Peso | Comentario para tu estrategia |
|---|---|---|
| **Reporte técnico** (claridad de decisiones, dominio conceptual, problemas reales) | **45%** | El bloque más grande, por mucho. Sin reporte no se evalúa el código. |
| **CI/CD** (pipeline reproducible, escaneos, deploy automático) | **25%** | Pipeline verde end-to-end con escaneos pasando es lo que se evalúa. |
| **Containerización y despliegue en AWS** (cómputo, ALB, IAM, IaC) | **20%** | Que la app responda en el ALB y la infra sea reproducible. |
| **Observabilidad** (métricas custom, dashboard, SLOs y alertas verificadas) | **10%** | El bloque más pequeño en peso. Cumple los mínimos del PDF 5.4 y no le metas más horas. |

**Texto del PDF que tienes que tener presente:**
> *"El reporte concentra el mayor peso porque la diferencia entre un perfil junior y un perfil mid-level se manifiesta en la capacidad de fundamentar técnicamente las decisiones tomadas. Sin defensa oral, el reporte es la única vía para evidenciar esa comprensión, y por eso se evalúa con criterio estricto sobre la solidez del razonamiento."*

### 🎯 Estrategia de tiempo basada en pesos

```
   Si tienes 60h totales para el proyecto, distribúyelas así:
   ────────────────────────────────────────────────────────
   Reporte (45%):              ~27h   ← inversión más grande
   CI/CD (25%):                ~15h
   Containerización + IaC (20%): ~12h
   Observabilidad (10%):        ~6h
   ────────────────────────────────────────────────────────

   Una hora extra invertida en el reporte da 4.5x más nota
   que la misma hora invertida en pulir un dashboard.
```

> ⚠️ **Trampa común del bootcamp:** los estudiantes se enamoran del código bonito (Terraform refactor, dashboards perfectos, módulos elegantes) y descuidan el reporte. **El evaluador no premia código bonito** — premia comprensión documentada. Reasigna horas si llegas a la última semana sin reporte.

---

<a id="parte-14"></a>
# PARTE 14 — Tabla maestra de errores comunes (consolidada)

| # | Error | Causa | Solución |
|---|---|---|---|
| 1 | "BucketAlreadyExists" S3 | nombres globales | Agrega entropía al nombre |
| 2 | Container `RUNNING` pero target `unhealthy` | path/timing del health check | `/v1/jobs`, healthy_threshold=2, interval=30 |
| 3 | "Unable to assume role" GHA | trust policy mal | Revisa `sub` del policy |
| 4 | Costos inesperados | NAT Gateway 24/7 | Usa `destruir.yaml` cada noche |
| 5 | Reporte "se siente IA" | frases genéricas | Reescribe con anécdotas reales |
| 6 | Imagen `:latest` | violación regla PDF | Pinea a versión exacta |
| 7 | Pipeline corre `apply` sin aprobar | sin environment | Settings → Environments → production → reviewers |
| 8 | ~~RDS expuesto~~ (N/A — ya no hay RDS, ver PARTE 5.4) | — | — |
| 9 | "InvalidClientTokenId" | credenciales | `aws configure` |
| 10 | destroy bloqueado por VPC | ENIs liberándose | Espera 5 min |
| 11 | Permission denied Docker | usuario fuera de grupo | `usermod -aG docker $USER` |
| 12 | docker-compose vs docker compose | versiones | Usa plugin v2 |
| 13 | Dkron OSS imprime el help y muere | usaste `--store=postgres` (solo existe en Pro) | Quita el flag, añade `--data-dir=/dkron.data` + volumen EBS. Ver PARTE 11.2 |
| 14 | ALB unhealthy tras `terraform apply` | EC2 vacía, falta correr Ansible | `ansible-playbook site.yml` |
| 15 | Container Dkron reinicia en loop | flag inválido en el `command` (típicamente `--store=postgres` con OSS) | `docker logs dkron` → si imprime el help, revisa el `command`. Ver PARTE 11.2 |
| 16 | Tags faltantes | olvido | Usa `default_tags` en provider |
| 17 | Dos applies concurrentes | sin lock | `use_lockfile = true` |
| 18 | Trivy bloqueando | CVEs sin fix | `.trivyignore` documentado |
| 19 | Target DOWN en Prometheus | IP de la EC2 cambió, file_sd target no actualizado | Re-aplica Terraform y `force-new-deployment` del task de Prom |
| 19b | Prometheus pierde datos al reiniciar | falta volumen EFS | Mount `/prometheus` desde EFS access point con uid 65534 |
| 19c | Grafana sin dashboard | provisioning mal montado | Monta YAML en `/etc/grafana/provisioning/dashboards` |
| 20 | Email SNS no llega | suscripción no confirmada | Click en confirmation email |
| 21 | ~~"Subnet group requires 2 AZs"~~ (N/A sin RDS) — pero seguimos creando 2 subnets privadas para Fargate multi-AZ | — | — |
| 22 | Job no se ejecuta | schedule mal escrito | Usa `@every 30s` para test |
| 23 | Checkov falla por defaults | reglas estrictas | Skip con justificación o ajusta config |
| 24 | terraform fmt en CI falla | local no formateado | `terraform fmt -recursive` antes de push |
| 25 | OIDC provider no existe | nunca usado en cuenta | Cambia data → resource para crearlo |
| 26 | `ansible-inventory --graph` vacío | tags o región mal en el plugin aws_ec2 | Verifica `tag:Project=dkron` y `regions:` |
| 27 | Conexión `aws_ssm` falla | falta plugin session-manager o IAM | Instala `session-manager-plugin` y revisa role |
| 28 | Playbook reporta `changed=N` siempre | `command:` o `shell:` sin `creates`/`changed_when` | Usa módulos nativos o agrega `changed_when: false` |
| 29 | `community.docker.docker_compose_v2` falla "no module 'docker'" | falta `pip install docker` | Asegura el rol `docker` instala el SDK Python antes |
| 30 | `wait_for: port=8080` timeout | container en `Restarting (1)` (típicamente flag inválido — ver #15) o image_tag mal | `docker compose ps` + `docker logs dkron --tail 50` |
| 31 | ansible-lint bloquea con `name[casing]` | profile production estricto | Usa Start Case en nombres o documenta skip en `.ansible-lint` |
| 32 | EC2 no aparece en SSM | falta `AmazonSSMManagedInstanceCore` o ruta NAT | Atach policy + verifica route table de la subnet privada |
| 33 | Bucket `ansible-ssm` no existe | Terraform no lo creó | Recurso `aws_s3_bucket.ansible_ssm` y permisos en instance profile |

---

<a id="parte-12"></a>
# PARTE 12 — Cierre: destruir y costo cero

> **Ansible no tiene state**: nada que destruir del lado de Ansible. Toda la infraestructura física vive en Terraform; basta con `terraform destroy`. Lo único que Ansible "deja" es la configuración dentro de la EC2, y la EC2 se borra cuando Terraform la borra.

```bash
# Opción A: desde GitHub UI
# Actions → destruir → Run workflow → escribe "DESTRUIR"

# Opción B: local
cd infra/envs/prod
# terraform.tfvars ya tiene tus valores (PARTE 5.1.4)
terraform destroy
```

**Verifica que no quede nada:**
```bash
aws ec2 describe-instances --filters "Name=tag:Project,Values=dkron" --query "Reservations[].Instances[].State.Name"
aws ecs list-clusters --region us-east-1
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=dkron"
aws elbv2 describe-load-balancers --query "LoadBalancers[?Tags[?Key=='Project' && Value=='dkron']]"

# El bucket auxiliar de Ansible-SSM lo destruye Terraform (force_destroy=true).
# Solo borra a mano si por alguna razón el destroy lo dejó huérfano:
# aws s3 rb s3://dkron-ansible-ssm-<account-id> --force
```

> ⚠️ El bucket de tfstate **NO lo destruyas**. Tu state vive ahí. Si lo borras, empiezas de cero.

---

## ❓ 12.1 ¿Cómo bajo el costo SIN cambiar la arquitectura híbrida?

> El bootcamp evalúa la arquitectura, no el bolsillo. Pero si trabajas 6 semanas a $102/mes 24/7 son $150 desperdiciados. Aquí están las técnicas FinOps que aplican **manteniendo Dkron en EC2+Ansible y Prom/Grafana en Fargate** (sin cambiar la decisión de arquitectura del reporte):

### Las 3 palancas, ordenadas por impacto

```
   Palanca               Ahorro/mes    Esfuerzo    Cambia diseño?
   ─────────────────     ──────────    ────────    ──────────────
   1. Destroy nocturno   ~$60          ⭐          NO
   2. Free tier 12 meses ~$30          ⭐⭐         NO
   3. NAT GW → NAT Inst  ~$28          ⭐⭐⭐        NO (tweak red)
   4. Fargate Spot       ~$10          ⭐⭐         NO
   5. Logs 1d retention  ~$3           ⭐          NO
   6. Combinar Prom+Graf ~$3           ⭐⭐         leve (1 task)
   ─────────────────────────────────────────────────────────────
   Aplicando 1+2+5 (mínimo esfuerzo): de $102 → ~$8/mes.
   Aplicando todas: de $102 → ~$5/mes.
```

### Palanca 1 — Destruir todo cuando no trabajas (el más rentable)

Es lo que ya tienes con `destruir.yaml`, pero formalízalo: un calendario realista de 3h/día = 85h/mes activo, 660h/mes destruido. AWS cobra por hora prorrateada — todo lo que destruyes deja de contar.

**Workflow recomendado:**
- **Mañana (cuando empiezas):** Actions → ci-cd → manual trigger sobre main, o `terraform apply && ansible-playbook site.yml` local. Tarda ~10 min.
- **Noche (cuando terminas):** Actions → destruir → escribe `DESTRUIR`. Tarda ~5 min.

**Cuidado con:**
- **EBS root de la EC2 (contiene el BoltDB de Dkron):** con `delete_on_termination = true` (default en este proyecto), `terraform destroy` borra el volumen. **Si quieres preservar el histórico de Dkron entre sesiones, toma un snapshot del volumen antes del destroy** (ver runbook R1). Para producción real, activa DLM con snapshots diarios.
- **CloudWatch Logs:** los log groups sobreviven a `terraform destroy` si no los gestiona el módulo. Verifica que `aws_cloudwatch_log_group.dkron` y `compose` estén dentro del state.
- **Bucket S3 ansible-ssm:** `force_destroy = true` ya está, así que se borra solo.
- **ECR:** las imágenes sobreviven al destroy si no agregas `force_delete = true`. **No las borres** — el primer `apply` del día siguiente las re-pulea innecesariamente; mejor pagar los $0.10/GB y tener push barato.

### Palanca 2 — Aprovechar el AWS Free Tier (12 primeros meses)

Si tu cuenta tiene <12 meses, edita estos defaults para entrar al free tier:

**`infra/modules/compute/variables.tf`:**
```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"   # antes t3.small — free tier 750h/mes
}
```

> ⚠️ **t3.micro tiene 1 vCPU y 1 GB de RAM**. Dkron + node_exporter caben justo. Si ves OOMKilled en Docker (`docker logs dkron`), sube a t3.small. Documenta el OOM en la sección C del reporte.

**EBS free tier checklist (el volumen root de la EC2 contiene el BoltDB de Dkron):**
- `volume_size = 20` ✓ (free tier cubre 30 GB de gp3)
- `volume_type = "gp3"` ✓
- `encrypted = true` ✓ (no cuesta extra)
- `delete_on_termination = true` ✓ — pero significa que al destruir EC2 pierdes el histórico de Dkron (mitigación: snapshots EBS, ver runbook R1)

### Palanca 3 — NAT Gateway → NAT Instance (la diferencia más grande para 24/7)

Si por alguna razón **no puedes apagar** (estás en una semana de demos, una rama larga abierta, etc.), un NAT Instance t3.nano cuesta $3.80/mes vs $32 del NAT Gateway.

**Reemplazo en `infra/modules/network/main.tf`** (alineado a los nombres del módulo: `aws_vpc.main`, `var.project`, `aws_subnet.public[0]`):
```hcl
# COMENTA o elimina aws_nat_gateway si vas full NAT Instance:
# resource "aws_nat_gateway" "this" { ... }
# resource "aws_eip" "nat" { ... }

resource "aws_security_group" "nat" {
  name   = "${var.project}-nat-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]   # solo desde dentro de la VPC
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-nat-sg" }
}

data "aws_ssm_parameter" "nat_ami" {
  # AMI oficial de Amazon Linux 2 con NAT preconfigurada
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ssm_parameter.nat_ami.value
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false                       # ← clave para NAT
  vpc_security_group_ids      = [aws_security_group.nat.id]

  user_data = <<-EOT
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  EOT

  tags = { Name = "${var.project}-nat" }
}

# Reemplaza la route 0.0.0.0/0 → NAT GW por una que apunte a la ENI de la instance.
# (Borra el resource aws_nat_gateway.this y crea esta en su lugar.)
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}
```

**Trade-offs honestos para el reporte (sección C):**
- **Pro:** $32 → $3.80 (≈90% off).
- **Contra:** SPOF (un nodo). Si t3.nano se reinicia, 60s sin Internet saliente. Para academic, irrelevante. Para prod real, NAT GW gana.
- **Contra:** mantenimiento del SO de la NAT instance — no auto-update de CVE.

**Alternativa intermedia: VPC Interface Endpoints solo para servicios que la EC2 usa (ECR, SSM, CloudWatch Logs):**
- 4 endpoints × $7.30/mes = $29.20 — **NO ahorra** vs NAT GW si solo tienes 1 EC2 y poco tráfico.
- Solo conviene si destruyes el NAT GW y aún así necesitas ECR/SSM. Documenta esta decisión en el reporte.

### Palanca 4 — Fargate Spot para Prom/Grafana (-70%)

Las tasks de observabilidad pueden interrumpirse sin daño (Prometheus persiste en EFS, Grafana también). Aprovecha **Fargate Spot**.

**Cambio en `infra/modules/monitoring/prometheus.tf`:**
```hcl
resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = aws_ecs_cluster.obs.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1

  # Reemplaza launch_type = "FARGATE" por capacity_provider_strategy:
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.prometheus.id]
  }
}
```

> Si te preocupa que SPOT te interrumpa Grafana mientras lo demuestras al evaluador: deja Grafana en `FARGATE` y solo Prometheus en `FARGATE_SPOT`. Justificación documentada en sección C del reporte.

### Palanca 5 — Retención de logs corta (-75% en CloudWatch)

```hcl
resource "aws_cloudwatch_log_group" "dkron" {
  name              = "/dkron/ec2/dkron"
  retention_in_days = 1   # ← antes 7. Para alcance de proyecto basta 1 día.
}
```
Si necesitas más historia, configura un **export task a S3** (mucho más barato que mantener en logs):
```hcl
resource "aws_cloudwatch_log_subscription_filter" "to_s3" {
  # opcional, para sección E del reporte como mejora futura
}
```

### Palanca 6 — Una sola task de Fargate para todo el stack de observabilidad

En vez de **2 tasks** (prom+alertmanager juntos, grafana aparte) usa **1 sola task con 3 containers**: prom + alertmanager + grafana, todos compartiendo EFS. Reduce de 0.5 vCPU total a 0.5 vCPU total (mismo costo de cómputo) **pero ahorras la ENI extra y simplifica networking**:

```hcl
resource "aws_ecs_task_definition" "obs" {
  family                   = "dkron-obs"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # ...
  container_definitions = jsonencode([
    { name = "prometheus",   image = "prom/prometheus:v2.54.1",   ... },
    { name = "alertmanager", image = "prom/alertmanager:v0.27.0", ... },
    { name = "grafana",      image = "grafana/grafana:11.2.0",    ... }
  ])
}
```

Trade-off: si Grafana crashea, los 3 containers reinician (porque `essential = true`). Documéntalo.

## ❓ 12.2 Tabla "antes vs después" para el reporte (sección D — Costos)

Reemplaza la tabla del reporte por una con las dos columnas:

| Recurso | 24/7 sin optimizar | **Optimizado** (free tier + destroy nocturno + NAT Inst) |
|---|---|---|
| EC2 — Dkron host | t3.small $15 | t3.micro free tier × 85h activo = **$0** |
| EBS gp3 (raíz EC2) | $1.60 | $0.30 (20 GB × 85h prorrateado) |
| ECS Fargate — Prometheus | $7 (FARGATE) | $1.20 (FARGATE_SPOT × 85h) |
| ECS Fargate — Grafana | $7 | $1.20 (combinada o spot) |
| ~~RDS PostgreSQL~~ | **eliminado** ($0) | **eliminado** ($0) |
| ALB | $20 | $1.70 (85h × $0.0225 + LCU mínimo) |
| NAT | NAT Gateway $32 | NAT Instance t3.nano 85h = **$0.30**, o NAT GW 85h = $3.83 |
| EFS | $0.60 | $0.60 (siempre prendido pero barato) |
| ECR | $0.10 | $0.10 |
| S3 (tfstate + ansible-ssm) | $0.05 | $0.05 |
| Lambda alertmgr-to-sns | $0 | $0 |
| CloudWatch Logs (1d) | $4 | $1 |
| **Total mensual** | **~$87** | **~$6-8** (free tier) o **~$12** (sin free tier) |

**Para escribir en sección D del reporte:**
> "El costo 24/7 estimado es ~$87/mes (antes ~$102 con RDS; se cayeron ~$15 al eliminar el módulo storage — ver PARTE 5.4), dominado por NAT Gateway ($32) y ALB ($20). Las dos optimizaciones que aplicaría en producción real (PDF sección 6.2 D) son: (1) reemplazar NAT Gateway por VPC Endpoints para los flujos críticos (ECR, SSM, CloudWatch) más una NAT Instance t3.nano para el resto del egress, ahorrando ~$28/mes; (2) consolidar las 2 tasks de observabilidad en 1 task con 3 containers en `FARGATE_SPOT`, ahorrando ~70% del cómputo de observabilidad. Durante el desarrollo del bootcamp aplicamos también `terraform destroy` nocturno (orquestado en `destruir.yaml`), llevando el costo total del proyecto a <$10."

## ❓ 12.3 ¿Hay algo gratis adicional que ya estoy desperdiciando?

| Servicio | Free tier permanente | ¿Lo aprovechamos? |
|---|---|---|
| **CloudWatch Metrics** | 10 custom metrics + 5GB ingesta | ✅ |
| **CloudWatch Logs** | 5 GB ingesta + 5 GB storage/mes | ✅ con retention 1d |
| **CloudWatch Alarms** | 10 alarms | ✅ tenemos 2 |
| **SNS** | 1k publicaciones/mes | ✅ |
| **Lambda** | 1M invocaciones/mes | ✅ |
| **ECR** | 500 MB storage gratis | ✅ |
| **AWS Budgets** | 2 budgets gratis | configura el alert a $10 (ver Pregunta 0.3) |
| **GitHub Actions** | 2000 min/mes en repos privados, ilimitado en públicos | hazlo público y ahorra |

## ❓ 12.4 Mini-checklist de "modo barato"

Antes de hacer `git push` que dispara `apply`:

- [ ] `instance_type = "t3.micro"` (free tier) en `infra/modules/compute/`
- [ ] EBS root `volume_size = 20` GB gp3 (free tier cubre 30 GB)
- [ ] `retention_in_days = 1` en todos los `aws_cloudwatch_log_group`
- [ ] `FARGATE_SPOT` en task de Prometheus (Grafana opcional)
- [ ] NAT Instance t3.nano si dejas infra prendida >12h/día, o NAT Gateway si destruyes a diario
- [ ] AWS Budget configurado a $10 con alerta email
- [ ] Workflow `destruir.yaml` corre cada noche (cron en GHA o manual disciplinado)

> 💡 **Una técnica avanzada para sección E del reporte (reflexión):** un `aws_ce_anomaly_subscription` envía un email si el costo diario supera un umbral. Cuesta $0 hasta cierto punto y es lo que usa una empresa real.

---

<a id="parte-13"></a>
# PARTE 13 — Cronograma sugerido de 6 semanas (2-3h/día)

## 🗺️ Diagrama: visualización del cronograma de 6 semanas

```
   Sem 1: FUNDAMENTOS    ██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  16%
          • PDF + Parte 0-1
          • Instalaciones
          • Dkron local con docker-compose
          • Romper cosas a propósito ←  importante

   Sem 2: AWS + IAC      ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░  33%
          • Cuenta AWS, IAM, billing alert
          • Bucket de tfstate
          • Módulos Terraform (network, compute con EC2)
          • Primer apply, push imagen ECR
          • EC2 vacía + ALB unhealthy ←  esperado

   Sem 3: ANSIBLE        ██████████████████░░░░░░░░░░░░░░░░░░░░  50%
          • Ansible local + colecciones
          • Inventario dinámico aws_ec2
          • Roles docker + dkron-compose
          • site.yml — Dkron corriendo en AWS ←  victoria grande
          • Probar idempotencia (ejecutar 2 veces)

   Sem 4: CI/CD          ████████████████████████░░░░░░░░░░░░░░  66%
          • OIDC + roles
          • Workflow ci-cd.yaml (incluye ansible-deploy)
          • Workflow destruir.yaml
          • Primer PR validado y mergeado
          • Apply + Ansible automatizado con aprobación

   Sem 5: OBSERV. + DEC. ██████████████████████████████░░░░░░░░  83%
          • Prom + Grafana en Fargate (con file_sd → EC2)
          • Dashboard + 2 alarmas
          • Provocar alerta intencional ←  evidencia obligatoria
          • Decidir las 5 respuestas técnicas

   Sem 6: REPORTE        ██████████████████████████████████████  100%
          • REPORTE.md (sin IA, escrito por TI)
          • Runbook con R1-R3
          • Evidencias en docs/
          • Checklist final + destroy + reapply + ansible
          • (opcional) Video 10 min
          • Entregar 🚀

   Cada noche/sesión:
   ┌─────────────────────────────────────────┐
   │  terraform destroy  o  workflow destruir │  ← cero costo dormido
   └─────────────────────────────────────────┘
```



### Semana 1 — Fundamentos
- [ ] Día 1-2: Leer PDF completo y la Parte 0-1 de esta guía. Hacer las instalaciones.
- [ ] Día 3-4: Parte 2 (conceptos), prestando atención a 2.3 (IaC vs config) y 2.11 (Ansible).
- [ ] Día 5-7: Parte 3. Levantar Dkron local. Crear el primer job. Romper cosas a propósito.

### Semana 2 — AWS y Terraform (módulo compute con EC2)
- [ ] Día 1-2: Parte 4. Crear cuenta, IAM, alertas billing, bucket de tfstate.
- [ ] Día 3-7: Parte 5. Escribir módulos network y compute (con la **EC2** + ALB + IAM + ECR), primer `apply`. La EC2 queda vacía — eso está bien. **No hay módulo storage**: la persistencia de Dkron es BoltDB local sobre EBS (ver PARTE 5.4).

### Semana 3 — Ansible (capa de configuración) ⭐️ semana añadida
- [ ] Día 1-2: Parte 6.1-6.3. Instalar Ansible, requirements.yml, ansible.cfg, inventario dinámico aws_ec2.
- [ ] Día 3-4: Parte 6.4-6.5. Roles `docker` y `dkron-compose` con templates Jinja2.
- [ ] Día 5: Parte 6.6-6.7. Playbooks site.yml/deploy.yml, primera ejecución, smoke test contra el ALB.
- [ ] Día 6-7: probar **idempotencia** (correr el playbook dos veces, segundo run debe ser changed=0). Romper a propósito (apagar Docker, borrar el .env) y re-correr Ansible para arreglar.

### Semana 4 — CI/CD
- [ ] Día 1-2: Parte 7.1-7.2. OIDC, role IAM, secrets en GitHub.
- [ ] Día 3-5: Parte 7.3. Workflow ci-cd.yaml con jobs `iac-validate`, `ansible-validate`, `replicate-image`, `trivy-scan`, `apply`, `ansible-deploy`. Primer PR exitoso end-to-end.
- [ ] Día 6-7: Pruebas — rompe el pipeline a propósito (ansible-lint, Trivy, fmt). Workflow destruir.yaml.

### Semana 5 — Observabilidad y decisiones
- [ ] Día 1-3: Parte 8. Módulo `monitoring/` con file_sd → EC2 IP. Dashboard + alertas. Provocar alerta intencional.
- [ ] Día 4-5: Parte 9. Decidir las 5 respuestas con argumentos propios.
- [ ] Día 6-7: Empezar REPORTE.md sección por sección.

### Semana 6 — Reporte y entrega
- [ ] Día 1-3: Terminar REPORTE.md (con la frontera Terraform↔Ansible documentada). Releer 2 veces, corregir solo ortografía.
- [ ] Día 4: Runbook (R1, R2, R3) + README + evidencias.
- [ ] Día 5: Checklist final. Prueba destroy + reapply + ansible-playbook desde cero.
- [ ] Día 6: Video opcional.
- [ ] Día 7: Entregar.

**Cada noche:** `terraform destroy` o workflow `destruir`. **El sábado y domingo:** apaga todo lo que no uses.

---

<a id="apendice-a"></a>
# APÉNDICE A — Bitácora "yo me equivoqué así" (template para tu reporte)

Cuando te equivocas, anota inmediatamente en este formato. Lo usarás en la sección C del reporte.

```markdown
## Problema #N: [título corto]

**Fecha:** 2026-MM-DD
**Síntoma:** [qué viste, mensaje exacto del error]
**Hipótesis iniciales (lo que probé y no era):**
- [ ] X — descartada porque...
- [ ] Y — descartada porque...
**Investigación:** [qué comandos/logs/dashboards usaste]
**Causa raíz:** [una sola frase]
**Solución:** [qué cambiaste, en qué archivo, qué línea]
**Prevención futura:** [test, alerta, regla en CI]
**Tiempo perdido:** [horas]
```

Llena al menos 5 entradas durante el proyecto. Te servirán para la sección C del reporte y para entrevistas de trabajo.

---

<a id="apendice-b"></a>
# APÉNDICE B — Glosario rápido

| Término | Definición corta |
|---|---|
| **ALB** | Application Load Balancer. Balanceador HTTP de AWS. |
| **AMI** | Amazon Machine Image. Plantilla de un servidor virtual. |
| **CIDR** | Notación de rangos IP. `10.0.0.0/16` = 65k IPs. |
| **CloudWatch** | Sistema de logs/métricas/alarmas de AWS. |
| **ECR** | Elastic Container Registry. Docker Hub privado. |
| **ECS** | Elastic Container Service. Orquestador de containers. |
| **EKS** | Elastic Kubernetes Service. Kubernetes managed. |
| **Fargate** | Modo serverless de ECS. AWS gestiona los nodos. |
| **HCL** | HashiCorp Configuration Language. Lenguaje de Terraform. |
| **IAM** | Identity and Access Management. Permisos de AWS. |
| **IaC** | Infrastructure as Code. |
| **NAT Gateway** | Permite a subnet privada salir a Internet sin entrar. |
| **OIDC** | OpenID Connect. Federación de identidades sin keys. |
| **Prometheus** | Sistema de monitoreo open-source basado en pull (scrape) y serie temporal. |
| **PromQL** | Lenguaje de consulta de Prometheus (queries como `rate(metric[5m])`). |
| **Alertmanager** | Componente de Prometheus que enruta alertas a canales (email, webhook, Slack). |
| **Grafana** | UI para dashboards y alertas sobre fuentes como Prometheus y CloudWatch. |
| **EFS** | Elastic File System. Almacenamiento de archivos compartido y persistente para Fargate. |
| **Cloud Map** | Service discovery DNS de AWS — resuelve `<svc>.<ns>.local` a IPs internas. |
| **RDS** | Relational Database Service. BDs managed. (En este proyecto NO se usa — Dkron OSS persiste en BoltDB embebido sobre EBS; ver PARTE 5.4 y 9.2.) |
| **BoltDB** | Key-value store embebido escrito en Go. Es un archivo único en disco; lo usa Dkron OSS como almacén por defecto cuando arrancas con `--data-dir=<path>`. No requiere proceso aparte ni puertos abiertos. |
| **SG** | Security Group. Firewall virtual de AWS. |
| **SLA / SLO / SLI** | Acuerdo / Objetivo / Indicador de nivel de servicio. |
| **SNS** | Simple Notification Service. Pub/sub para alertas. |
| **SSM** | Systems Manager. Incluye Parameter Store. |
| **VPC** | Virtual Private Cloud. Tu red en AWS. |
| **awsvpc mode** | Cada task ECS tiene su propia ENI (IP). |
| **container** | Aplicación empaquetada con sus dependencias. |
| **drift** | Desviación entre lo declarado y lo real. |
| **error budget** | Margen tolerado de errores antes de violar SLO. |
| **idempotente** | Que ejecutarlo N veces produce el mismo resultado que 1 vez. |
| **pipeline** | Secuencia automatizada de pasos (build, test, deploy). |
| **runbook** | Procedimiento documentado para una operación. |
| **scrape** | Recolectar métricas de un endpoint. |
| **sidecar** | Container auxiliar al lado del principal en una task. |
| **state** | Snapshot del estado de la infra (Terraform). |
| **task definition** | Plantilla de un container en ECS. |
| **tflint / tfsec / Checkov** | Linters/scanners de seguridad para Terraform. |
| **Trivy** | Scanner de vulnerabilidades en imágenes Docker. |
| **Ansible** | Herramienta de gestión de configuración: ejecuta playbooks YAML sobre máquinas remotas vía SSH/SSM. |
| **playbook** | Archivo YAML con una secuencia de tareas Ansible. |
| **rol (role)** | Carpeta con tasks/handlers/templates/defaults reutilizables. |
| **handler** | Tarea Ansible que solo corre si otra la `notify`-ica (ej. reiniciar Docker si cambió el daemon.json). |
| **inventario** | Lista de máquinas que Ansible va a configurar. Puede ser estático (INI/YAML) o dinámico (plugin aws_ec2). |
| **`aws_ec2` plugin** | Plugin de inventario dinámico de la colección amazon.aws: descubre EC2 por filtros (tags, región). |
| **`aws_ssm` connection** | Plugin de conexión Ansible que tunela vía AWS SSM Session Manager — sin SSH público ni bastion. |
| **ansible-lint / yamllint** | Linters para playbooks Ansible y archivos YAML. |
| **idempotencia (Ansible)** | Propiedad clave de un playbook: ejecutarlo N veces deja el sistema en el mismo estado, reportando `changed=0` desde la 2ª vez. |
| **Jinja2** | Motor de templates de Python que Ansible usa para renderizar archivos como `docker-compose.yml.j2` con variables. |
| **collection (Ansible)** | Paquete de módulos+roles distribuido por Ansible Galaxy (ej. `community.docker`, `amazon.aws`). |
| **file_sd_configs** | Mecanismo de Service Discovery de Prometheus que lee targets desde un JSON en disco — ideal para EC2 sin Cloud Map. |
| **node_exporter** | Exporter de Prometheus que expone métricas del sistema operativo (CPU, RAM, disco) en `:9100/metrics`. |
| **SSM Session Manager** | Servicio de AWS que permite abrir sesiones a EC2 sin SSH público, autenticando vía IAM. |

---

# 🎓 CIERRE: la mentalidad correcta

Este proyecto no se trata de hacer todo perfecto a la primera. Se trata de:
1. **Entender** por qué cada decisión.
2. **Equivocarte** y aprender del error.
3. **Documentar** el aprendizaje.

El bootcamp evalúa **comprensión**. Un proyecto con 3 problemas reales documentados (tu sección C) vale más que un proyecto "perfecto" sin huellas de esfuerzo. Eso es DevOps real: cosas se rompen, las arreglas, dejas un runbook para que la próxima vez sea más rápido.

**Equivócate, anota, soluciona, documenta.** Repite. Eso es la guía completa del Caso D.

¡Buena suerte! 🚀

---

<a id="parte-11"></a>
# PARTE 11 — Errores reales encontrados en producción (sesión de debug 2026-05-17)

Esta sección documenta tres fallos que aparecieron al ejecutar el playbook por primera vez contra la EC2 ya provisionada. Los dejo aquí porque son específicos del stack **Dkron OSS + AL2023 + community.docker** y no aparecen en la documentación oficial. Si te aparece alguno, no es que hicieras algo mal — es la combinación.

## ❓ 11.1 awscli muere con `ModuleNotFoundError: No module named 'urllib3'`

**Síntoma:** la task `aws ecr get-login-password --region us-east-1` falla con código de retorno 1. Si tienes `no_log: true` en la task no ves el error real — quítalo temporalmente para depurar.

**Causa:** el AWS CLI v1 que viene en AL2023 corre como `/usr/bin/python3 -s ...` (el flag `-s` excluye `/usr/local/lib/python3.9/site-packages/` del path de imports). El paquete `python3-urllib3` está instalado por rpm en `/usr/lib/python3.9/site-packages/urllib3/`, pero si previamente corriste `pip install docker --ignore-installed`, pip sobreescribe/borra archivos del urllib3 del sistema. Resultado: `rpm -q python3-urllib3` dice "instalado" pero `/usr/lib/python3.9/site-packages/urllib3/__init__.py` ya no existe → `ModuleNotFoundError`.

**Fix aplicado (ya está en el playbook):**
1. Quitar `--ignore-installed` del `extra_args` del módulo `pip` para que no vuelva a romper urllib3.
2. Añadir una tarea auto-sanadora que verifica con `rpm -V python3-urllib3` y, si detecta archivos faltantes, ejecuta `dnf reinstall -y python3-urllib3`. Está en `roles/docker/tasks/main.yml` justo después del pip install.

**Cómo se ve la tarea:**
```yaml
- name: Verificar integridad de python3-urllib3
  ansible.builtin.command: rpm -V python3-urllib3
  register: urllib3_verify
  failed_when: false
  changed_when: false

- name: Reinstalar python3-urllib3 si está corrupto
  ansible.builtin.command: dnf reinstall -y python3-urllib3
  when: urllib3_verify.stdout | length > 0
```

**Por qué importa para el reporte:** ejemplo concreto de "infra como código resiliente" — el playbook detecta corrupción y se auto-cura sin intervención manual. Buen punto para sección 9.8 (operación) del reporte.

## ❓ 11.2 Dkron container en `Restarting (1)` infinito — imprime el help y muere

**Síntoma:** después de `docker compose up -d`, `docker compose ps` muestra dkron con `Status: Restarting (1) Xs ago`. Los logs (`docker compose logs dkron`) imprimen el listado completo de flags de `dkron agent --help` y exit code 1.

**Causa:** el compose le pasa `--store=postgres` al binario. **Dkron OSS v4.0.9 no soporta backends externos** — los flags `--store`, `--backend`, `--dsn` solo existen en Dkron Pro (la versión comercial). El binario OSS no reconoce `--store`, asume que pasaste un comando inválido, imprime el help y sale.

Verificación: en el host corre `docker run --rm <imagen>:v4.0.9 agent --help | grep -iE 'store|backend|dsn|postgres'` — devuelve vacío. Ninguno de esos flags existe.

**Fix aplicado:**
1. Quitar `--store=postgres` del `command` del compose.
2. Añadir `--data-dir=/dkron.data` y montar un volumen `{{ dkron_data_volume }}:/dkron.data` para que BoltDB persista entre `docker compose down/up`.
3. Eliminar `DKRON_DSN` del `.env` (era una lookup a SSM que ya no se usa).
4. Eliminar el módulo Terraform `storage/` que aprovisionaba RDS + SSM SecureString del DSN.

**Cómo verificar que está corregido:** `curl http://<alb>/v1/jobs` devuelve `[]` (status 200) — Dkron arrancó, expuso la API, BoltDB inicializado vacío. La task `wait_for` + `uri` de Ansible cubre esto en el playbook.

**Lección de diseño:** verificar la matriz de features OSS vs Pro **antes** de aprovisionar infraestructura. Aquí gastamos RDS + SSM + un módulo Terraform completo en algo que el binario nunca iba a usar.

## ❓ 11.3 Handler `Reiniciar compose` falla con `Unsupported parameters: restarted`

**Síntoma:** al cambiar el template del compose, el handler se dispara y falla con:
```
Unsupported parameters for (community.docker.docker_compose_v2) module: restarted.
```

**Causa:** API incompatible. En `community.docker.docker_compose` (v1, deprecated) se usaba `state: present` + `restarted: true`. En `community.docker.docker_compose_v2` el parámetro `restarted` ya no existe — se usa directamente `state: restarted`.

**Fix:** en `roles/dkron-compose/handlers/main.yml`:
```yaml
- name: Reiniciar compose
  community.docker.docker_compose_v2:
    project_src: "{{ dkron_dir }}"
    state: restarted    # antes: state: present + restarted: true
```

**Por qué importa:** cuando migres de `docker_compose` v1 a v2 (recomendado, soporta Compose v2 nativo), revisa todos los parámetros. La docs oficial lista los soportados: `present`, `absent`, `stopped`, `restarted`.
