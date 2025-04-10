ARG tool
# Basis-Image
FROM mmalzahn/wfs-master:latest
WORKDIR /app

COPY ${tool}/script.sh /app/script.sh
RUN chmod +x /app/script.sh
CMD [ "/app/script.sh" ]
