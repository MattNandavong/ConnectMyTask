import 'dart:convert';
import 'package:app/model/bid.dart';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:app/widget/make_offer_modal.dart';
import 'package:app/widget/my_task/bids.dart';
import 'package:app/widget/profile_screen.dart';
import 'package:app/widget/screen/edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyTaskDetails extends StatelessWidget {
  final String taskId;
  MyTaskDetails({required this.taskId});

  final formatter = DateFormat.yMMMMd();

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    return user['_id'] ?? user['id'];
  }

  Future<Map<String, User>> fetchProvidersForBids(List<Bid> bids) async {
    final Map<String, User> providerMap = {};
    for (var bid in bids) {
      if (!providerMap.containsKey(bid.provider)) {
        final user = await AuthService().getUserProfile(bid.provider);
        providerMap[bid.provider] = user;
      }
    }
    return providerMap;
  }

  void _showImageGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    PageController pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 30,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Theme.of(context).colorScheme.surface,
    //   appBar: AppBar(title: Text('Task Details')),
    return FutureBuilder<Task>(
      future: TaskService().getTask(taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        final task = snapshot.data!;
        final user = task.user;

        return FutureBuilder<String?>(
          future: _getCurrentUserId(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData)
              return Center(child: CircularProgressIndicator());
            final currentUserId = userSnapshot.data;
            final isPoster = currentUserId == task.user.id;
            final isCompleted = task.status.toLowerCase() == 'completed';

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                surfaceTintColor: Colors.white,
                elevation: 8,
                title: Text('Task Details'),
                actions: [
                  if (isPoster && !isCompleted)
                    IconButton(
                      icon: Icon(Icons.edit_rounded),
                      tooltip: 'Edit Task',
                      onPressed: () {
                        // Navigate to Edit Task screen (you'll implement it)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task,),
                          ),
                        );
                      },
                    ),
                ],
              ),

              body: Stack(
                children: [
                  // BACKGROUND STATUS SECTION
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                task.status == 'Active'
                                    ? 'WAITING OFFERS'
                                    : task.status.toUpperCase(),
                                style: GoogleFonts.oswald(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(task.status),
                                ),
                              ),
                              if (isPoster &&
                                  task.bids.isNotEmpty &&
                                  task.assignedProvider == null) ...[
                                FilledButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                      0,
                                      24,
                                    ), // Optional: sets a smaller height baseline
                                  ),
                                  icon: Icon(
                                    Icons.visibility,
                                    size: 12,
                                  ), // Smaller icon
                                  label: Text(
                                    'View Offers',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ), // Smaller text
                                  ),
                                  onPressed: () {
                                    showBidsModal(
                                      context: context,
                                      bids: task.bids,
                                      taskId: task.id,
                                      onBidAccepted: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => MyTaskDetails(
                                                  taskId: task.id,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          // SizedBox(height: 6),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            value: _getStatusProgress(task.status),
                            backgroundColor: Colors.grey.shade300,
                            color: _getStatusColor(task.status),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  //  MAIN CONTENT
                  Positioned.fill(
                    top: 80, // Leaves room for the status section
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),

                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: GoogleFonts.figtree(
                                  fontSize: 22,
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
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
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
                                    task.deadline != null
                                        ? 'Deadline: ${formatter.format(task.deadline!)}'
                                        : 'Deadline: Flexible',
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
                                Container(
                                  height: 140,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: task.images.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final imageUrl = task.images[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _showImageGallery(
                                            context,
                                            task.images,
                                            index,
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                  color:
                                        Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    task.location?.type == 'remote'
                                        ? Row(
                                          children: [
                                            Icon(
                                              Icons.cloud_outlined,
                                              color: Colors.teal,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'This is a remote task',
                                                style: GoogleFonts.figtree(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                    style: GoogleFonts.figtree(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: SizedBox(
                                                height: 200,
                                                child: GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                        target: LatLng(
                                                          task.location?.lat ??
                                                              0.0,
                                                          task.location?.lng ??
                                                              0.0,
                                                        ),
                                                        zoom: 15,
                                                      ),
                                                  markers: {
                                                    Marker(
                                                      markerId: MarkerId(
                                                        'task-location',
                                                      ),
                                                      position: LatLng(
                                                        task.location?.lat ??
                                                            0.0,
                                                        task.location?.lng ??
                                                            0.0,
                                                      ),
                                                    ),
                                                  },
                                                  zoomControlsEnabled: false,
                                                  liteModeEnabled:
                                                      true, // faster map
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                              SizedBox(height: 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                        child: Text(
                                          'Failed to load provider info',
                                        ),
                                      );
                                    }

                                    final provider = providerSnapshot.data!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .assignment_turned_in_outlined,
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
                                                      style:
                                                          GoogleFonts.figtree(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),

                                                    Text(
                                                      provider.averageRating !=
                                                                  null ||
                                                              provider.averageRating! >
                                                                  0
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
                                              SizedBox(height: 12),
                                              ElevatedButton.icon(
                                                icon: Icon(
                                                  Icons.chat_bubble_outline,
                                                ),
                                                label: Text("Open Chat"),
                                                style: ElevatedButton.styleFrom(
                                                  // backgroundColor: Colors.blueAccent,
                                                  // foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) => ChatScreen(
                                                            taskId: task.id,
                                                            userId:
                                                                currentUserId!,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                              if (task.status.toLowerCase() == 'in progress' &&
                                  isPoster)
                                Container(
                                  padding: const EdgeInsets.all(40.0),
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      //TODO: Implement simulated payment
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          double rating = 5.0;
                                          TextEditingController
                                          commentController =
                                              TextEditingController();

                                          return AlertDialog(
                                            title: Text(
                                              'How was your experience?',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Rate the provider'),
                                                SizedBox(height: 8),
                                                StatefulBuilder(
                                                  builder:
                                                      (
                                                        context,
                                                        setState,
                                                      ) => Slider(
                                                        min: 1,
                                                        max: 5,
                                                        divisions: 4,
                                                        label:
                                                            rating.toString(),
                                                        value: rating,
                                                        onChanged:
                                                            (val) => setState(
                                                              () =>
                                                                  rating = val,
                                                            ),
                                                      ),
                                                ),
                                                TextField(
                                                  controller: commentController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Leave a comment...',
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                              ),
                                              ElevatedButton(
                                                child: Text('Submit'),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await TaskService()
                                                      .completeTask(
                                                        task.id,
                                                        rating,
                                                        commentController.text
                                                            .trim(),
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Task marked as completed!',
                                                      ),
                                                    ),
                                                  );
                                                  Navigator.pop(
                                                    context,
                                                  ); // or refresh screen
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.done_all),
                                    label: Text('Mark as Completed'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _getStatusProgress(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 1.0;
      case 'in progress':
        return 0.7;
      case 'active':
        return 0.4;
      case 'urgent':
        return 0.2;
      default:
        return 0.1;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.grey;
      case 'in progress':
        return Colors.blueAccent;
      case 'active':
        return Colors.green;
      case 'urgent':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
