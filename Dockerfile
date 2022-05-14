# FROM node:lts as dependencies
# WORKDIR /learn-d
# COPY package.json yarn.lock ./
# RUN yarn install --frozen-lockfile

# FROM node:lts as builder
# WORKDIR /learn-d
# COPY . .
# COPY --from=dependencies /learn-d/node_modules ./node_modules
# RUN yarn build

# FROM node:lts as runner
# WORKDIR /learn-d
# ENV NODE_ENV production

# COPY --from=builder /learn-d/public ./public
# COPY --from=builder /learn-d/package.json ./package.json
# COPY --from=builder /learn-d/.next ./.next
# COPY --from=builder /learn-d/node_modules ./node_modules

# EXPOSE 3000
# CMD ["yarn", "start"]

# Install dependencies only when needed
FROM node:lts-alpine AS deps
WORKDIR /learn-d
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:lts-alpine AS builder
ENV NODE_ENV=production
WORKDIR /learn-d
COPY . .
COPY --from=deps /learn-d/node_modules ./node_modules
RUN yarn build


FROM node:lts-alpine AS runner
ARG X_TAG
WORKDIR /learn-d
ENV NODE_ENV=production
COPY --from=builder /learn-d/next.config.js ./
COPY --from=builder /learn-d/public ./public
COPY --from=builder /learn-d/.next ./.next
COPY --from=builder /learn-d/node_modules ./node_modules
CMD ["node_modules/.bin/next", "start"]