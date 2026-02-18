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

# Copy gpt-vis-ssr
COPY gpt-vis-ssr /app/gpt-vis-ssr
WORKDIR /app/gpt-vis-ssr
RUN npm install && npm rebuild canvas && npm run build

# Copy mcp-server-chart
COPY mcp-server-chart /app/mcp-server-chart
WORKDIR /app/mcp-server-chart
RUN npm install && npm run build

# Create startup script
WORKDIR /app

ENV VIS_DOMAIN="https://mcp-server-chart-vis.valiantlynx.com"
RUN echo '#!/bin/bash\n\
cd /app/gpt-vis-ssr && VIS_DOMAIN=$VIS_DOMAIN node server.js &\n\
sleep 3\n\
cd /app/mcp-server-chart && VIS_REQUEST_SERVER=$VIS_DOMAIN/api/gpt-vis node build/index.js --transport streamable --host 0.0.0.0 --port 1122\n\
' > /app/start.sh && chmod +x /app/start.sh

EXPOSE 1122 3000

CMD ["bash", "/app/start.sh"]