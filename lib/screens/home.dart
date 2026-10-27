import 'dart:convert';

import 'package:ToDo/models/settings.dart';
import 'package:ToDo/screens/details.dart';
import 'package:ToDo/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;

  const HomeScreen({super.key, required this.settings});

  @override
  State<HomeScreen> createState() => _StateHomeScreen();
}

class _StateHomeScreen extends State<HomeScreen> {
  static const String tasksKey = 'todo_tasks';

  List<TaskModel> taskLists = [];
  bool isLoading = true;

  // Последовательно выполняем сохранения,
  // чтобы быстрые изменения не перезаписывали друг друга.
  Future<void> _pendingSave = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Загрузка задач из локального хранилища
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(tasksKey);

      final List<TaskModel> tasks;

      if (stored == null) {
        tasks = [
          const TaskModel(
            id: 0,
            name: 'сдать долг по MySql',
            status: false,
            desc: 'Нужно в срочном порядке сдать ПЗ по MySql',
            date: '22.10.2026',
          ),
        ];

        await prefs.setString(
          tasksKey,
          jsonEncode(tasks.map((t) => t.toJson()).toList()),
        );
      } else {
        tasks = (jsonDecode(stored) as List<dynamic>)
            .map(
              (json) => TaskModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      if (!mounted) return;

      setState(() {
        taskLists = tasks;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось загрузить сохранённые задачи'),
        ),
      );
    }
  }

  // Сохранение списка задач
  Future<bool> _saveTasks() {
    final snapshot = jsonEncode(
      taskLists.map((task) => task.toJson()).toList(),
    );

    final result = _pendingSave.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(tasksKey, snapshot);
    });

    _pendingSave = result.then<void>(
      (_) {},
      onError: (Object _) {},
    );

    return result;
  }

  // Удаление задачи
  Future<bool> _deleteTask(int id) async {
    final oldTasks = List<TaskModel>.from(taskLists);

    setState(() {
      taskLists.removeWhere((task) => task.id == id);
    });

    try {
      if (await _saveTasks()) return true;
    } catch (_) {
      // Восстановим список, если сохранение не удалось.
    }

    if (mounted) {
      setState(() => taskLists = oldTasks);
    }

    return false;
  }

  // Всплывающее окно добавления задачи
  Future<void> _showAddTaskDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      final data = await showDialog<
          ({String name, String description})>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Новая задача'),

          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите название задачи';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),

            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(dialogContext, (
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                ));
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      );

      if (data == null || !mounted) return;

      // Получаем текущую дату
      final now = DateTime.now();

      final date =
          '${now.day.toString().padLeft(2, '0')}.'
          '${now.month.toString().padLeft(2, '0')}.'
          '${now.year}';

      // Генерируем новый ID
      final nextId = taskLists.fold<int>(
        -1,
        (maxId, task) => task.id > maxId ? task.id : maxId,
      ) + 1;

      // Создаём новую задачу
      final task = TaskModel(
        id: nextId,
        name: data.name,
        desc: data.description,
        status: false,
        date: date,
      );

      // Добавляем задачу на экран
      setState(() {
        taskLists.add(task);
      });

      // Сохраняем задачу
      try {
        if (await _saveTasks()) return;
      } catch (_) {
        // Откатим добавление при ошибке.
      }

      if (!mounted) return;

      setState(() {
        taskLists.removeWhere(
          (item) => identical(item, task),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить новую задачу'),
        ),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
    }
  }

  // Изменение состояния задачи
  Future<void> _setTaskStatus(int id, bool status) async {
    final index = taskLists.indexWhere(
      (task) => task.id == id,
    );

    if (index == -1) return;

    final previous = taskLists[index];

    setState(() {
      taskLists[index] = previous.copyWith(status: status);
    });

    try {
      if (await _saveTasks()) return;
    } catch (_) {
      // Восстановим состояние при ошибке.
    }

    if (!mounted) return;

    final currentIndex = taskLists.indexWhere(
      (task) => task.id == id,
    );

    if (currentIndex != -1 &&
        taskLists[currentIndex].status == status) {
      setState(() {
        taskLists[currentIndex] = previous;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Не удалось сохранить состояние задачи'),
      ),
    );
  }

  // Открытие подробностей задачи
  void _openDetails(TaskModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(
          item: item,
          onDelete: _deleteTask,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    settings: widget.settings,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),

        child: Column(
          children: [
            // Кнопка добавления задачи
            ElevatedButton(
              onPressed: isLoading ? null : _showAddTaskDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Добавить задачу'),
                  Icon(Icons.add),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Задачи',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),

            const Divider(),

            // Список задач
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: taskLists.length,

                      itemBuilder: (context, index) {
                        final item = taskLists[index];

                        return Card(
                          key: ValueKey(item.id),

                          child: Row(
                            children: [
                              Checkbox(
                                value: item.status,
                                onChanged: (value) {
                                  _setTaskStatus(
                                    item.id,
                                    value ?? false,
                                  );
                                },
                              ),

                              Expanded(
                                child: ListTile(
                                  title: Text(item.name),
                                  onTap: () => _openDetails(item),
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
    );
  }
}
