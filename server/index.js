require("dotenv").config();
const express = require("express");
const http = require("http");
const socketio = require("socket.io");
const connectDB = require("./config/db");
const taskRoutes = require("./routes/taskRoutes");
const authRoutes = require("./routes/authRoutes");

const app = express();
const server = http.createServer(app); // ✅ wrap app with http
const io = socketio(server, {
  cors: {
    origin: "*", // Update this in production
    methods: ["GET", "POST"],
  },
});

// Middleware
app.use(express.json());

// Connect to Database
connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/tasks", taskRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Hello World!");
});

// Socket.IO logic
io.on("connection", (socket) => {
  console.log("🔌 New client connected:", socket.id);

  socket.on("joinTask", ({ taskId }) => {
    socket.join(taskId);
    console.log(`User joined room for task: ${taskId}`);
  });

  socket.on("sendMessage", ({ taskId, sender, text }) => {
    const message = {
      sender,
      text,
      timestamp: new Date(),
    };

    io.to(taskId).emit("receiveMessage", message);

    // Optional: store message in MongoDB
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

// Start server with Socket.IO
const PORT = process.env.PORT || 3300;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
