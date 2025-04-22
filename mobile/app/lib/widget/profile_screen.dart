import 'package:app/model/Review.dart';
import 'package:app/utils/review_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔷 Profile Header
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                        ? CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.profilePhoto!),
                        )
                        : user.buildAvatar(radius: 40),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.figtree(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (user.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '@${user.email.split("@")[0]}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat(
                          '⭐',
                          '${user.averageRating?.toStringAsFixed(1) ?? '0.0'}',
                        ),
                        SizedBox(width: 20),
                        _buildStat('💬', '${user.totalReviews} Reviews'),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: Text("Edit Profile"),
                    ),
                  ],
                ),
              ),

              // ⬇ Bottom content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      if (user.location != null)
                        _buildInfoTile(
                          Icons.location_on,
                          'Location',
                          user.location!,
                        ),

                      if (user.role == 'provider') ...[
                        Text(
                          "Skills",
                          style: GoogleFonts.figtree(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              user.skills
                                  .map(
                                    (skill) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        skill,
                                        style: GoogleFonts.figtree(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        SizedBox(height: 20),
                      ],

                      _buildInfoTile(
                        user.isVerified
                            ? Icons.verified_user
                            : Icons.person_outline,
                        'Verification Status',
                        user.isVerified ? 'Verified' : 'Unverified',
                      ),

                      // ⭐ Horizontal Review Scroll
                      SizedBox(height: 20),
                      Text(
                        "Latest Reviews",
                        style: GoogleFonts.figtree(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<List<Review>>(
                        future: getProviderReviews(user.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          final reviews = snapshot.data!;
                          return SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final r = reviews[index];
                                return Container(
                                  width: 240,
                                  margin: EdgeInsets.only(right: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Colors.black12,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "⭐ ${r.rating.toStringAsFixed(1)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(r.comment),
                                      Spacer(),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage:
                                                r.photo != null
                                                    ? NetworkImage(r.photo!)
                                                    : null,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            r.reviewer,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 🔙 Back button
          Positioned(
            top: 40,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(label, style: GoogleFonts.figtree(color: Colors.white)),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF457EFF)),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
