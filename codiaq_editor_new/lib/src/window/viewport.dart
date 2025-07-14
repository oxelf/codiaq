class Viewport {
  int topLine; // line number of topmost visible line
  int height; // number of visible lines
  double pixelHeight = 0.0;
  double pixelWidth = 0.0;
  double scrollOffsetY = 0.0; // vertical scroll offset in pixels
  double scrollOffsetX = 0.0; // horizontal scroll offset in pixels

  Viewport({required this.topLine, required this.height});

  void scroll(int lines) {
    topLine = (topLine + lines).clamp(0, 1 << 30);
  }
}
