import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/config/ai_config.dart';
import 'package:todo_cat/services/ai_settings_service.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';

/// AI / LLM 配置对话框：填写 DeepSeek API Key / Base URL / Model。
///
/// 保存后立即生效（写入本地 `ai_config.json` 并应用到全局 OpenAI 客户端），
/// 无需重启应用。
class AiConfigDialog extends StatefulWidget {
  const AiConfigDialog({super.key});

  static const tag = 'ai_config_dialog';

  @override
  State<AiConfigDialog> createState() => _AiConfigDialogState();
}

class _AiConfigDialogState extends State<AiConfigDialog> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;

  bool _obscureKey = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final service = AiSettingsService.to;
    _apiKeyController = TextEditingController(text: service.apiKey);
    _baseUrlController = TextEditingController(text: service.baseUrl);
    _modelController = TextEditingController(text: service.model);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_apiKeyController.text.trim().isEmpty) {
      showToast(l10n.aiApiKeyRequired,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      await AiSettingsService.to.save(
        apiKey: _apiKeyController.text,
        baseUrl: _baseUrlController.text,
        model: _modelController.text,
      );
      showToast(l10n.aiConfigSaved,
          toastStyleType: TodoCatToastStyleType.success);
      SmartDialog.dismiss(tag: AiConfigDialog.tag);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    await AiSettingsService.to.clear();
    if (!mounted) return;
    setState(() {
      _apiKeyController.text = AiSettingsService.to.apiKey;
      _baseUrlController.text = AiSettingsService.to.baseUrl;
      _modelController.text = AiSettingsService.to.model;
    });
    showToast(l10n.aiConfigCleared, toastStyleType: TodoCatToastStyleType.info);
  }

  @override
  Widget build(BuildContext context) {
    final width = context.isPhone ? 1.sw : 460.0;

    return Container(
      width: width,
      constraints: BoxConstraints(
        maxHeight: context.isPhone ? 1.sh : 620,
      ),
      padding: context.isPhone ? const EdgeInsets.only(top: 12) : null,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: context.isPhone
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: l10n.aiConfiguration,
            onCancel: () => SmartDialog.dismiss(tag: AiConfigDialog.tag),
            showConfirm: false,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(context),
                  const SizedBox(height: 20),
                  _buildLabel(context, l10n.aiApiKey),
                  const SizedBox(height: 8),
                  _buildField(
                    context,
                    controller: _apiKeyController,
                    hintText: l10n.aiApiKeyHint,
                    obscureText: _obscureKey,
                    prefixIcon: Icons.vpn_key_outlined,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: context.theme.hintColor,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, l10n.aiBaseUrl),
                  const SizedBox(height: 8),
                  _buildField(
                    context,
                    controller: _baseUrlController,
                    hintText: AiConfig.baseUrl,
                    prefixIcon: Icons.link_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, l10n.aiModel),
                  const SizedBox(height: 8),
                  _buildField(
                    context,
                    controller: _modelController,
                    hintText: AiConfig.model,
                    prefixIcon: Icons.memory_outlined,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.aiConfigStoredHint,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: context.theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : _clear,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor:
                                context.theme.textTheme.bodyMedium?.color,
                            side: BorderSide(
                              color: context.theme.dividerColor
                                  .withValues(alpha: 0.6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(l10n.clear),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.blue.shade600.withValues(alpha: 0.5),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  l10n.save,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final configured = AiSettingsService.to.isConfigured;
    final color = configured ? Colors.green : Colors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            configured ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              configured ? l10n.aiConfigured : l10n.aiNotConfigured,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.theme.textTheme.bodyMedium?.color
            ?.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffix,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: context.theme.hintColor, fontSize: 13),
        filled: true,
        fillColor: context.theme.cardColor,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 18, color: context.theme.hintColor),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: context.theme.dividerColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: context.theme.primaryColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
