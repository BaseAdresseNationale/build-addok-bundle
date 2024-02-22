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
    apt-get install -y redis-tools zip unzip

COPY --from=redis /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=build /root/.local /root/.local

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

COPY build-addok-bundle.sh /usr/local/bin/build-addok-bundle.sh
RUN chmod +x /usr/local/bin/build-addok-bundle.sh

COPY config config
ENV ADDOK_CONFIG_MODULE=config/addok.conf

RUN mkdir -p data dist

ENV PATH=/root/.local/bin:$PATH

CMD ["start.sh"]