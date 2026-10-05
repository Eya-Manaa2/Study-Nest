import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_provider.dart';
import '../widgets/sn_card.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final t = state.theme;
    final todos = state.todos;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Mes tâches',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: t.textColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${todos.where((t) => !t.isCompleted).length} en cours',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Todo list
            Expanded(
              child: todos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 48, color: t.accent.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune tâche',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: t.textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ajoute ta première tâche ici',
                              style: TextStyle(fontSize: 13, color: t.muted),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => _showAddTodoDialog(context, ref),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Créer une tâche'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: t.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: todos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final todo = todos[i];
                        return SnCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => ref.read(appProvider.notifier).toggleTodo(todo.id),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: todo.isCompleted ? t.accent : t.surface2,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: todo.isCompleted ? t.accent : t.line,
                                      width: 2,
                                    ),
                                  ),
                                  child: todo.isCompleted
                                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: todo.isCompleted ? t.muted : t.textColor,
                                        decoration: todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _PriorityBadge(priority: todo.priority, theme: t),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            todo.reminderTime == null
                                                ? '${todo.dueDate.day.toString().padLeft(2, '0')}/${todo.dueDate.month.toString().padLeft(2, '0')}/${todo.dueDate.year} · heure non définie'
                                                : '${todo.dueDate.day.toString().padLeft(2, '0')}/${todo.dueDate.month.toString().padLeft(2, '0')}/${todo.dueDate.year} à ${todo.reminderTime!.hour.toString().padLeft(2, '0')}:${todo.reminderTime!.minute.toString().padLeft(2, '0')}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: todo.reminderTime == null ? t.muted : t.accent,
                                              fontWeight: todo.reminderTime == null ? FontWeight.w400 : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref.read(appProvider.notifier).deleteTodo(todo.id),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: t.muted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        backgroundColor: t.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay? selectedTime;
    int selectedPriority = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle tâche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Ex: Réviser chapitre 4',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date d\'échéance'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Heure de rappel'),
                  subtitle: Text(selectedTime != null 
                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Non définie'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text('Priorité :'),
                    ),
                    ...[0, 1, 2, 3].map((p) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: ChoiceChip(
                            label: Text(
                              p == 0
                                  ? 'Faible'
                                  : p == 1
                                      ? 'Moyenne'
                                      : p == 2
                                          ? 'Haute'
                                          : 'Urgente',
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected: selectedPriority == p,
                            onSelected: (selected) => setDialogState(() => selectedPriority = p),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                await ref.read(appProvider.notifier).addTodo(
                  titleController.text.trim(),
                  selectedDate,
                  null,
                  selectedPriority,
                  reminderTime: selectedTime,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;
  final dynamic theme;

  const _PriorityBadge({required this.priority, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final colors = [
      t.surface2,
      Colors.orange.withValues(alpha: 0.8),
      Colors.red.withValues(alpha: 0.8),
      Colors.purple.withValues(alpha: 0.8),
    ];
    final labels = ['Faible', 'Moyenne', 'Haute', 'Urgente'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[priority],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labels[priority],
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
