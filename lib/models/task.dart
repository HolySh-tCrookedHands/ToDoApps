class TaskModel {
  const TaskModel({
    required this.id,
    required this.name,
    required this.status,
    required this.desc,
    required this.date,
  });

  final int id;
  final String name;
  final bool status;
  final String desc;
  final String date;

  TaskModel copyWith({bool? status}) => TaskModel(
        id: id,
        name: name,
        status: status ?? this.status,
        desc: desc,
        date: date,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'desc': desc,
        'date': date,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as int,
        name: json['name'] as String,
        status: json['status'] as bool,
        desc: json['desc'] as String,
        date: json['date'] as String,
      );
}
