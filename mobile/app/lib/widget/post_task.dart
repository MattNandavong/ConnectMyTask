import 'dart:convert';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostTask extends StatefulWidget {
  const PostTask({super.key});

  @override
  State<PostTask> createState() => _PostTaskState();
}

class _PostTaskState extends State<PostTask> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String _workType = 'Remote';
  DateTime? _deadline;
  int _currentStep = 0;
  final int _totalSteps = 5;
  final formatter = DateFormat.yMMMd();

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
    (_) => GlobalKey<FormState>(),
  );

  void _nextStep() {
    final isValid = _formKeys[_currentStep].currentState?.validate() ?? true;

    if (isValid && _currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _presentDataPicker() async {
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDateTime != null) {
      setState(() {
        _deadline = pickedDateTime;
      });
    }
  }

  Future<void> _postTask() async {
    for (final key in _formKeys.take(4)) {
      if (key.currentState != null && !key.currentState!.validate()) {
        return;
      }
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a deadline')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please log in to post a task.')));
      return;
    }

    try {
      final result = await TaskService().createTask(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        double.parse(_budgetController.text),
        _deadline!.toIso8601String(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task posted successfully!')));

      // Reset form
      setState(() {
        _currentStep = 0;
        _titleController.clear();
        _descriptionController.clear();
        _budgetController.clear();
        _deadline = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post task: ${e.toString()}')),
      );
    }
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / _totalSteps,
          backgroundColor: Colors.grey.shade300,
          color: Colors.teal,
          minHeight: 6,
        ),
        SizedBox(height: 10),
        Text(
          'Step ${_currentStep + 1} of $_totalSteps',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStepCard({required Widget child, required String title}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Form(
          key: _formKeys[0],
          child: _buildStepCard(
            title: 'Task Title',
            child: TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Enter a short, clear title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Title is required'
                          : null,
            ),
          ),
        );
      case 1:
        return Form(
          key: _formKeys[1],
          child: _buildStepCard(
            title: 'Description',
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe the task in detail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Description is required'
                          : null,
            ),
          ),
        );
      case 2:
        return Form(
          key: _formKeys[2],
          child: _buildStepCard(
            title: 'Budget',
            child: TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your budget in AUD',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Budget is required';
                }

                final parsed = double.tryParse(value);
                if (parsed == null) {
                  return 'Please enter a valid number';
                }

                if (parsed <= 0) {
                  return 'Budget must be greater than 0';
                }

                return null;
              },
            ),
          ),
        );
      case 3:
        return Form(
          key: _formKeys[3],
          child: _buildStepCard(
            title: 'Work Type',
            child: DropdownButtonFormField<String>(
              value: _workType,
              items:
                  ['Remote', 'On Location']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _workType = val!),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
          ),
        );
      case 4:
        return _buildStepCard(
          title: 'Deadline',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _deadline == null
                    ? 'No deadline selected'
                    : '${formatter.format(_deadline!)}',
                style: TextStyle(fontSize: 16),
              ),
              ElevatedButton.icon(
                onPressed: _presentDataPicker,
                icon: Icon(Icons.calendar_today),
                label: Text('Pick Date'),
              ),
            ],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Post a Task')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(onPressed: _prevStep, child: Text('Back')),
                if (_currentStep < _totalSteps - 1)
                  ElevatedButton(onPressed: _nextStep, child: Text('Next')),
                if (_currentStep == _totalSteps - 1)
                  ElevatedButton.icon(
                    onPressed: _postTask,
                    icon: Icon(Icons.send),
                    label: Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
