class CauseModel {
  final String id;
  final String title;
  const CauseModel(this.id, this.title);

  @override
  bool operator ==(other) {
    return (other is CauseModel) && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
