import 'package:flutter/material.dart';

import 'data/task_repository.dart';
import 'models/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocalTaskManagerApp());
}

class LocalTaskManagerApp extends StatelessWidget {
  const LocalTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Local Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C8C)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: const TaskHomePage(),
      );
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final _titleController = TextEditingController();
  final _repository = TaskRepository.instance;
  List<Task> _tasks = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _repository.getAll();
      if (!mounted) return;
      setState(() => _tasks = tasks);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is UnsupportedError) return error.message.toString();
    return 'The database operation failed. Please try again. Details: $error';
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Enter a task title before adding it.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _repository.create(title);
      _titleController.clear();
      await _loadTasks();
      if (mounted && _error == null) _showMessage('Task saved.');
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleTask(Task task, bool completed) async {
    try {
      await _repository.setCompleted(task, completed);
      await _loadTasks();
      if (mounted && _error == null) {
        _showMessage(completed ? 'Task marked as completed.' : 'Task marked as pending.');
      }
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error));
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _repository.delete(task.id);
      await _loadTasks();
      if (mounted && _error == null) _showMessage('Task deleted.');
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Task Manager', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.checklist_rounded, color: Colors.white, size: 38),
                      const SizedBox(height: 12),
                      const Text('Make room for what matters.',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '$completedCount of ${_tasks.length} tasks completed · Saved locally on this device',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Add a task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addTask(),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Finish mobile development activity',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _addTask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(child: Text('Your tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                    IconButton(onPressed: _loadTasks, tooltip: 'Refresh tasks', icon: const Icon(Icons.refresh_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  _InfoPanel(icon: Icons.storage_rounded, title: 'Storage is unavailable', message: _error!)
                else if (_tasks.isEmpty)
                  const _InfoPanel(
                    icon: Icons.task_alt_rounded,
                    title: 'No tasks yet',
                    message: 'Add your first task above. Saved tasks will still be here after you reopen the app.',
                  )
                else
                  ..._tasks.map((task) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => _toggleTask(task, value ?? false),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text(task.isCompleted ? 'Completed' : 'Pending'),
                          trailing: IconButton(
                            tooltip: 'Delete task',
                            onPressed: () => _deleteTask(task),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                      )),
                const SizedBox(height: 12),
                const Text(
                  'Tasks are stored in a local SQLite database. No account or internet connection is required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
}
