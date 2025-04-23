const express = require('express');
const { Storage } = require('@google-cloud/storage');
const path = require('path');
// const upload = require('../middlewares/gcsUpload');

const ChatMessage = require('../models/ChatMessage');
const Task = require('../models/Task');
const User = require('../models/User');
const { upload, uploadToGCS } = require('../middlewares/gcsUpload');


const router = express.Router();

const storage = new Storage({
  keyFilename: path.join(__dirname, '../gcs-key.json'),
});
const bucket = storage.bucket('cmt-bucket-1');

console.log("📡 Chat routes loaded");

/// Get chat history by task ID
router.get('/:taskId', async (req, res) => {
  try {
    const messages = await ChatMessage.find({ taskId: req.params.taskId.trim() })
      .sort('timestamp')
      .populate('sender', 'name');

    res.json(messages);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

/// ✅ 2. Chat summary for message list
router.get('/summary/:userId', async (req, res) => {
  const userId = req.params.userId.trim();

  try {
    const messages = await ChatMessage.aggregate([
      {
        $match: {
          $or: [
            { 'sender._id': userId },
            { taskId: { $in: await getTaskIdsByUser(userId) } }
          ]
        }
      },
      { $sort: { timestamp: -1 } },
      {
        $group: {
          _id: '$taskId',
          lastMessage: { $first: '$text' },
          timestamp: { $first: '$timestamp' },
          sender: { $first: '$sender' },
        }
      },
    ]);

    const results = await Promise.all(messages.map(async (msg) => {
      const task = await Task.findById(msg._id).populate('user assignedProvider');
      if (!task) return null;

      const otherUser =
        task.user._id.toString() === userId
          ? task.assignedProvider
          : task.user;

      return {
        taskId: task._id,
        userId: otherUser?._id || '',
        userName: otherUser?.name || 'Unknown',
        lastMessage: msg.lastMessage,
        timestamp: msg.timestamp,
      };
    }));

    res.json(results.filter(r => r !== null));
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Failed to load chat summary' });
  }
});


/// ✅ 3. Image upload route for chat
router.post('/send-image', upload.single('image'), async (req, res) => {
  const { taskId, userId, caption } = req.body;

  try {
    const filename = `${Date.now()}-${req.file.originalname}`;
    const publicUrl = await uploadToGCS(req.file.buffer, filename);
    console.log('✅ Image uploaded to GCS:', publicUrl);

    const message = await ChatMessage.create({
      taskId,
      sender: userId,
      image: publicUrl,
      text: caption || '[Image]',
      timestamp: new Date(),
    });
    console.log("📨 Created DB message:", message);

    const io = req.app.get('io');
    console.log('💬 Emitting chat image message to room:', taskId);
    console.log({
      text: message.text,
      image: message.image,
      timestamp: message.timestamp,
    });

    io.to(taskId).emit('receiveMessage', {
      sender: { _id: userId },
      text: message.text,
      image: message.image,
      timestamp: message.timestamp,
    });

    res.status(200).json({
      sender: { _id: userId },
      text: message.text,
      image: message.image,
      timestamp: message.timestamp,
    });

  } catch (err) {
    console.error('❌ Upload or DB error:', err);
    res.status(500).send('Server error');
  }
});



/// 🔧 Helper: Get all tasks user is part of
async function getTaskIdsByUser(userId) {
  const cleanId = userId.trim();
  const tasks = await Task.find({
    $or: [{ user: cleanId }, { assignedProvider: cleanId }]
  }).select('_id');
  return tasks.map(t => t._id);
}

module.exports = router;
