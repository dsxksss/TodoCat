/// 默认背景模板
class DefaultBackground {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isVideo; // 是否为视频背景
  final String? downloadUrl; // 视频下载URL（仅用于需要下载的视频）
  
  const DefaultBackground({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isVideo = false,
    this.downloadUrl,
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
    DefaultBackground(
      id: 'background_4',
      name: '背景4',
      description: '',
      imageUrl: 'assets/imgs/background_4.jpg',
    ),
    DefaultBackground(
      id: 'background_5',
      name: '背景5',
      description: '',
      imageUrl: 'assets/imgs/background_5.jpg',
    ),
    DefaultBackground(
      id: 'video_background_3',
      name: '视频背景3',
      description: '',
      imageUrl: 'assets/videos/video_background_3.mp4',
      isVideo: true,
      downloadUrl: 'https://www.pexels.com/zh-cn/download/video/2869091/',
    ),
    DefaultBackground(
      id: 'video_background_1',
      name: '视频背景1',
      description: '',
      imageUrl: 'assets/videos/video_background_1.mp4',
      isVideo: true,
      downloadUrl: 'https://cdn.pixabay.com/video/2025/11/07/314643_small.mp4',
    ),
    DefaultBackground(
      id: 'video_background_2',
      name: '视频背景2',
      description: '',
      imageUrl: 'assets/videos/video_background_2.mp4',
      isVideo: true,
      downloadUrl: 'https://cdn.pixabay.com/video/2025/09/22/305657_tiny.mp4',
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
