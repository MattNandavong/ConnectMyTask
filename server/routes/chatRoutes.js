const express = require('express');
const router = express.Router();
const ChatMessage = require('../models/ChatMessage');
const Task = require('../models/Task');
const User = require('../models/User');

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

/// Summary for Messages Screen
router.get('/summary/:userId', async (req, res) => {
  const userId = req.params.userId.trim(); // Ensure clean input

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

/// 🛠️ Helper
async function getTaskIdsByUser(userId) {
  const cleanId = userId.trim();
  const tasks = await Task.find({
    $or: [{ user: cleanId }, { assignedProvider: cleanId }]
  }).select('_id');
  return tasks.map(t => t._id);
}

module.exports = router;
