const express = require('express');
const router = express.Router();
const ChatMessage = require('../models/ChatMessage');

router.get('/:taskId', async (req, res) => {
  try {
    const messages = await ChatMessage.find({ taskId: req.params.taskId })
      .sort('timestamp')
      .populate('sender', 'name');

    res.json(messages);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
