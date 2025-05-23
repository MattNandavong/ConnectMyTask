const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: {
      type: String,
      enum: ["user", "provider", "admin"],
      default: "user",
    },
    profilePhoto: { type: String },
    location: {
      country: { type: String },           
      lat: { type: Number },               
      lng: { type: Number },
    },
    skills: [{ type: String }], // Only applicable for providers
    isVerified: { type: Boolean, default: false },
    // For Google login
    googleId: { type: String },
    averageRating: { type: Number, default: 0 }, // Average rating for providers
    totalReviews: { type: Number, default: 0 }, // Number of received reviews
    completedTasks: { type: Number, default: 0 },
    recommendations: { type: Number, default: 0 },
    rank: {
      type: String,
      enum: ['Bronze', 'Silver', 'Gold', 'Platinum'],
      default: 'Bronze',
    },
    fcmToken: { type: String },// for FCM push notification 
  },
  { timestamps: true }
);

// Hash password before saving to DB
UserSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare Password for Login
UserSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model("User", UserSchema);
