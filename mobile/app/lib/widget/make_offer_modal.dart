import 'package:app/utils/task_service.dart';
import 'package:app/widget/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showMakeOfferModal(BuildContext context, String taskId) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      final _priceController = TextEditingController();
      final _estimatedTimeController = TextEditingController();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Make an Offer',
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _estimatedTimeController,
              decoration: InputDecoration(labelText: 'Estimated Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(_priceController.text);
                final estimatedTime = _estimatedTimeController.text;

                if (price != null && estimatedTime.isNotEmpty) {
                  try {
                    await TaskService().bidOnTask(taskId, price, estimatedTime);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Offer made successfully!')),
                    );
                  } catch (error) {
                    if (error.toString().contains('Authorization failed')) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Authorization failed. Please register as a provider.',
                          ),
                        ),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                          title: const Text('Authorization failed'),
                          content: const SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text('Do you want to sign up as provider?'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                                // FirebaseAuth.instance.signOut();
                              },
                              child: Text('YES'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                return;
                              },
                              child: Text('No'),
                            ),
                          ],
                        );
                        }
                        
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to make offer: $error')),
                      );
                    }
                  }
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter valid offer details')),
                  );
                }
              },
              child: Text('Submit Offer'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
