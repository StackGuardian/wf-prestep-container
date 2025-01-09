# Basis-Image
FROM debian:latest

# Aktualisierung der Paketliste und Installation von notwendigen Tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bash jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    WORKDIR /app
    COPY script.sh /app/start.sh
    RUN chmod +x /app/start.sh
    CMD [ "/app/start.sh" ]
# Festlegen des Startbefehls
#CMD ["ls -l"]
