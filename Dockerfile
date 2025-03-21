# Basis-Image
FROM debian:12-slim

# Aktualisierung der Paketliste und Installation von notwendigen Tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bash jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY scripts/*.sh /app
RUN chmod +x /app/*.sh
CMD [ "/app/sleep.sh" ]
