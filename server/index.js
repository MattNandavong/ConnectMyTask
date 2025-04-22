require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const taskRoutes = require("./routes/taskRoutes");
const authRoutes = require("./routes/authRoutes");
const chatRoutes = require('./routes/chatRoutes');
const { initIO, sendTestMessage } = require('./routes/testChatRoutes');

const cors = require("cors");
const http = require('http');
const socketio = require('socket.io');

const admin = require('./config/firebaseAdmin');
// Required for FCM
const ChatMessage = require("./models/ChatMessage"); // Message Model
const Task = require("./models/Task"); // Task Model for sender/receiver logic
const User = require("./models/User"); // Needed 

//initialize Firebase Admin SDK
// const serviceAccount = require("./config/serviceAccountKey.json");
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });


const app = express();
// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json());

// Connect to Database
connectDB();

// Routes register
app.use("/api/auth", authRoutes); // Use auth routes for login, register, etc.
app.use("/api/tasks", taskRoutes); // Use task routes for task management
app.use('/api/chat', chatRoutes);// Use chatRoutes for chat

//Create HTTP + Socket Server
const server = http.createServer(app);
const io = socketio(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

//initialise Socket.io comm
io.on('connection', (socket) => {
  console.log('Socket.Io: New client connected:', socket.id);

  socket.on('joinTask', ({ taskId }) => {
    socket.join(taskId);
    console.log(`Socket.Io: User joined task room: ${taskId}`);
  });

  //Send messages
  socket.on('sendMessage', async (data) => {
    const messageData = {
      taskId: data.taskId,
      sender: data.sender,
      text: data.text,
    };

    //save message to DB
    const savedMessage = await ChatMessage.create(messageData);

    // Send push notification to other user
    const task = await Task.findById(data.taskId).populate('user');
    const recipientId = data.sender._id == task.user._id.toString() 
      ? task.assignedProvider 
      : task.user._id;

    const recipient = await User.findById(recipientId);
    if (recipient?.fcmToken) {
      await admin.messaging().send({
        token: recipient.fcmToken,
        notification: {
          title: 'New Message',
          body: data.text,
        },
        data: {
          taskId: data.taskId,
          type:'chat',
        },
      });
    }

    //receive messages to client room
    io.to(data.taskId).emit('receiveMessage', {
      sender: savedMessage.sender,
      text: savedMessage.text,
      timestamp: savedMessage.timestamp,
    });
  });

  socket.on('disconnect', () => {
    console.log('Socket.Io: Client disconnected');
  });
});


// Test Routes for chat using postman
app.post("/api/test/chat", sendTestMessage);

app.get("/", (req, res) => {
  res.send("Hello World!");
});

//start server
initIO(io);
const port = 3300;
server.listen(port, () => {
  console.log(`Example app listening on port hi ${port}`);
});


