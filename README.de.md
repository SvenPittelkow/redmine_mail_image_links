# Redmine Mail Image Links

Ein kleines Redmine-Plugin, das **Bilder in HTML-Benachrichtigungsmails durch einen Link** auf das Bild ersetzt.

Große Screenshots in Tickets und Kommentaren machen Redmine-Benachrichtigungen schwer lesbar. Mit diesem Plugin wird jedes Bild im HTML-Teil einer ausgehenden Mail durch einen kurzen Link wie **[Bild öffnen]** ersetzt. Die restliche Formatierung (Tabellen, Code, Links) bleibt erhalten.

## Funktionen

- `<img>` → `<a href="…">[Bild öffnen]</a>`
- Thumbnails (`{{thumbnail(...)}}`) und verlinkte Bilder behalten ihren Link auf den Anhang. Nur das Bild wird durch den Linktext ersetzt.
- Bilder, die ein Mailprogramm nicht öffnen kann (`cid:`, `data:`, relative Pfade), werden nur durch den Text ersetzt.
- Der Linktext ist einstellbar (*Administration → Plugins → Konfigurieren*). Bleibt das Feld leer, wird der Standardtext in der Standardsprache von Redmine verwendet.
- Wirkt auf alle ausgehenden Mails, auch auf Mails anderer Plugins. Der Nur-Text-Teil bleibt unverändert.
- Keine Migration und keine zusätzlichen Gems.

## Kompatibilität

Redmine 6.0, 6.1 und 7.0. Alle drei Versionen werden in der CI getestet.

## Installation

```bash
cd /pfad/zu/redmine/plugins
git clone https://github.com/GITHUB_OWNER/redmine_mail_image_links.git
# Redmine neu starten
```

Für Docker und Kubernetes siehe die englische [README.md](README.md#docker--kubernetes) und [`examples/kubernetes.yaml`](examples/kubernetes.yaml).

## Lizenz

GNU GPL v2 oder neuer, wie Redmine selbst.
