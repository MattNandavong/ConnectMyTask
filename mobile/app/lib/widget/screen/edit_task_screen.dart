import 'package:flutter/material.dart';
import 'package:app/model/task.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _budgetController;
  late TextEditingController _categoryController;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _budgetController = TextEditingController(
      text: widget.task.budget.toString(),
    );
    _categoryController = TextEditingController(text: widget.task.category);
    _deadline = widget.task.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _deadline = date;
      });
    }
  }

  void _confirmEdit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task Updated Successfully')));

    Navigator.pop(context); // Go back after editing
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 6,
        shadowColor: const Color.fromARGB(66, 190, 190, 190),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(labelText: 'Budget (AUD)'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              ListTile(
                title: Text(
                  _deadline != null
                      ? dateFormat.format(_deadline!)
                      : 'Select Deadline',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDeadline,
              ),
              SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _confirmEdit,
                icon: Icon(Icons.check),
                label: Text(
                  'Confirm Edit',
                  style: GoogleFonts.oswald(fontSize: 18),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
