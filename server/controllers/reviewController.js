// controllers/reviewController.js
const Review = require("../models/Review");

const getProviderReviews = async (req, res) => {
  const { providerId } = req.params;

  try {
    const reviews = await Review.find({ provider: providerId }).populate(
      "reviewer",
      "name email profilePhoto location isVerified averageRating totalReviews skills role"
    );
    res.json(reviews);
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: "Server error" });
  }
};

module.exports = { getProviderReviews };
