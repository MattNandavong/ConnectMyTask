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
        await blob.makePublic();
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
        resolve(publicUrl);
      });
      
    blobStream.on('error', reject);
  });
};

module.exports = { upload, uploadToGCS };
