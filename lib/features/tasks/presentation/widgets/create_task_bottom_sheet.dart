import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../providers/create_task_provider.dart';
import '../providers/task_provider.dart';

class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  final TaskModel? task; // null → create | not null → edit

  const CreateTaskBottomSheet({super.key, this.task});

  @override
  ConsumerState<CreateTaskBottomSheet> createState() =>
      _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState
    extends ConsumerState<CreateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  DateTime? _dueDate;

  bool _isSubmitting = false;
  bool _showPreview = false;

  Map<String, dynamic>? _previewData;

  String? _selectedCategory;
  String? _selectedPriority;

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    // 🔹 Prefill fields for Edit mode
    if (isEditMode) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _assignedToController.text = task.assignedTo ?? '';
      _dueDate = task.dueDate;
      _selectedCategory = task.category;
      _selectedPriority = task.priority;
      _showPreview = true; // Skip analyze in edit mode
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  // -------------------------------
  // 📅 Pick Due Date
  // -------------------------------
  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _dueDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  // -------------------------------
  // 🚀 Analyze / Save / Update
  // -------------------------------
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // ✏️ EDIT MODE → Update task
    if (isEditMode) {
      final payload = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assigned_to': _assignedToController.text.trim(),
        'due_date': _dueDate?.toIso8601String(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
      };

      try {
        await TaskRepository().updateTask(
          taskId: widget.task!.id,
          payload: payload,
        );

        ref.invalidate(taskProvider);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update task'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 🧠 CREATE MODE → Step 2: Save task
    if (_showPreview) {
      final payload = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assigned_to': _assignedToController.text.trim(),
        'due_date': _dueDate?.toIso8601String(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
      };

      try {
        await ref.read(createTaskProvider(payload).future);

        ref.invalidate(taskProvider);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save task'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 🧠 CREATE MODE → Step 1: Analyze
    setState(() => _isSubmitting = true);

    final analyzePayload = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'assigned_to': _assignedToController.text.trim(),
      'due_date': _dueDate?.toIso8601String(),
    };

    try {
      final result =
          await ref.read(createTaskProvider(analyzePayload).future);

      setState(() {
        _previewData = result;
        _showPreview = true;
        _selectedCategory = result['category'];
        _selectedPriority = result['priority'];
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to analyze task'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // -------------------------------
  // 🧱 UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Task' : 'Create Task',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration:
                      const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                ),

                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _dueDate == null
                        ? 'Select Due Date'
                        : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  ),
                  trailing:
                      const Icon(Icons.calendar_today),
                  onTap: _pickDueDate,
                ),

                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(
                      labelText: 'Assigned To'),
                ),

                const SizedBox(height: 16),

                if (_showPreview && _previewData != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Auto Classification Preview',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Category: ${_previewData!['category']}'),
                          Text(
                              'Priority: ${_previewData!['priority']}'),
                        ],
                      ),
                    ),
                  ),

                if (_showPreview)
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Override Classification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                            labelText: 'Category'),
                        items: const [
                          'scheduling',
                          'finance',
                          'technical',
                          'safety',
                          'general',
                        ]
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                            labelText: 'Priority'),
                        items: const ['high', 'medium', 'low']
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPriority = v),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditMode
                                ? 'Update Task'
                                : _showPreview
                                    ? 'Save Task'
                                    : 'Analyze',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
