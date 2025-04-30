import 'package:app/model/review.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/review_service.dart';
import 'package:app/widget/login/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final bool editable;

  const ProfileScreen({required this.user, required this.editable});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user; // show instantly
    _loadUser(); // update with backend version
  }

  Future<void> _loadUser() async {
    try {
      final latest = await AuthService().getUserProfile(widget.user.id);
      setState(() {
        _user = latest;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to reload user: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasValidPhoto(String? url) =>
        url != null &&
        url.trim().isNotEmpty &&
        Uri.tryParse(url)?.hasAbsolutePath == true;

    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildScrollableContent(context)),
            ],
          ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _user!.buildAvatar(radius: 40),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _user!.name,
                style: GoogleFonts.figtree(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_user!.isVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.verified, color: Colors.white, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(
                Icons.badge_rounded,
                _user!.isVerified ? 'Verified' : 'Unverified',
              ),
              const SizedBox(width: 20),
              _buildStat(
                Icons.location_on,
                _user!.location?['country'] ?? '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return FutureBuilder<User?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final currentUser = snapshot.data!;
        final isOwner = currentUser.id == _user!.id;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOwner)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProfileSetupScreen(user: _user!),
                        ),
                      );
                    },
                    child: Text("Edit Profile"),
                  ),
                ),
              if (_user!.rank != null) buildRankBadge(_user!),
              SizedBox(height: 10),
              if (_user!.role == 'provider') ...[
                Text(
                  "Skills",
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _user!.skills.map((skill) {
                        return Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              skill.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.figtree(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
              ],
              _buildInfoTile(
                context,
                _user!.isVerified
                    ? Icons.verified_user
                    : Icons.person_outline,
                'Verification Status',
                _user!.isVerified ? 'Verified' : 'Unverified',
              ),
              const SizedBox(height: 20),
              Text(
                "Latest Reviews",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Review>>(
                future: getProviderReviews(_user!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) return const Text("No reviews yet.");

                  return SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return Container(
                          width: 240,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(blurRadius: 3, color: Colors.black12),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Task Title",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "⭐ ${r.rating.toStringAsFixed(1)}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.comment,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  r.reviewer.profilePhoto != null &&
                                          r.reviewer.profilePhoto!.isNotEmpty
                                      ? CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(
                                          r.reviewer.profilePhoto!,
                                        ),
                                      )
                                      : r.reviewer.buildAvatar(radius: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    r.reviewer.name,
                                    style: const TextStyle(fontSize: 12),
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
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.figtree(color: Colors.white)),
      ],
    );
  }

  Widget _buildInfoTile(context, IconData icon, String title, String value) {
    return Card(
      // color: Theme.of(context).colorScheme.onInverseSurface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget buildRankBadge(User user) {
    final color =
        {
          'Bronze': Colors.brown,
          'Silver': Colors.grey,
          'Gold': Colors.amber,
          'Platinum': Colors.blueAccent,
        }[user.rank] ??
        Colors.black;

    return Card(
      // color: Theme.of(context).colorScheme.onInverseSurface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Image.asset(
          "lib/image/${user.rank}.png",
          width: 50,
          height: 50,
        ),
        title: Text(
          user.rank!,
          style: GoogleFonts.oswald(fontWeight: FontWeight.w800, color: color),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasks completed ${user.completedTasks}'),
            Text('Recommended by ${user.recommendations} people'),
          ],
        ),
      ),
    );
  }
}
