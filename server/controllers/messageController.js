// const Message = require("../models/Message");
const mongoose = require('mongoose');
const Task = require('../models/Task');
const Message = require('../models/Message');
const User = require('../models/User');

const createMessage = async (req, res) => {
  const { text, receiverId } = req.body;
  const { taskId } = req.params;
  const io = req.app.get('io'); // get the socket server instance

  try {
    const message = new Message({
      taskId,
      sender: req.user.id,
      receiver: receiverId,
      text: text || '[Image]',
      image: req.file?.path || null,
    });
    console.log("Message created:", message);

    await message.save();

    // Emit the message via WebSocket to the task room
    if (io) {
      io.to(taskId).emit('receiveMessage', {
        sender: { _id: message.sender },
        receiver: message.receiver,
        text: message.text,
        image: message.image,
        timestamp: message.timestamp,
      });
      console.log("📢 Emitted message to room:", taskId);
    }

    res.status(201).json(message);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

const getMessages = async (req, res) => {
  const { taskId } = req.params;

  try {
    const messages = await Message.find({ taskId })
      .populate("sender", "name profilePhoto")
      .sort({ timestamp: 1 });
    res.json(messages);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

const getChatSummary = async (req, res) => {
    const userId = req.params.userId;
  
    try {
      // Step 1: Find tasks where user is poster or assignedProvider
      const tasks = await Task.find({
        $or: [
          { user: userId },
          { assignedProvider: userId }
        ]
      }).select('_id title user assignedProvider');
  
      const taskIds = tasks.map(task => task._id);
  
      // Step 2: Find messages related to those tasks
      const messages = await Message.aggregate([
        { $match: { taskId: { $in: taskIds } } },
        { $sort: { timestamp: -1 } },
        {
          $group: {
            _id: "$taskId",
            lastMessage: { $first: "$text" },
            lastImage: { $first: "$image" },
            lastTimestamp: { $first: "$timestamp" },
            sender: { $first: "$sender" },
            receiver: { $first: "$receiver" }
          }
        }
      ]);
  
      // Step 3: Build chat summaries only for tasks with messages
      const chats = await Promise.all(messages.map(async (msg) => {
        const task = tasks.find(t => t._id.toString() === msg._id.toString());
        if (!task) return null; // Skip if no corresponding task (should not happen)
  
        let partnerId;
        if (task.user.toString() === userId) {
          partnerId = task.assignedProvider;
        } else {
          partnerId = task.user;
        }
  
        const partner = await User.findById(partnerId).select('name profilePhoto');
  
        return {
          taskId: task._id,
          taskTitle: task.title,
          lastMessage: msg.lastMessage || '[Image]',
          lastImage: msg.lastImage || null,
          lastTimestamp: msg.lastTimestamp,
          partnerName: partner ? partner.name : "Unknown",
          partnerProfilePhoto: partner?.profilePhoto || null,
        };
      }));
  
      // Step 4: Filter out any nulls (if missing tasks/users)
      const validChats = chats.filter(chat => chat !== null);
  
      // Step 5: Sort newest first
      validChats.sort((a, b) => new Date(b.lastTimestamp) - new Date(a.lastTimestamp));
  
      console.log('✅ Chat summary prepared:', validChats.length, 'chats.');
      res.json(validChats);
  
    } catch (err) {
      console.error('❌ Error getting chat summary:', err);
      res.status(500).send("Server Error");
    }
  };
  
  
  
  
  
module.exports = { createMessage, getMessages, getChatSummary };
