FROM node:24-alpine

ENV REPO_URL=https://github.com/langchain-ai/open-swe.git
ENV CLONE_DIR=/open-swe
ENV OPENSWE_DIR=${CLONE_DIR}/apps/open-swe
ENV WEB_DIR=${CLONE_DIR}/apps/web

RUN apk update && \
    apk add --no-cache bash git && \
    git clone "$REPO_URL" "$CLONE_DIR" && \
    cd "$CLONE_DIR" && \
    corepack enable && \
    corepack prepare yarn@3.5.1 --activate && \
    yarn install

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
