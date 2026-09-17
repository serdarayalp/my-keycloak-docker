# Keycloak Docker Entwicklungsumgebung

Dieses Projekt stellt eine vollständig vorkonfigurierte, containerbasierte Entwicklungsumgebung für **Keycloak** bereit. Es beinhaltet benutzerdefinierte Themes (Login- und E-Mail-Templates), eine eigene Service-Provider-Schnittstelle (SPI) zur Ereignisverarbeitung sowie Hilfsdienste wie eine PostgreSQL-Datenbank und einen lokalen E-Mail-Testserver (MailDev).

---

## 1. Übersicht & Architektur

Die Umgebung wird über Docker Compose gesteuert und umfasst drei integrierte Dienste:

```
                  +-----------------------------------+
                  |           Host-System             |
                  +-----------------------------------+
                     |              |              |
          Port 8080  |   Port 1080  |   Port 5432  |
                     v              v              v
        +------------------+ +-------------+ +------------------+
        | keycloak_server  | | keycloak_   | | keycloak_        |
        | (Keycloak 24+)   | | maildev     | | postgres (v16)   |
        |                  | | (MailDev)   | |                  |
        | - Themes Mount   | +-------------+ +------------------+
        | - SPI Jar Mount  |        ^                 ^
        +------------------+        |                 |
                 |                  | (SMTP: 1025)    | (JDBC: 5432)
                 +------------------+-----------------+
```

### Dienste & Schnittstellen

| Dienst | Container-Name | Image | Host-Port | Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| **Keycloak** | `keycloak_server` | `quay.io/keycloak/keycloak:latest` | `8080` | Identity- & Access-Management Server |
| **PostgreSQL** | `keycloak_postgres` | `postgres:16` | `5432` | Relationale Datenbank für Keycloak-Daten |
| **MailDev** | `keycloak_maildev` | `maildev/maildev:latest` | `1080` (Web)<br>`1025` (SMTP) | Lokaler SMTP-Server & Webmailer zum Testen |

---

## 2. Docker Compose Konfiguration (`docker-compose.yml`)

Die Datei `docker-compose.yml` orchestriert das Zusammenspiel der Container und optimiert die Konfiguration für die lokale Entwicklung:

### Keycloak (`keycloak_server`)
- **Startmodus (`start-dev`):** Startet Keycloak im Entwicklungsmodus (HTTP aktiviert, vereinfachte Sicherheitsanforderungen für lokale Tests).
- **Theme-Hot-Reloading:** Über die Flags `--spi-theme-cache-themes=false` und `--spi-theme-cache-templates=false` wird das Caching von Themes und FreeMarker-Templates deaktiviert. Änderungen an CSS, JS oder `.ftl`-Dateien sind nach einem Browser-Reload sofort sichtbar, ohne dass der Container neu gestartet werden muss.
- **Mounts:**
  - `./themes:/opt/keycloak/themes`: Stellt das benutzerdefinierte Theme `mytheme` direkt im Container bereit.
  - `./spis/my-keycloak-password-change-listener-1.0.0.jar:/opt/keycloak/providers/...`: Bindet das SPI-Erweiterungsarchiv direkt in das Providers-Verzeichnis ein.
- **Zugangsdaten & Umgebungsvariablen:**
  - `KEYCLOAK_ADMIN`: `admin`
  - `KEYCLOAK_ADMIN_PASSWORD`: `admin`
  - `KC_DB`: `postgres`
  - `KC_DB_URL`: `jdbc:postgresql://postgres:5432/keycloak`
  - `KC_DB_USERNAME`: `keycloak`
  - `KC_DB_PASSWORD`: `keycloak_password`

### PostgreSQL (`keycloak_postgres`)
- **Version:** PostgreSQL 16.
- **Persistenz:** Nutzt das Named Volume `postgres_data`, gemountet auf `/var/lib/postgresql/data`, damit Realm- und Benutzerkonfigurationen Container-Neustarts überdauern.
- **Port:** `5432` ist auf dem Host freigegeben (ermöglicht die Inspektion mit DB-Tools wie DBeaver/DataGrip).

### MailDev (`keycloak_maildev`)
- **SMTP Server:** Erreichbar intern unter `maildev:1025` (bzw. auf dem Host unter `localhost:1025`).
- **Web-Interface:** Erreichbar im Browser unter [http://localhost:1080](http://localhost:1080).
- **Nutzen:** Fängt alle von Keycloak generierten E-Mails (z. B. Passwort-Reset, E-Mail-Bestätigung) lokal ab, sodass kein echter SMTP-Server erforderlich ist.

---

## 3. Custom Themes (`themes/`)

Unter `themes/mytheme` befindet sich ein angepasstes Keycloak-Theme, aufgeteilt in drei Kernbereiche:

```
themes/mytheme/
├── common/             # Gemeinsam genutzte Ressourcen & Basisdefinitionen
│   ├── resources/
│   │   ├── css/        # Bootstrap CSS & allgemeine Styles
│   │   └── js/         # Bootstrap JS Bundle & allgemeine Skripte
│   └── theme.properties
├── login/              # Login-, Registrierungs- und Auth-Flow-Seiten
│   ├── messages/       # Lokalisierung (messages_de.properties)
│   ├── resources/      # Login-spezifisches CSS und Bilder/Logos
│   ├── footer.ftl      # Benutzerdefinierter Footer-Baustein
│   ├── info.ftl        # Informations- und Hinweisseiten
│   ├── login.ftl       # Angepasste Login-Maske (Passwort-Sichtbarkeit, Social Login etc.)
│   ├── template.ftl    # Hauptlayout (Header "Mein Keycloak", Sprachauswahl, Alerts)
│   └── theme.properties
└── email/              # HTML- und Text-E-Mail-Vorlagen
    ├── html/           # HTML-Templates für alle Auth- und Benachrichtigungsereignisse
    ├── text/           # Plaintext-Templates für alle Ereignisse
    ├── messages/       # Deutsche Übersetzungen für E-Mail-Betreff & -Texte
    └── theme.properties
```

### Module im Detail

#### A. Common (`themes/mytheme/common`)
- **Eigenschaften (`theme.properties`):** Erbt von `keycloak` (`parent=keycloak`) und importiert `common/keycloak`.
- **Ressourcen:** Enthält Standard-Bibliotheken wie **Bootstrap 5** (`bootstrap.min.css`, `bootstrap.bundle.min.js`), die in den Themes wiederverwendet werden können.

#### B. Login (`themes/mytheme/login`)
- **Vererbung & Assets (`theme.properties`):**
  - Erbt von `keycloak` (`parent=keycloak`) und importiert `common/mytheme`.
  - Bindet `css/common.css`, `css/bootstrap/bootstrap.min.css` sowie `css/login.css` ein.
  - Definiert Klassen-Mappings für PatternFly- und Formularelemente.
- **Templates (`.ftl`):**
  - `template.ftl`: Zentrales Layout mit deutschem Branding-Titel (`Mein Keycloak`), konfigurierbarer Sprachauswahl, Feedback-/Fehlermeldungsanzeige und Integration des Footers.
  - `login.ftl`: Login-Formular mit Unterstützung für E-Mail-/Benutzernamen-Login, Passwort-Sichtbarkeitsumschaltung, "Angemeldet bleiben" (Remember Me), Passwort-Vergessen-Link und Identitätsanbieter (Social Logins).
  - `info.ftl`: Benutzerhinweise und Statusmeldungen (z. B. nach Aktionen).
  - `footer.ftl`: Modularer Footer-Bereich für rechtliche Hinweise oder Links.
- **Lokalisierung (`messages/messages_de.properties`):**
  - Vollständige, präzise deutsche Übersetzung für Anmeldemasken, Fehlermeldungen, 2FA/TOTP-Einrichtung, Passkey/WebAuthn, Recovery Codes und Kontoverwaltung.

#### C. Email (`themes/mytheme/email`)
- **Vererbung (`theme.properties`):** Basiert auf `parent=base`.
- **Templates (`html/` und `text/`):**
  - E-Mail-Verifizierung (`email-verification.ftl`, `email-verification-with-code.ftl`)
  - Passwort zurücksetzen (`password-reset.ftl`)
  - Bestätigung von Passwort- und E-Mail-Änderungen (`password-updated.ftl`, `email-update-confirmation.ftl`)
  - Sicherheitsbenachrichtigungen bei Kontosperren (`event-user_disabled_by_temporary_lockout.ftl`, `event-user_disabled_by_permanent_lockout.ftl`)
  - Benachrichtigungen bei Login-Fehlern und Credential-/TOTP-Änderungen (`event-login_error.ftl`, `event-update_password.ftl`, `event-update_totp.ftl`, `event-remove_totp.ftl` etc.)
  - Einladungen zu Organisationen (`org-invite.ftl`) und Identitätsanbieter-Verknüpfung (`identity-provider-link.ftl`)
- **Lokalisierung (`messages/messages_de.properties`):**
  - Deutsche Übersetzungen für Betreffzeilen und Vorlagentexte.

---

## 4. Service Provider Interfaces / Extensions (`spis/`)

Das Verzeichnis `spis/` enthält benutzerdefinierte Java-Erweiterungen für Keycloak.

### `my-keycloak-password-change-listener-1.0.0.jar`
- **Typ:** Keycloak Event Listener SPI (`org.keycloak.events.EventListenerProvider` / `EventListenerProviderFactory`).
- **Klassen:**
  - `de.mydomain.PasswordChangeListenerFactory`: Registriert den Provider in Keycloak.
  - `de.mydomain.PasswordChangeListener`: Horcht auf Benutzer- und Admin-Ereignisse (`Event` und `AdminEvent`).
- **Funktion:** Reagiert auf Passwortänderungen und sicherheitsrelevante Ereignisse im Keycloak-Lifecycle, um benutzerdefinierte Logik (z. B. Audit-Logging, externe Benachrichtigungen oder Synchronisation) auszuführen.
- **Bereitstellung:** Wird über die `docker-compose.yml` automatisch nach `/opt/keycloak/providers/my-keycloak-password-change-listener-1.0.0.jar` gemountet.

---

## 5. Schnelleinstieg & Betrieb

### Voraussetzungen
- Docker und Docker Compose installiert.

### 1. Umgebung starten
```bash
docker compose up -d
```

### 2. Zugriff auf die Web-Oberflächen
- **Keycloak Admin Console:** [http://localhost:8080](http://localhost:8080)
  - Benutzer: `admin`
  - Passwort: `admin`
- **MailDev Web-Interface:** [http://localhost:1080](http://localhost:1080)
- **PostgreSQL:** `localhost:5432` (User: `keycloak`, DB: `keycloak`, Passwort: `keycloak_password`)

### 3. Theme in Keycloak aktivieren
1. In der Keycloak Admin Console anmelden.
2. Den gewünschten Realm auswählen (oder im Realm `master` bleiben).
3. Unter **Realm Settings** > Reiter **Themes**:
   - **Login theme:** `mytheme`
   - **Email theme:** `mytheme`
4. Speichern anklicken.

### 4. MailDev als SMTP-Server in Keycloak einrichten
1. Unter **Realm Settings** > Reiter **Email**:
   - **Host:** `maildev`
   - **Port:** `1025`
   - **From:** `noreply@keycloak.local`
   - **Authentication:** `OFF`
   - **SSL/TLS:** `OFF`
2. Über **Test connection** eine Test-E-Mail senden und im MailDev-Interface unter [http://localhost:1080](http://localhost:1080) überprüfen.

### 5. Event Listener SPI aktivieren
1. Unter **Realm Settings** > Reiter **Events** > Unterreiter **Event listeners**.
2. Den registrierten Listener (`my-keycloak-password-change-listener` bzw. den konfigurierten Provider-Namen) hinzufügen und speichern.

### 6. Logs einsehen & Umgebung stoppen
```bash
# Logs anzeigen
docker compose logs -f keycloak

# Umgebung stoppen
docker compose down

# Umgebung stoppen und Datenbank-Volume löschen (Reset)
docker compose down -v
```
