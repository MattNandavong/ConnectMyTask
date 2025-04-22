// routes/reviewRoutes.js
const express = require('express');
const router = express.Router();
const Task = require('../models/Task');
const User = require('../models/User');

// GET /api/reviews/:providerId
router.get('/:providerId', async (req, res) => {
  try {
    const tasks = await Task.find({
      assignedProvider: req.params.providerId,
      status: 'Completed',
      review: { $exists: true }
    }).populate('user', 'name profilePhoto');

    const reviews = tasks.map(task => ({
      rating: task.review.rating,
      comment: task.review.comment,
      reviewer: task.user.name,
      photo: task.user.profilePhoto,
      date: task.updatedAt,
    }));

    res.json(reviews);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Failed to fetch reviews' });
  }
});

module.exports = router;
