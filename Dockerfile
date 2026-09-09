# This will be set by the GitHub action to the folder containing this component.
ARG FOLDER=/app

FROM node:24-slim AS base

# Enable corepack
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable

# Setup PNPM
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
ENV CI=true
ENV PNPM_CONFIG_MINIMUM_RELEASE_AGE=0
ENV PNPM_CONFIG_STRICT_DEP_BUILDS=false

COPY --from=oven/bun:1.3.11 /usr/local/bin/bun /usr/local/bin/bun

# Install dependencies only when needed
FROM base AS deps
ARG FOLDER

COPY . /app
WORKDIR ${FOLDER}

# Install dependencies based on the preferred package manager
RUN \
  if [ -f bun.lockb ] || [ -f bun.lock ]; then bun install --frozen-lockfile || bun install; \
  elif [ -f yarn.lock ]; then yarn install --frozen-lockfile || yarn install; \
  elif [ -f package-lock.json ]; then npm ci || npm i; \
  elif [ -f pnpm-lock.yaml ]; then pnpm i --frozen-lockfile || pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Rebuild the source code only when needed
FROM base AS builder
ARG FOLDER
COPY . /app
WORKDIR ${FOLDER}
COPY --from=deps ${FOLDER}/node_modules ./node_modules

RUN \
  if [ -f bun.lockb ] || [ -f bun.lock ]; then bun run build; \
  elif [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

FROM base AS runner
ARG FOLDER
COPY --from=builder --chown=1000:1000 ${FOLDER}/node_modules ${FOLDER}/node_modules
COPY --from=builder --chown=1000:1000 ${FOLDER}/.output ${FOLDER}/.output
COPY --from=builder --chown=1000:1000 ${FOLDER}/package.json ${FOLDER}/package.json

WORKDIR ${FOLDER}

ENV NODE_ENV=production

USER 1000:1000

EXPOSE 5173
ENV PORT=5173

CMD ["npm", "start"]
