// backend/controllers/taskController.js

const Task = require("../models/Task");
const User = require("../models/User");
const {
  sendTaskCreationEmail,
  sendBidNotificationEmail,
  sendBidAcceptedEmail,
  sendTaskCompletionEmail,
} = require("../utils/mail");
//chat model
const Chat = require("../models/Message.js")
const { calculateProviderRank } = require('../services/rankingService');


// Create a new task
const createTask = async (req, res) => {
  try {
    const { title, description, budget, deadline, category } = req.body;

    // Manually parse location string
    let location;
    if (req.body.location) {
      location = JSON.parse(req.body.location);
    } else {
      return res.status(400).json({ message: "Missing location field" });
    }

    // Validate required fields first
    if (!title || !description || !budget  || !category || !location) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // Validate location type
    if (location.type === 'physical') {
      if (!location.address || location.lat == null || location.lng == null) {
        return res.status(400).json({ message: "Physical location requires address, lat, and lng" });
      }
    } else if (location.type !== 'remote') {
      return res.status(400).json({ message: "Location type must be 'physical' or 'remote'" });
    }

    const imageUrls = req.files?.map((file) => file.path) || [];

    const newTask = new Task({
      title,
      description,
      budget,
      ...(deadline && { deadline }),
      user: req.user.id, // Logged-in user
      location,           // Save location object directly
      images: imageUrls,   // Save image paths (from Cloudinary or wherever)
      category,
    });

    const savedTask = await newTask.save();

    res.status(201).json(savedTask);
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Get all tasks
const getTasks = async (req, res) => {
  try {
    const tasks = await Task.find().populate("user", "name email"); // Populate user details
    res.json(tasks);
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Get a single task by ID
const getTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id).populate(
      "user",
      "name email"
    );
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }
    res.json(task);
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Update task status (active, completed, cancelled)
const updateTaskStatus = async (req, res) => {
  const { status } = req.body;

  try {
    let task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }

    // Only the task poster or admin can update status
    if (task.user.toString() !== req.user.id && req.user.role !== "admin") {
      return res
        .status(403)
        .json({ msg: "Not authorized to update task status" });
    }

    task.status = status;
    await task.save();
    res.json(task);
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Delete a task
const deleteTask = async (req, res) => {
  try {
    let task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }

    // Only the user who posted the task or an admin can delete the task
    if (task.user.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ msg: "Not authorized to delete task" });
    }

    // Use deleteOne() to remove the task
    await Task.deleteOne({ _id: req.params.id });

    res.json({ msg: "Task deleted" });
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Bid on a task
const bidOnTask = async (req, res) => {
  const { price, estimatedTime, comment } = req.body;
  const sendNotification = require('../utils/sendnotification.js');
// Get user's FCM token from DB or request


  try {
    const task = await Task.findById(req.params.id).populate("user", "email fcmToken");
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }
    // Find provider's name
    const provider = await User.findById(req.user.id).select("name");
    if (!provider) return res.status(404).json({ msg: "Provider not found" });

    // Add the bid to the task's bids array
    task.bids.push({
      provider: req.user.id,
      price,
      comment: comment || '',
      estimatedTime,
    });

    await task.save();
    //push notification to task poster
    console.log("📲 Sending notification to:", task.user.fcmToken);

    if (task.user.fcmToken) {
      await sendNotification(
        task.user.fcmToken,
        'New Offer Received',
        `${provider.name} has offered $${price} for your task.`,
        { taskId: task._id.toString(), type: "bid" }
      );
    } else {
      console.warn("No FCM token found for user.");
    }
    // sendBidNotificationEmail(task.user.email, task.title, req.user.name); // Send email notification to the task poster
    res.json(task);
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server error");
  }
};

// Accept a bid and assign a provider to the task, updating the task status to "In Progress"
const acceptBid = async (req, res) => {
  const { id, bidId } = req.params;
  const sendNotification = require('../utils/sendnotification.js');
  // Get user's FCM token from DB or request

  try {
    // Find the task by ID
    const task = await Task.findById(id).populate("bids.provider", "name email fcmToken");
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }

    // Ensure the user is the one who posted the task
    if (task.user.toString() !== req.user.id) {
      return res
        .status(403)
        .json({ msg: "Only the task poster can accept a bid" });
    }

    // Find the bid in the task's bids array
    const bid = task.bids.find((bid) => bid._id.toString() === bidId);
    if (!bid) {
      return res.status(404).json({ msg: "Bid not found" });
    }

    // Set the assigned provider and update the task status
    task.assignedProvider = bid.provider;
    task.status = "In Progress";

    await task.save();
    // Send push notification to provider
    const provider = bid.provider;
    if (provider.fcmToken) {
      await sendNotification(
        provider.fcmToken,
        "Offer Accepted!",
        `${task.user.name} has accepted your offer for the task. View task now!`,
        { taskId: task._id.toString(),
          type: 'bid',
        }
      );
    } else {
      console.warn("No FCM token found for accepted provider.");
    }
    // sendBidAcceptedEmail(
    //   bid.provider.email,
    //   task.title
    // ); // Send email notification to the provider

    res.json({ msg: "Bid accepted", task });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Complete Task and Provide a Review
const completeTask = async (req, res) => {
  const { id } = req.params;
  const { rating, comment, recommend } = req.body;
  const sendNotification = require('../utils/sendnotification.js');
  try {
    // Find the task by ID
    const task = await Task.findById(id);
    if (!task) {
      return res.status(404).json({ msg: "Task not found" });
    }

    // Ensure the user is the one who posted the task
    if (task.user.toString() !== req.user.id) {
      return res
        .status(403)
        .json({ msg: "Only the task poster can mark a task as completed" });
    }

    // Check if task is already completed
    if (task.status === "Completed") {
      return res.status(400).json({ msg: "Task is already completed" });
    }

    // Mark task as completed and add the review
    task.status = "Completed";
    task.review = {
      rating,
      comment,
      reviewer: req.user.id,
    };

    // Find the provider of the task
    const provider = await User.findById(task.assignedProvider);
    if (!provider) {
      return res.status(404).json({ msg: "Assigned provider not found" });
    }

    // Increment recommendations 
    if (recommend) {
      provider.recommendations = (provider.recommendations || 0) + 1;
    }

    console.log('👉 Recommend value from body:', recommend);


    // Update the provider's average rating and total reviews
    provider.totalReviews += 1;
    provider.averageRating = Number (
      (provider.averageRating * (provider.totalReviews - 1) + rating) /
      provider.totalReviews
    ).toFixed(1); // Recalculate average rating

    // Increment completed tasks
    provider.completedTasks = (provider.completedTasks || 0) + 1;

    // Ensure recommendations field exists
    provider.recommendations = provider.recommendations || 0;

    // Calculate and assign rank
    provider.rank = calculateProviderRank({
      averageRating: provider.averageRating,
      completedTasks: provider.completedTasks,
      recommendations: provider.recommendations,
    });

    await provider.save(); // Save updated provider info
    await task.save(); // Save the task with updated status and review

    // Send push notification to provider
    if (provider.fcmToken) {
      await sendNotification(
        provider.fcmToken,
        "Task Completed!",
        `Congratulation! You have successfully complete ${task.title}.`,
        { taskId: task._id.toString(),
          type: 'task',
        }
      );
    } else {
      console.warn("No FCM token found for accepted provider.");
    }

    // sendTaskCompletionEmail(
    //   provider.email,
    //   task.title
    // ); // Send email notification to the provider

    //Delete Chat history for the task id
    await Chat.deleteMany({ taskId: task._id });

    res.json({ msg: "Task marked as completed and review added", task });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};
// Create a Comment
const createComment = async (req, res) => {
  const { text } = req.body;
  try {
    const task = await Task.findById(req.params.taskId);
    if (!task) return res.status(404).json({ msg: "Task not found" });

    const newComment = {
      user: req.user.id,
      text,
    };

    task.comments.push(newComment);
    await task.save();

    res.status(201).json(task);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

// Reply to a Comment
const replyToComment = async (req, res) => {
  const { text } = req.body;
  try {
    const task = await Task.findById(req.params.taskId);
    if (!task) return res.status(404).json({ msg: "Task not found" });

    const comment = task.comments.id(req.params.commentId);
    if (!comment) return res.status(404).json({ msg: "Comment not found" });

    const newReply = {
      user: req.user.id,
      text,
    };

    comment.replies.push(newReply);
    await task.save();

    res.status(201).json(task);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
};

module.exports = {
  createTask,
  getTasks,
  getTask,
  updateTaskStatus,
  deleteTask,
  bidOnTask,
  acceptBid,
  completeTask,
  createComment,
  replyToComment
};
