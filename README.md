# Ark VCS Homebrew Tap and Docker Image

> [!IMPORTANT]
> This is an **unofficial** tap and image. It is not affiliated with or endorsed by the Ark VCS developers.
> Ark VCS is made by STARY DONKEY UNIPESSOAL LDA. Visit the official website: https://www.ark-vcs.com

Ark is downloaded directly from the [official download page](https://www.ark-vcs.com/download.html) and is checked daily for new versions.

## Homebrew

Requires [Homebrew](https://brew.sh).

```sh
brew tap tsukinoko-kun/ark-vcs https://github.com/tsukinoko-kun/ark-vcs
```

macOS (installs `Ark-Vcs.app` to `/Applications` and `ark` to your PATH):

```sh
brew install --cask ark-vcs
```

Linux (x86_64):

```sh
brew install ark-vcs
```

Run `ark` to open the client, or `ark help` for the CLI.

Update with `brew upgrade ark-vcs`, uninstall with `brew uninstall ark-vcs`.

## Docker (server)

`ghcr.io/tsukinoko-kun/ark-vcs` runs the Ark server for Linux (x86_64) and Windows (Server 2025). Tags: `latest`, `<version>` (e.g. `1.1.3`), and `<version>-linux` / `<version>-windows`.

Server data (repositories, config, SSL key and certificate, logs) is stored in `/data` (`C:\data` on Windows). Mount a volume there or you lose it with the container. Clients connect on port `9000`.

```sh
docker run -d --name ark-server --restart unless-stopped -p 9000:9000 -v ark-data:/data ghcr.io/tsukinoko-kun/ark-vcs:1.1.3
```

Docker Compose:

```yaml
services:
  ark-server:
    image: ghcr.io/tsukinoko-kun/ark-vcs:1.1.3
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - ark-data:/data

volumes:
  ark-data:
```

To use a host directory instead of a named volume, make it writable by UID `65532`, or run the container as its owner with `user: "1000:1000"` (`--user 1000:1000`).

To pass server flags, override the command, e.g. to change the log level:

```sh
docker run ... ghcr.io/tsukinoko-kun/ark-vcs:1.1.3 server -path /data -log_level warning
```

Run `docker run --rm ghcr.io/tsukinoko-kun/ark-vcs server` to list all flags.

Pin a version tag instead of `latest`. Back up `/data` before you change it. If a new version upgrades the data format, the server refuses to start until you add `-allow_dv_upgrade true`, and that upgrade cannot be reversed.

On Windows:

```powershell
docker run -d --name ark-server --restart unless-stopped -p 9000:9000 -v C:\ark-data:C:\data ghcr.io/tsukinoko-kun/ark-vcs:1.1.3
```

## License

Ark VCS is proprietary software. Its End User License Agreement (`eula.txt`) is included in every [official download](https://www.ark-vcs.com/download.html). Licensing details: https://www.ark-vcs.com/pricing.html
