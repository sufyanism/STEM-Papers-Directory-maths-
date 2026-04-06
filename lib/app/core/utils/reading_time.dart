int estimateReadingTime(String text) {
  final words = text.split(" ").length;
  return (words / 200).ceil();
}