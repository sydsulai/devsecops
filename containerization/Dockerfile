FROM node:25 AS builder
WORKDIR /build
COPY package.json ./
RUN npm install
COPY . .

# FROM node:25-slim
# WORKDIR /app
# COPY --from=builder /build/node_modules ./node_modules
# COPY --from=builder /build/package.json ./package.json
# COPY --from=builder /build/app.js ./app.js
# RUN groupadd -r appuser && useradd -r -g appuser appuser
# RUN chown -R appuser:appuser /app
# USER appuser
# EXPOSE 3000
# CMD ["npm", "start"]

FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=builder --chown=1000:1000 /build/node_modules ./node_modules
COPY --from=builder --chown=1000:1000 /build/app.js ./app.js
USER 1000:1000
EXPOSE 3000
CMD ["app.js"]