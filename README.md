# Redmine Mail Image Links

[![Tests](https://github.com/GITHUB_OWNER/redmine_mail_image_links/actions/workflows/test.yml/badge.svg)](https://github.com/GITHUB_OWNER/redmine_mail_image_links/actions/workflows/test.yml)

A small Redmine plugin that **replaces inline images in HTML notification emails with a link** to the image.

Large screenshots pasted into issues and comments make Redmine notification emails hard to read. With this plugin, every image in the HTML part of an outgoing email is replaced by a short link such as **[Open image]**. All other formatting (tables, code, links) is kept as it is.

*Deutsch: siehe [README.de.md](README.de.md).*

## Features

- `<img>` → `<a href="…">[Open image]</a>`
- Thumbnails (`{{thumbnail(...)}}`) and linked images keep their existing link to the attachment. Only the image is replaced by the label.
- Images that cannot be opened from a mail client (`cid:`, `data:`, relative paths) are replaced by the label only.
- Configurable link text (*Administration → Plugins → Configure*). When left empty, the default text in Redmine's default language is used (`[Open image]`, `[Bild öffnen]`).
- Affects all outgoing emails, including mailers of other plugins. The plain-text part is not changed.
- No database migration and no extra gems.

## Compatibility

| Redmine | Status |
|---------|--------|
| 7.0.x   | ✅ tested in CI |
| 6.1.x   | ✅ tested in CI |
| 6.0.x   | ✅ tested in CI |
| ≤ 5.x   | ❌ not supported |

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/GITHUB_OWNER/redmine_mail_image_links.git
# restart Redmine
```

The plugin needs no migration. After a restart it shows up under *Administration → Plugins*.

### Docker / Kubernetes

With the official `redmine` image, the plugin lives in `/usr/src/redmine/plugins/redmine_mail_image_links`.

**Custom image:**

```dockerfile
FROM redmine:7
RUN git clone --depth 1 --branch v1.0.0 \
      https://github.com/GITHUB_OWNER/redmine_mail_image_links.git \
      /usr/src/redmine/plugins/redmine_mail_image_links
```

**Kubernetes, without building an image:** clone the repository in an init container into an `emptyDir` volume and mount that volume at `/usr/src/redmine/plugins/redmine_mail_image_links` in the Redmine container. A sample manifest is in [`examples/kubernetes.yaml`](examples/kubernetes.yaml).

## Uninstall

Remove the `plugins/redmine_mail_image_links` directory and restart Redmine.

## Development

```bash
# Filter tests without Redmine
STANDALONE=1 ruby -Itest test/unit/html_filter_test.rb

# Full tests inside a Redmine checkout
bin/rails redmine:plugins:test NAME=redmine_mail_image_links RAILS_ENV=test
```

## License

GNU General Public License v2.0 or later, the same license as Redmine. See [LICENSE](LICENSE).
