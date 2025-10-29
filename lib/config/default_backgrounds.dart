/// 默认背景模板
class DefaultBackground {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  
  const DefaultBackground({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

/// 默认背景模板列表
class DefaultBackgrounds {
  static const List<DefaultBackground> templates = [
    DefaultBackground(
      id: 'background_1',
      name: '背景1',
      description: '',
      imageUrl: 'assets/imgs/background_1.jpg',
    ),
    DefaultBackground(
      id: 'background_2',
      name: '背景2',
      description: '',
      imageUrl: 'assets/imgs/background_2.jpg',
    ),
    DefaultBackground(
      id: 'background_3',
      name: '背景3',
      description: '',
      imageUrl: 'assets/imgs/background_3.jpg',
    ),
  ];
  
  /// 根据ID获取模板
  static DefaultBackground? getById(String id) {
    try {
      return templates.firstWhere((bg) => bg.id == id);
    } catch (e) {
      return null;
    }
  }
}
