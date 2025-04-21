import 'dart:io';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostTask extends StatefulWidget {
  const PostTask({super.key});
  @override
  State<PostTask> createState() => _PostTaskState();
}

class _PostTaskState extends State<PostTask> {
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final DateFormat _formatter = DateFormat.yMMMMd();

  String _category = 'Cleaning';
  double _budget = 0.0;
  bool _isRemote = true;
  String _selectedState = 'VIC';
  String? _city;
  DateTime? _deadline;
  TimeOfDay? _deadlineTime;
  int _currentStep = 0;

  List<Map<String, dynamic>> _imagesWithCaptions = [];

  final _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Handyman',
    'Moving',
    'Delivery',
    'Gardening',
    'Tutoring',
    'Tech Support',
    'Other'
  ];

  final _states = ['VIC', 'NSW', 'QLD', 'SA', 'WA', 'TAS', 'ACT', 'NT'];

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      setState(() {
        _deadline = date;
        _deadlineTime = time ?? TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 75);
    if (files != null) {
      setState(() {
        _imagesWithCaptions.addAll(
          files.map((e) => {'file': File(e.path), 'caption': ''}),
        );
      });
    }
  }

void _submitTask() async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Confirm Submit'),
      content: Text('Do you want to post this task?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // close dialog

            try {
              final deadlineDateTime = DateTime(
                _deadline!.year,
                _deadline!.month,
                _deadline!.day,
                _deadlineTime?.hour ?? 23,
                _deadlineTime?.minute ?? 59,
              );

              await TaskService().createTask(
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                budget: double.tryParse(_budgetController.text.trim()) ?? 0,
                deadline: deadlineDateTime.toIso8601String(),
                category: _category,
                location: _isRemote
                    ? "Remote"
                    : '$_selectedState${_locationController.text.isNotEmpty ? ', ${_locationController.text.trim()}' : ''}',
                images: _imagesWithCaptions
                    .map((img) => img['file'] as File)
                    .toList(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task Submitted')),
              );

              setState(() {
                _currentStep = 0;
                _titleController.clear();
                _descController.clear();
                _budgetController.clear();
                _locationController.clear();
                _imagesWithCaptions.clear();
                _deadline = null;
                _deadlineTime = null;
                _isRemote = true;
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to submit task: $e')),
              );
            }
          },
          child: Text('Submit'),
        )
      ],
    ),
  );
}


  Widget _buildPreview() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text("📌 Title: ${_titleController.text}", style: TextStyle(fontSize: 16)),
        Text("📂 Category: $_category"),
        Text("📝 Description:\n${_descController.text}"),
        SizedBox(height: 12),
        Text("💰 Budget: \$${_budgetController.text}"),
        if (_deadline != null)
          Text(
            "⏳ Deadline: ${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? 'No deadline'}",
          ),
        Text("📍 Location: ${_isRemote ? 'Remote' : 'On Location ($_selectedState)'}"),
        if (!_isRemote) Text("🏙️ City/Suburb: ${_locationController.text}"),
        SizedBox(height: 20),
        Text("🖼️ Images:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ..._imagesWithCaptions.map(
          (img) => ListTile(
            leading: Image.file(img['file'], width: 50, height: 50, fit: BoxFit.cover),
            // title: Text(img['caption'] ?? ''),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          icon: Icon(Icons.send),
          label: Text('Confirm & Submit'),
          onPressed: _submitTask,
          // onPressed: () {
          //   print('Task Submit: ${_titleController.text} ${_category} ${_descController.text} ${_budgetController.text} ${_formatter.format(_deadline!)} ${_isRemote ? 'Remote' : 'On Location ($_selectedState)'} ${_locationController.text}');
          // },
        )
      ],
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return Form(
          key: _formKeys[0],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField(
                  value: _category,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        );
      case 1:
        return Form(
          key: _formKeys[1],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Budget (AUD)'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                ListTile(
                  title: Text(_deadline != null
                      ? '${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? ''}'
                      : 'Select Deadline'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _pickDeadline,
                ),
                SwitchListTile(
                  title: Text('Remote'),
                  value: _isRemote,
                  onChanged: (val) => setState(() => _isRemote = val),
                ),
                if (!_isRemote) ...[
                  DropdownButtonFormField(
                    value: _selectedState,
                    decoration: InputDecoration(labelText: 'State'),
                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedState = val!),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'City / Suburb'),
                  ),
                ]
              ],
            ),
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.photo_library),
                label: Text('Upload Images'),
                onPressed: _pickImages,
              ),
              SizedBox(height: 10),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _imagesWithCaptions.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _imagesWithCaptions.removeAt(oldIndex);
                      _imagesWithCaptions.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final image = _imagesWithCaptions[index];
                    return ListTile(
                      key: ValueKey(index),
                      leading: Image.file(image['file'], width: 60, height: 60, fit: BoxFit.cover),
                      // title: TextFormField(
                      //   initialValue: image['caption'],
                      //   onChanged: (val) => image['caption'] = val,
                      //   decoration: InputDecoration(labelText: 'Caption'),
                      // ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _imagesWithCaptions.removeAt(index)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      case 3:
        return _buildPreview();
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Task')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: Colors.teal,
          ),
          Expanded(child: _buildStepContent(_currentStep)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(onPressed: () => setState(() => _currentStep--), child: Text('Back')),
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: () {
                      final valid = _formKeys[_currentStep].currentState?.validate() ?? true;
                      if (valid) setState(() => _currentStep++);
                    },
                    child: Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
