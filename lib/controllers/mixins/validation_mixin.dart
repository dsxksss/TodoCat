import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';

/// 数据验证Mixin
/// 提供常用的验证方法
mixin ValidationMixin {
  /// 验证必填字段
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName}Required'.tr;
    }
    return null;
  }

  /// 验证邮箱格式
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'emailRequired'.tr;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'emailInvalid'.tr;
    }
    
    return null;
  }

  /// 验证密码强度
  String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'passwordRequired'.tr;
    }
    
    if (value.length < minLength) {
      return 'passwordTooShort'.tr;
    }
    
    return null;
  }

  /// 验证数字范围
  String? validateNumberRange(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return 'numberRequired'.tr;
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'numberInvalid'.tr;
    }
    
    if (number < min || number > max) {
      return 'numberOutOfRange'.trParams({'min': min.toString(), 'max': max.toString()});
    }
    
    return null;
  }

  /// 验证文本长度
  String? validateTextLength(String? value, {int? minLength, int? maxLength}) {
    value ??= '';
    
    if (minLength != null && value.length < minLength) {
      return 'textTooShort'.trParams({'min': minLength.toString()});
    }
    
    if (maxLength != null && value.length > maxLength) {
      return 'textTooLong'.trParams({'max': maxLength.toString()});
    }
    
    return null;
  }

  /// 显示验证错误提示
  void showValidationError(String message) {
    showToast(message, toastStyleType: TodoCatToastStyleType.warning);
  }
}

/// 数据缓存Mixin
/// 提供数据缓存和恢复功能
mixin CacheMixin<T> on GetxController {
  static final Map<String, Map<String, dynamic>> _globalCache = {};
  
  String get cacheKey => '${runtimeType}_$hashCode';
  
  /// 保存数据到缓存
  void saveToCache(Map<String, dynamic> data) {
    _globalCache[cacheKey] = Map<String, dynamic>.from(data);
  }
  
  /// 从缓存恢复数据
  Map<String, dynamic>? restoreFromCache() {
    return _globalCache[cacheKey];
  }
  
  /// 清除缓存
  void clearCache() {
    _globalCache.remove(cacheKey);
  }
  
  /// 检查是否有缓存数据
  bool hasCachedData() {
    return _globalCache.containsKey(cacheKey);
  }
  
  /// 获取缓存数据的特定字段
  V? getCachedValue<V>(String key) {
    final cache = _globalCache[cacheKey];
    return cache?[key] as V?;
  }
  
  /// 设置缓存数据的特定字段
  void setCachedValue<V>(String key, V value) {
    _globalCache[cacheKey] ??= {};
    _globalCache[cacheKey]![key] = value;
  }
  
  @override
  void onClose() {
    clearCache();
    super.onClose();
  }
}