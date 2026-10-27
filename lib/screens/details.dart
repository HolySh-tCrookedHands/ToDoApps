import 'package:ToDo/models/task.dart';
import 'package:flutter/material.dart';

class Details extends StatelessWidget {
  const Details({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final TaskModel item;
  final Future<bool> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Задача №${item.id}')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(item.name),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Описание'),
            const SizedBox(height: 10),
            Text(item.desc),
            const SizedBox(height: 20),
            Text('Дата создания: ${item.date}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final deleted = await onDelete(item.id);
                  if (!context.mounted) return;
                  if (deleted) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Не удалось удалить задачу')),
                    );
                  }
                },
                child: const Text('Удалить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
