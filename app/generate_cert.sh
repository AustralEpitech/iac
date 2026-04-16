#!/bin/bash
# Script pour générer des certificats SSL auto-signés

echo "Génération de certificats SSL auto-signés..."
openssl req -x509 -newkey rsa:4096 -nodes -out cert.pem -keyout key.pem -days 365 -subj "/CN=localhost"

echo "Certificats générés :"
echo "  - cert.pem (certificat)"
echo "  - key.pem (clé privée)"
echo ""
echo "Pour utiliser ces certificats, l'application les détectera automatiquement."

