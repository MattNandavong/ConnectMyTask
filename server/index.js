require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const taskRoutes = require("./routes/taskRoutes");
const authRoutes = require("./routes/authRoutes");
const chatRoutes = require('./routes/chatRoutes');
const locationRoutes = require("./routes/locationRoutes");
const { initIO, sendTestMessage } = require('./routes/testChatRoutes');
const messageRoutes = require("./routes/messageRoutes");
const { initSocket } = require("./utils/socket");

const cors = require("cors");
const http = require('http');
const socketio = require('socket.io');

const admin = require('./config/firebaseAdmin');
const ChatMessage = require("./models/Message");
const Task = require("./models/Task");
const User = require("./models/User");

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// app.use((req, res, next) => {
//   console.log(`[${req.method}] ${req.originalUrl}`);
//   next();
// });

// Connect to DB
connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/messages", messageRoutes);


// Create HTTP + WebSocket server
// const server = http.createServer(app);
// const io = socketio(server, {
//   cors: {
//     origin: '*',
//     methods: ['GET', 'POST'],
//   },
// });
// app.set('io', io);

// // Socket.IO logic
// io.on('connection', (socket) => {
//   console.log('📡 Socket connected:', socket.id);

//   socket.on('joinTask', ({ taskId }) => {
//     socket.join(taskId);
//     console.log(`👥 Joined task room: ${taskId}`);
//   });

//   socket.on('sendMessage', async (data) => {
//     try {
//       const messageData = {
//         taskId: data.taskId,
//         sender: data.sender._id, // ensure only _id is used
//         receiver: data.receiver._id,
//         text: data.text,
//       };

//       const savedMessage = await ChatMessage.create(messageData);

//       const task = await Task.findById(data.taskId).populate('user');
//       if (!task) {
//         console.error(`❌ Task not found: ${data.taskId}`);
//         return;
//       }

//       const recipientId = data.sender._id == task.user._id.toString()
//         ? task.assignedProvider
//         : task.user._id;

//       const recipient = await User.findById(recipientId);
//       //push notification
//       if (recipient?.fcmToken) {
//         await admin.messaging().send({
//           token: recipient.fcmToken,
//           notification: {
//             title: 'New Message',
//             body: data.text,
//           },
//           data: {
//             taskId: data.taskId,
//             type: 'chat',
//           },
//         });
//       }

//       console.log('💬 Emitting saved message:', {
//         sender: { _id: savedMessage.sender },
//         receiver: {_id: savedMessage.receiver},
//         text: savedMessage.text,
//         image: savedMessage.image,
//         timestamp: savedMessage.timestamp,
//       });

//       io.to(data.taskId).emit('receiveMessage', {
//         sender: { _id: savedMessage.sender },
//         receiver: {_id: savedMessage.receiver},
//         text: savedMessage.text,
//         image: savedMessage.image,
//         timestamp: savedMessage.timestamp,
//       });

//     } catch (error) {
//       console.error('❌ Error in sendMessage handler:', error);
//     }
//   });
// });

// Extra routes
// app.post("/api/test/chat", sendTestMessage);
app.get("/", (req, res) => res.send("Hello World!"));

// Start server
// initIO(io);
const io = initSocket(server);
app.set('io', io); // <-- Attach io to Express app

const PORT = process.env.PORT || 3300;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
