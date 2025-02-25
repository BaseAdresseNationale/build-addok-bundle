# Stage 1
FROM python:3.10-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y build-essential gcc
COPY requirements.txt ./
RUN pip install --user -r requirements.txt

# Stage 2
FROM redis:7.0 AS redis

# Stage 3
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y redis-tools zip unzip curl

# Create user and group with UID/GID 1000
RUN groupadd -g 1000 appgroup && useradd -u 1000 -g appgroup -s /bin/sh -m appuser

# Copy Redis from stage 2
COPY --from=redis /usr/local/bin/redis-server /usr/local/bin/redis-server

# Install AWS CLI for all users
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Copy Python packages to appuser's home directory instead of root
COPY --from=build /root/.local /home/appuser/.local
RUN chown -R appuser:appgroup /home/appuser/.local

# Copy scripts
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
COPY build-addok-bundle.sh /usr/local/bin/build-addok-bundle.sh
RUN chmod +x /usr/local/bin/build-addok-bundle.sh

# Copy config
COPY config config
ENV ADDOK_CONFIG_MODULE=config/addok.conf

# Create directories with proper permissions
RUN mkdir -p data dist && chown -R appuser:appgroup data dist /app

# Set environment variables
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to appuser
USER appuser

CMD ["start.sh"]