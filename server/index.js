require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const taskRoutes = require("./routes/taskRoutes");
const authRoutes = require("./routes/authRoutes");
const cors = require("cors");
const http = require('http');
const socketio = require('socket.io');
const { initIO, sendTestMessage } = require('./routes/testChatRoutes');
//chat routes
const chatRoutes = require('./routes/chatRoutes');


const ChatMessage = require('./models/ChatMessage');




const app = express();

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json());

// Connect to Database
connectDB();

// Routes
app.use("/api/auth", authRoutes); // Use auth routes for login, register, etc.
app.use("/api/tasks", taskRoutes); // Use task routes for task management

// Socket.io setup
const server = http.createServer(app);
const io = socketio(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  console.log('Socket.Io: New client connected:', socket.id);

  socket.on('joinTask', ({ taskId }) => {
    socket.join(taskId);
    console.log(`Socket.Io: User joined task room: ${taskId}`);
  });

  socket.on('sendMessage', async (data) => {
    const messageData = {
      taskId: data.taskId,
      sender: data.sender,
      text: data.text,
    };
  
    const savedMessage = await ChatMessage.create(messageData);
  
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

const port = 3300;

// Start the chat
initIO(io);
app.post("/api/test/chat", sendTestMessage);

app.get("/", (req, res) => {
  res.send("Hello World!");
});

server.listen(port, () => {
  console.log(`Example app listening on port hi ${port}`);
});

app.use('/api/chat', chatRoutes);
