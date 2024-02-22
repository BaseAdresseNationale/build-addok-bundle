## BUILD-ADDOK-BUNDLE

[Lire la version anglais README.md](README.md)

### Description

Ce service est utilisé pour générer le bundle Addok pour la France. Il télécharge les données d'entrée à partir d'un bucket S3, génère le bundle et le téléverse sur S3 au même chemin/répertoire.

### Installation

#### Prérequis

- Docker
- Docker-compose

#### Déploiement (Mode développement)

1. Clonez ce dépôt.
2. Copiez le fichier `.env.sample` et renseignez les valeurs des variables d'environnement.
3. Lancez les conteneurs Docker :

```bash
docker-compose up --build -d
```

Cette commande déploiera 3 conteneurs :

- conteneur build-addok-bundle : Le conteneur principal où tout le traitement du bundle se déroule.
- conteneur minio : utilisé pour simuler un service S3 localement. Pour accéder à l'interface, rendez-vous sur http://localhost:9001. Si vous avez modifié la variable d'environnement MINIO_FRONT_PORT, modifier l'URL en conséquence (par exemple, http://localhost:${MINIO_FRONT_PORT}).
- conteneur minio-init : utilisé pour préparer le minio avec des données. Il crée un bucket avec le nom spécifié dans la variable d'environnement ${S3_BUCKET} et téléverse un fichier de données d'entrée à l'emplacement spécifié dans ${S3_ADDOK_PATH}. Ce fichier sera ensuite utilisé par le conteneur build-addok-bundle comme fichier d'entrée principal pour créer le bundle.

Les conteneurs démarrent automatiquement dans un ordre spécifique :

- Tout d'abord, le conteneur minio démarre.
- Lorsque le service minio est opérationnel, le conteneur minio-init démarre, effectue son processus et s'arrête.
- Enfin, lorsque le conteneur minio-init s'arrête, le conteneur build-addok-bundle démarre, effectue son processus et s'arrête.

## License
Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.