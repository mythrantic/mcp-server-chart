FROM node:20

WORKDIR /app

# Install system dependencies for canvas
RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy 
COPY . /app/
WORKDIR /app/
RUN npm install && npm rebuild canvas && npm run build

# Create startup script
WORKDIR /app

ENV VIS_DOMAIN="https://mcp-server-chart-vis.valiantlynx.com"

EXPOSE 3000

CMD ["node", "server.js"]