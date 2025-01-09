# Basis-Image
FROM debian:latest

# Aktualisierung der Paketliste und Installation von notwendigen Tools
RUN apt-get update && \
    apt-get install -y \
    bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Festlegen des Arbeitsverzeichnisses
WORKDIR /app

# Skript erstellen, das beim Start alle Environment-Variablen ausgibt
RUN echo -e "#!/bin/bash\nprintenv" > /app/start.sh && \
    chmod +x /app/start.sh

# Festlegen des Startbefehls
CMD ["/app/start.sh"]