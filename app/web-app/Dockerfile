# Utiliser une image Python légère
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier le code
COPY . /app

# Installer les dépendances (Flask)
RUN pip install Flask

# Exposer le port par défaut de l'application
EXPOSE 5000

# Commande de démarrage
CMD ["python3", "index.html"]