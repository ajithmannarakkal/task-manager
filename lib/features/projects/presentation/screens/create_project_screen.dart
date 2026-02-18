import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/common_button.dart';
import '../../../../core/presentation/widgets/common_text.dart';
import '../../../../core/presentation/widgets/common_text_field.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  final Project? project;

  const CreateProjectScreen({super.key, this.project});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late Color _selectedColor;

  bool get isEditing => widget.project != null;

  final List<Map<String, dynamic>> _colorOptions = [
    {'color': const Color(0xFF6C63FF), 'label': 'Purple'},
    {'color': const Color(0xFF2196F3), 'label': 'Blue'},
    {'color': const Color(0xFF4CAF50), 'label': 'Green'},
    {'color': const Color(0xFFFF5722), 'label': 'Red'},
    {'color': const Color(0xFFFF9800), 'label': 'Orange'},
    {'color': const Color(0xFF009688), 'label': 'Teal'},
    {'color': const Color(0xFFE91E63), 'label': 'Pink'},
    {'color': const Color(0xFF795548), 'label': 'Brown'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? const Color(0xFF6C63FF);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        final updated = widget.project!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          color: _selectedColor,
        );
        ref.read(projectListProvider.notifier).updateProject(updated);
      } else {
        ref.read(projectListProvider.notifier).addProject(
              _nameController.text.trim(),
              _descController.text.trim(),
              _selectedColor,
            );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommonButton(
          onPressed: _saveProject,
          text: isEditing ? 'Save Changes' : 'Create Project',
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                controller: _nameController,
                labelText: 'Project Name',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Project name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: _descController,
                labelText: 'Description (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // Color Picker
              CommonText(
                'Project Color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((option) {
                  final color = option['color'] as Color;
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppTheme.textPrimary, width: 3)
                            : Border.all(color: Colors.transparent, width: 3),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Preview Card
              CommonText(
                'Preview',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _selectedColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.folder_rounded,
                          color: _selectedColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty
                                ? 'Project Name'
                                : _nameController.text,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to view tasks',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
