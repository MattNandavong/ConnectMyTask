// middleware/gcsUpload.js
const { Storage } = require('@google-cloud/storage');
const multer = require('multer');
const path = require('path');
const storage = new Storage({ keyFilename: path.join(__dirname, '../gcs-key.json') });
const bucket = storage.bucket('cmt-bucket-1');

const multerStorage = multer.memoryStorage();
const upload = multer({ storage: multerStorage });

const uploadToGCS = async (fileBuffer, filename) => {
  const blob = bucket.file(`chat-images/${filename}`);
  const blobStream = blob.createWriteStream({
    resumable: false,
    contentType: 'image/jpeg',
  });

  blobStream.end(fileBuffer);
  
  return new Promise((resolve, reject) => {
    blobStream.on('finish', async () => {
      try {
        // Generate a signed URL
        const [url] = await blob.getSignedUrl({
          version: 'v4',
          action: 'read',
          expires: Date.now() + 60 * 60 * 1000, // 1 hour
        });
        resolve(url);
      } catch (err) {
        reject(err);
      }
    });

    blobStream.on('error', reject);
  });
};

module.exports = { upload, uploadToGCS };
