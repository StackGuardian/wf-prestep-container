# Basis-Image
FROM debian:latest

# Aktualisierung der Paketliste und Installation von notwendigen Tools
RUN apt-get update && \
    apt-get install -y \
    bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Festlegen des Startbefehls
CMD ["printenv"]