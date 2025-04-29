// lib/widget/task_details/task_detail_body.dart

import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/comment_section.dart';
import 'package:app/widget/make_offer_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class TaskDetailBody extends StatelessWidget {
  final Task task;
  final User user;
  final bool isPoster;
  final bool isCompleted;
  final String? currentUserId;
  final void Function()? onViewOffers;
  final void Function()? onOpenChat;
  final void Function()? onMarkComplete;
  final void Function()? onMakeOffer;
  final void Function()? showImageGallery;

  const TaskDetailBody({
    required this.task,
    required this.user,
    required this.isPoster,
    required this.isCompleted,
    this.currentUserId,
    this.onViewOffers,
    this.onOpenChat,
    this.onMarkComplete,
    this.onMakeOffer,
    this.showImageGallery,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMMd();

    return Positioned.fill(
      top: 80, // Leaves room for the status section
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title.toUpperCase(),
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  task.description,
                  style: GoogleFonts.figtree(fontSize: 15),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Icon(Icons.attach_money_rounded, color: Theme.of(context).colorScheme.secondary),
                    // SizedBox(width: 6),
                    Text(
                      '${task.budget.toStringAsFixed(2)}',
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    // Icon(Icons.calendar_today, size: 18),
                    // SizedBox(width: 6),
                    Text(
                      task.deadline !=null ? 'Deadline: ${formatter.format(task.deadline!)}': 'Deadline: Flexible',
                      style: GoogleFonts.figtree(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // IMAGES SECTION
                if (task.images.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Text(
                    'Images:',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: task.images.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final imageUrl = task.images[index];
                        return GestureDetector(
                          onTap: () {
                            showImageGallery;
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // LOCATION DETAILS SECTION
                SizedBox(height: 20),
                Text(
                  'Location:',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      task.location?.type == 'remote'
                          ? Row(
                            children: [
                              Icon(Icons.cloud_outlined, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is a remote task',
                                  style: GoogleFonts.figtree(fontSize: 14),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task.location?.address ??
                                          'Unknown Address',
                                      style: GoogleFonts.figtree(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 200,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        task.location?.lat ?? 0.0,
                                        task.location?.lng ?? 0.0,
                                      ),
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId('task-location'),
                                        position: LatLng(
                                          task.location?.lat ?? 0.0,
                                          task.location?.lng ?? 0.0,
                                        ),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    liteModeEnabled: true, // faster map
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
                SizedBox(height: 20,),
                
                Text(
                  'Posted by: ',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Divider(),
                Row(
                  children: [
                    user.buildAvatar(radius: 18),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // show privider brief profile if task assigned
                if (task.assignedProvider != null) ...[
                  FutureBuilder<User>(
                    future: AuthService().getUserProfile(
                      task.assignedProvider!.id,
                    ),
                    builder: (context, providerSnapshot) {
                      if (providerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!providerSnapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Failed to load provider info'),
                        );
                      }

                      final provider = providerSnapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.assignment_turned_in_outlined,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This task is assigned to:',
                                    style: GoogleFonts.figtree(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            child: Row(
                              children: [
                                provider.buildAvatar(radius: 18),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.name,
                                        style: GoogleFonts.figtree(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      Text(
                                        provider.averageRating != null ||
                                                provider.averageRating! > 0
                                            ? '⭐ ${provider.averageRating!.toStringAsFixed(1)}'
                                            : 'No rating yet',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                            // TODO: Submit the comment to backend
                                
                          SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ],
                Text(
                                'Comments',
                                style: GoogleFonts.figtree(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              CommentSection(taskId: task.id),
                              SizedBox(height: 20),

                SizedBox(height: 20),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
