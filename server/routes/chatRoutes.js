const express = require('express');
const router = express.Router();
const ChatMessage = require('../models/ChatMessage');
const Task = require('../models/Task');
const User = require('../models/User');
const { upload, uploadToGCS } = require('../middlewares/gcsUpload');
console.log("📡 Chat routes loaded");




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
  try {
    const { taskId, userId, caption } = req.body;

    const imageUrl = await uploadToGCS(req.file.buffer, `${Date.now()}-${req.file.originalname}`);

    const message = await ChatMessage.create({
      taskId,
      sender: userId,
      image: imageUrl,
      text: caption || '[Image]',
      timestamp: new Date(),
    });

    res.status(200).json({
      sender: { _id: userId },
      text: message.text,
      image: message.image,
      timestamp: message.timestamp,
    });
  } catch (error) {
    console.error('❌ Image upload error:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
});

// ✅ Dummy test route - no upload logic
router.post('/dummy', (req, res) => {
  console.log("✅ Dummy route hit!");
  res.status(200).send("Dummy route reached successfully!");
});

/// ✅ 1. Get chat history by task ID
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


/// 🔧 Helper: Get all tasks user is part of
async function getTaskIdsByUser(userId) {
  const cleanId = userId.trim();
  const tasks = await Task.find({
    $or: [{ user: cleanId }, { assignedProvider: cleanId }]
  }).select('_id');
  return tasks.map(t => t._id);
}

module.exports = router;
