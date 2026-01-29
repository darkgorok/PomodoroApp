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
  late bool _autoStartBreak;
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
    _autoStartBreak = preset?.autoStartBreak ?? true;
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
              CupertinoFormSection.insetGrouped(
                backgroundColor: Colors.transparent,
                margin: EdgeInsets.zero,
                children: [
                  CupertinoFormRow(
                    prefix: Text(loc.t('preset_name')),
                    child: CupertinoTextField(
                      controller: _nameController,
                      placeholder: loc.t('preset_name_placeholder'),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(loc.t('focus_minutes')),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _pickMinutes(
                        context: context,
                        title: loc.t('focus_minutes'),
                        initial: _focusMinutes,
                        onSelected: (value) => setState(() => _focusMinutes = value),
                        min: 1,
                        max: 240,
                      ),
                      child: Text('$_focusMinutes'),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(loc.t('break_minutes')),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _pickMinutes(
                        context: context,
                        title: loc.t('break_minutes'),
                        initial: _breakMinutes,
                        onSelected: (value) => setState(() => _breakMinutes = value),
                        min: 0,
                        max: 120,
                      ),
                      child: Text('$_breakMinutes'),
                    ),
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                backgroundColor: Colors.transparent,
                margin: const EdgeInsets.only(top: 8),
                children: [
                  CupertinoFormRow(
                    prefix: Text(loc.t('auto_start_break')),
                    child: CupertinoSwitch(
                      value: _autoStartBreak,
                      onChanged: (value) => setState(() => _autoStartBreak = value),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text(loc.t('auto_start_next_focus')),
                    child: CupertinoSwitch(
                      value: _autoStartNextFocus,
                      onChanged: (value) => setState(() => _autoStartNextFocus = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: _savePreset,
                borderRadius: BorderRadius.circular(16),
                child: Text(loc.t('save')),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    (index) => Center(child: Text('${min + index}')),
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
      autoStartBreak: _autoStartBreak,
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
