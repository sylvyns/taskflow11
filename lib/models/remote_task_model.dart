/// DTO (модель API): так задача приходит с сервера в JSON.
/// В Presentation эта модель не попадает — её превращают в Entity в mapper/.
class RemoteTaskModel {
  const RemoteTaskModel({required this.id, required this.title, required this.completed});

  factory RemoteTaskModel.fromJson(Map<String, dynamic> json) => RemoteTaskModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: (json['title'] as String?) ?? '',
        completed: json['completed'] == true,
      );

  final int id;
  final String title;
  final bool completed;
}
