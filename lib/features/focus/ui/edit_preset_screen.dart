import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../../../core/ui/app_background.dart';
import '../controller/presets_controller.dart';
import '../model/presets.dart';

class EditPresetScreen extends StatefulWidget {
  const EditPresetScreen({
    super.key,
    required this.presetsController,
    this.preset,
    this.createFromPreset = false,
  });

  final PresetsController presetsController;
  final FocusPreset? preset;
  final bool createFromPreset;

  @override
  State<EditPresetScreen> createState() => _EditPresetScreenState();
}

class _EditPresetScreenState extends State<EditPresetScreen> {
  late final TextEditingController _nameController;
  late int _focusMinutes;
  late int _breakMinutes;
  late bool _autoStartNextFocus;

  bool get _isEditing => widget.preset != null && !widget.createFromPreset;

  @override
  void initState() {
    super.initState();
    final preset = widget.preset;
    _nameController = TextEditingController(
      text: preset?.name ?? '',
    );
    _focusMinutes = ((preset?.focusSeconds ?? 1500) / 60).round();
    _breakMinutes = ((preset?.breakSeconds ?? 300) / 60).round();
    _autoStartNextFocus = preset?.autoStartNextFocus ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isEditing ? loc.t('edit_preset') : loc.t('create_preset'),
        ),
      ),
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: SafeArea(
          bottom: false,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(appBackgroundAsset(context)),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
              _CardBlock(
                child: Column(
                  children: [
                    _FieldRow(
                      title: loc.t('preset_name'),
                      child: CupertinoTextField(
                        controller: _nameController,
                        placeholder: loc.t('preset_name_placeholder'),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.black),
                        placeholderStyle: const TextStyle(
                          color: Color(0xFF6B6F8C),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    _DividerLine(),
                    _PickerRow(
                      title: loc.t('focus_minutes'),
                      value: '$_focusMinutes',
                      onTap: () => _pickMinutes(
                        context: context,
                        title: loc.t('focus_minutes'),
                        initial: _focusMinutes,
                        onSelected: (value) => setState(() => _focusMinutes = value),
                        min: 1,
                        max: 240,
                      ),
                    ),
                    _DividerLine(),
                    _PickerRow(
                      title: loc.t('break_minutes'),
                      value: '$_breakMinutes',
                      onTap: () => _pickMinutes(
                        context: context,
                        title: loc.t('break_minutes'),
                        initial: _breakMinutes,
                        onSelected: (value) => setState(() => _breakMinutes = value),
                        min: 0,
                        max: 120,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CardBlock(
                child: Column(
                  children: [
                    _SwitchRow(
                      title: loc.t('auto_start_next_focus'),
                      value: _autoStartNextFocus,
                      onChanged: (value) => setState(() => _autoStartNextFocus = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: _savePreset,
                borderRadius: BorderRadius.circular(16),
                child: Text(
                  loc.t('save'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CupertinoButton(
                    onPressed: _deletePreset,
                    child: Text(
                      loc.t('delete_preset'),
                      style: const TextStyle(color: CupertinoColors.systemRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickMinutes({
    required BuildContext context,
    required String title,
    required int initial,
    required ValueChanged<int> onSelected,
    required int min,
    required int max,
  }) async {
    int tempValue = initial;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        onSelected(tempValue);
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context).t('save')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: (initial - min).clamp(0, max - min),
                  ),
                  itemExtent: 36,
                  onSelectedItemChanged: (index) {
                    tempValue = min + index;
                  },
                  children: List.generate(
                    max - min + 1,
                    (index) => Center(
                      child: Text(
                        '${min + index}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePreset() async {
    final loc = AppLocalizations.of(context);
    final name = _nameController.text.trim().isEmpty
        ? loc.t('custom_preset')
        : _nameController.text.trim();

    final existing = widget.preset;
    final preset = FocusPreset(
      id: _isEditing
          ? existing!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      focusSeconds: _focusMinutes * 60,
      breakSeconds: _breakMinutes * 60,
      isBuiltIn: false,
      isPremium: true,
      autoStartBreak: true,
      autoStartNextFocus: _autoStartNextFocus,
      whiteNoiseSoundId: existing?.whiteNoiseSoundId,
      reminderProfileId: existing?.reminderProfileId,
    );

    if (_isEditing) {
      await widget.presetsController.updatePreset(preset);
    } else {
      await widget.presetsController.createPreset(preset);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deletePreset() async {
    final preset = widget.preset;
    if (preset == null) return;
    await widget.presetsController.deletePreset(preset.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE2E4F0)),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2138),
            ),
          ),
        ),
        SizedBox(width: 210, child: child),
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2138),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2138),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFF9AA0C8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2138),
            ),
          ),
        ),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
