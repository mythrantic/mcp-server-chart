const express = require('express');
const { render } = require('./dist/cjs/index.js');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.VIS_DOMAIN || `http://localhost:${PORT}`;

// Create images directory if it doesn't exist
const IMAGES_DIR = path.join(__dirname, 'images');
if (!fs.existsSync(IMAGES_DIR)) {
  fs.mkdirSync(IMAGES_DIR, { recursive: true });
}

app.use(express.json());

// Serve static images
app.use('/images', express.static(IMAGES_DIR));

// Main endpoint for MCP server chart integration
app.post('/api/gpt-vis', async (req, res) => {
  try {
    const { type, source, ...options } = req.body;
    
    console.log(`Rendering chart: type=${type}, source=${source}`);
    
    // Render the chart
    const vis = await render({ type, ...options });
    
    // Get the buffer
    const buffer = vis.toBuffer();
    
    // Clean up
    vis.destroy();
    
    // Generate unique filename using hash of content
    const hash = crypto.createHash('md5').update(buffer).digest('hex');
    const filename = `${hash}.png`;
    const filepath = path.join(IMAGES_DIR, filename);
    
    // Save image to disk if it doesn't exist
    if (!fs.existsSync(filepath)) {
      fs.writeFileSync(filepath, buffer);
      console.log(`Saved new image: ${filename}`);
    } else {
      console.log(`Image already exists: ${filename}`);
    }
    
    // Convert to base64 data URL
    const base64 = buffer.toString('base64');
    const dataUrl = `data:image/png;base64,${base64}`;
    
    // Generate URL path
    const imageUrl = `${HOST}/images/${filename}`;
    
    // Send response with both base64 data and URL
    res.json({
      success: true,
      resultObj: dataUrl,
      imageUrl: imageUrl,
      filename: filename,
      errorMessage: null
    });
  } catch (error) {
    console.error('Error rendering chart:', error);
    res.json({
      success: false,
      resultObj: null,
      imageUrl: null,
      errorMessage: error.message
    });
  }
});

// Endpoint to retrieve image by filename
app.get('/image/:filename', (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(IMAGES_DIR, filename);
  
  if (fs.existsSync(filepath)) {
    res.sendFile(filepath);
  } else {
    res.status(404).json({ error: 'Image not found' });
  }
});

// Endpoint to list all images
app.get('/api/images', (req, res) => {
  try {
    const files = fs.readdirSync(IMAGES_DIR)
      .filter(file => file.endsWith('.png'))
      .map(file => ({
        filename: file,
        url: `${HOST}/images/${file}`,
        path: `/image/${file}`
      }));
    
    res.json({ success: true, images: files });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`GPT-Vis SSR server listening on http://0.0.0.0:${PORT}`);
  console.log(`Endpoint: http://0.0.0.0:${PORT}/api/gpt-vis`);
  console.log(`Image serving: http://0.0.0.0:${PORT}/images/`);
  console.log(`Images directory: ${IMAGES_DIR}`);
});