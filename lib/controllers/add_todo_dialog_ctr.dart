import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class TagService {
  static const int maxTags = 3;

  bool canAddTag(List<String> currentTags, String newTag) {
    return currentTags.length < maxTags && newTag.isNotEmpty;
  }

  String? validateNewTag(List<String> currentTags, String newTag) {
    if (newTag.isEmpty) {
      return 'tagEmpty'.tr;
    }
    if (currentTags.length >= maxTags) {
      return 'tagsUpperLimit'.tr;
    }
    if (currentTags.contains(newTag)) {
      return 'tagDuplicate'.tr;
    }
    return null;
  }
}

class FormValidator {
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'titleRequired'.tr;
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'descriptionRequired'.tr;
    }
    return null;
  }
}

class AddTodoDialogController extends GetxController {
  static final Map<String, Map<String, dynamic>> _dialogCache = {};
  final String dialogId = DateTime.now().millisecondsSinceEpoch.toString();

  static final _logger = Logger();
  final formKey = GlobalKey<FormState>();
  final titleFormCtrl = TextEditingController();
  final descriptionFormCtrl = TextEditingController();
  final tagController = TextEditingController();

  final selectedTags = <String>[].obs;
  final selectedPriority = TodoPriority.lowLevel.obs;
  final remindersValue = 0.obs;
  final remindersText = "".obs;
  final selectedDate = Rx<DateTime?>(null);

  late final TagService _tagService;
  late final FormValidator _formValidator;

  bool get hasUnsavedChanges => isDataNotEmpty();

  AddTodoDialogController() {
    _tagService = TagService();
    _formValidator = FormValidator();
  }

  @override
  void onInit() {
    super.onInit();
    _logger.i('Initializing AddTodoDialogController');

    if (_dialogCache.containsKey(dialogId)) {
      final cache = _dialogCache[dialogId]!;
      titleFormCtrl.text = cache['title'] ?? '';
      descriptionFormCtrl.text = cache['description'] ?? '';
      selectedTags.value = List<String>.from(cache['tags'] ?? []);
      selectedDate.value = cache['date'];
      selectedPriority.value = TodoPriority.values[cache['priority'] ?? 0];
      remindersValue.value = cache['reminders'] ?? 0;
    }

    ever(selectedTags, (_) => _updateCache());
    ever(selectedDate, (_) => _updateCache());
    ever(selectedPriority, (_) => _updateCache());
    ever(remindersValue, (_) => _updateCache());

    titleFormCtrl.addListener(_updateCache);
    descriptionFormCtrl.addListener(_updateCache);
  }

  void _updateCache() {
    _dialogCache[dialogId] = {
      'title': titleFormCtrl.text,
      'description': descriptionFormCtrl.text,
      'tags': selectedTags.toList(),
      'date': selectedDate.value,
      'priority': selectedPriority.value.index,
      'reminders': remindersValue.value,
    };
  }

  void addTag() {
    _logger.d('Attempting to add tag: ${tagController.text}');
    final newTag = tagController.text.trim();
    final validationError = _tagService.validateNewTag(selectedTags, newTag);

    if (validationError != null) {
      _logger.w('Tag validation failed: $validationError');
      showToast(
        validationError,
        toastStyleType: TodoCatToastStyleType.warning,
      );
      return;
    }

    _logger.d('Adding new tag: $newTag');
    selectedTags.add(newTag);
    tagController.clear();
  }

  bool validateForm() {
    _logger.d('Validating form');
    if (formKey.currentState == null) {
      _logger.w('Form key current state is null');
      return false;
    }

    final titleError = _formValidator.validateTitle(titleFormCtrl.text);
    if (titleError != null) {
      _logger.w('Title validation failed: $titleError');
      showToast('Title validation failed: $titleError',
          toastStyleType: TodoCatToastStyleType.error);
      return false;
    }

    return true;
  }

  Future<bool> submitForm() async {
    if (!validateForm()) {
      return false;
    }

    final todo = Todo()
      ..uuid = const Uuid().v4()
      ..title = titleFormCtrl.text
      ..description = descriptionFormCtrl.text
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tags = selectedTags.toList()
      ..priority = selectedPriority.value
      ..status = TodoStatus.todo
      ..finishedAt = 0
      ..reminders = remindersValue.value;

    try {
      final bool isSuccess = await Get.find<HomeController>().addTodo(todo);
      if (isSuccess) {
        clearForm();
        return true;
      }
    } catch (e) {
      _logger.e('Error submitting todo: $e');
    }
    return false;
  }

  bool isDataEmpty() {
    return selectedTags.isEmpty &&
        titleFormCtrl.text.isEmpty &&
        descriptionFormCtrl.text.isEmpty &&
        tagController.text.isEmpty &&
        remindersValue.value == 0;
  }

  bool isDataNotEmpty() {
    return titleFormCtrl.text.isNotEmpty ||
        descriptionFormCtrl.text.isNotEmpty ||
        selectedTags.isNotEmpty ||
        selectedDate.value != null ||
        selectedPriority.value != TodoPriority.lowLevel ||
        remindersValue.value != 0;
  }

  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      _logger.d('Removing tag at index $index: ${selectedTags[index]}');
      selectedTags.removeAt(index);
    } else {
      _logger.w('Invalid tag index for removal: $index');
    }
  }

  void saveCache() {
    _logger.d('Saving form cache');
    _updateCache();
  }

  void clearCache() {
    _logger.d('Clearing form cache');
    _dialogCache.remove(dialogId);
  }

  void clearForm() {
    _logger.d('Clearing form data');
    titleFormCtrl.clear();
    descriptionFormCtrl.clear();
    tagController.clear();
    selectedTags.clear();
    selectedPriority.value = TodoPriority.lowLevel;
    remindersText.value = "${"enter".tr}${"time".tr}";
    remindersValue.value = 0;
    selectedDate.value = null;
    clearCache();
  }

  @override
  void onClose() {
    _logger.d('Cleaning up AddTodoDialogController resources');
    titleFormCtrl.removeListener(_updateCache);
    descriptionFormCtrl.removeListener(_updateCache);
    titleFormCtrl.dispose();
    descriptionFormCtrl.dispose();
    tagController.dispose();
    super.onClose();
  }
}
