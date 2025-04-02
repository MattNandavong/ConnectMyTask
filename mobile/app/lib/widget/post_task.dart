import 'dart:convert';
import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/widget/drawer_menu.dart';
import 'package:app/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;

class PostTask extends StatefulWidget {
  const PostTask({super.key});

  @override
  State<PostTask> createState() => _PostTaskState();
}

class _PostTaskState extends State<PostTask> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();
  // final quill.QuillController _controller = quill.QuillController.basic();
  String _workType = 'Remote';
  DateTime? _deadline ;
  final User user = User(id: id, name: name, email: email, role: role)
  

  

  Future<void> _postTask() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    if (token == null) {
      // Handle missing token
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to post a task.')),
      );
      return;
    }

    final url = 'http://localhost:3300/api/tasks';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'budget': double.parse(_budgetController.text),
        'deadline': _deadline.toString(),
      }),
    );

    if (response.statusCode == 201) {
      // Handle successful task creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task posted successfully!')),
      );
      _formKey.currentState?.reset();
    } else {
      // Handle task creation failure
      final errorData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorData['msg'] ?? 'Failed to post task.')),
      );
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDataPicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    // final lastDate = DateTime(now.);
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    setState(() {
      _deadline = pickedDateTime;
    });
  }

  Widget build(BuildContext context) {
    final formatter = DateFormat.yMd();

    formattedDate(date) {
      return formatter.format(date);
    }

    return Scaffold(
      appBar: TopBar(screen: 'screen'),
      drawer: DrawerMenu(user: user),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(color: Colors.white),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter task title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.multiline,
                selectionHeightStyle: BoxHeightStyle.max,
                controller: _descriptionController,
                
                decoration: InputDecoration(labelText: 'Description'),
                maxLength: 150,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty ) {
                    return 'Please enter a budget';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Work Type'),
                value: _workType,
                items:
                    ['Remote', 'On Location'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _workType = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Due date: '),
                    Text(
                      _deadline == null
                          ? ('No date selected')
                          : formatter.format(_deadline!),
                    ),
                    IconButton(
                      onPressed: _presentDataPicker,
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              
              ElevatedButton(onPressed: _postTask, child: Text('Create Task')),
            ],
          ),
          
        ),
        
      ),
    );
  }
}
