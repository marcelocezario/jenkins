FROM jenkins/jenkins:lts-jdk21

# Instalar Docker CLI e Compose Plugin
USER root
RUN apt-get update && \
    apt-get install -y \
    docker.io && \
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh --skip-daemon-start && \
    rm -rf /var/lib/apt/lists/* get-docker.sh

# Permitir que o usuário Jenkins acesse o Docker CLI
RUN if ! getent group docker; then groupadd -g 999 docker; fi && \
    usermod -aG docker jenkins

USER jenkins
