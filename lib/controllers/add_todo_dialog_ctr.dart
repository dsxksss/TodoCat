import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';

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
  static final _logger = Logger();
  final formKey = GlobalKey<FormState>();
  final titleFormCtrl = TextEditingController();
  final descriptionFormCtrl = TextEditingController();
  final tagController = TextEditingController();

  final selectedTags = <String>[].obs;
  final selectedPriority = TodoPriority.lowLevel.obs;
  final remindersValue = 0.obs;
  final remindersText = "".obs;

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
      showToast(titleError, toastStyleType: TodoCatToastStyleType.error);
      return false;
    }

    final descriptionError =
        _formValidator.validateDescription(descriptionFormCtrl.text);
    if (descriptionError != null) {
      _logger.w('Description validation failed: $descriptionError');
      showToast(descriptionError, toastStyleType: TodoCatToastStyleType.error);
      return false;
    }

    return formKey.currentState!.validate();
  }

  bool isDataEmpty() {
    return selectedTags.isEmpty &&
        titleFormCtrl.text.isEmpty &&
        descriptionFormCtrl.text.isEmpty &&
        tagController.text.isEmpty &&
        remindersValue.value == 0;
  }

  bool isDataNotEmpty() => !isDataEmpty();

  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      _logger.d('Removing tag at index $index: ${selectedTags[index]}');
      selectedTags.removeAt(index);
    } else {
      _logger.w('Invalid tag index for removal: $index');
    }
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
  }

  @override
  void onClose() {
    _logger.d('Cleaning up AddTodoDialogController resources');
    titleFormCtrl.dispose();
    descriptionFormCtrl.dispose();
    tagController.dispose();
    super.onClose();
  }
}
