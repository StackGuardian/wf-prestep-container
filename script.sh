#!/bin/bash

# Verzeichnis, dessen Inhalt angezeigt werden soll
directory="."

# Überprüfen, ob das Verzeichnis existiert
if [ -d "$directory" ]; then
    echo "Inhalt des Verzeichnisses $directory:"
    ls -la "$directory"
else
    echo "Das Verzeichnis $directory existiert nicht."
fi