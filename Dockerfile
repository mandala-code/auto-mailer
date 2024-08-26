FROM node:22-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN \
  if [ -f package-lock.json ]; then \
    npm ci; \
  else \
    echo "no package-lock.json found" && exit 1; \
  fi

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build; \  
  npm prune --production;

FROM base AS release
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules

CMD HOST="0.0.0.0" node dist/main.js