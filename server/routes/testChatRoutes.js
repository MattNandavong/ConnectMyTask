let ioInstance;

const User = require("../models/User");

function initIO(io) {
  ioInstance = io;
}

const sendTestMessage = async (req, res) => {
  const { taskId, sender, text } = req.body;

  if (!taskId || !sender || !text) {
    return res.status(400).json({ msg: "Missing required fields" });
  }

  try {
    const user = await User.findById(sender).select("_id name");
    if (!user) {
      return res.status(404).json({ msg: "Sender user not found" });
    }

    const message = {
      sender: { _id: user._id, name: user.name },
      text,
      timestamp: new Date().toISOString(),
    };

    ioInstance.to(taskId).emit("receiveMessage", message);

    return res.status(200).json({ msg: "Message emitted successfully", data: message });
  } catch (err) {
    console.error("❌ Error sending message:", err.message);
    res.status(500).json({ msg: "Server error" });
  }
};

module.exports = {
  initIO,
  sendTestMessage,
};
