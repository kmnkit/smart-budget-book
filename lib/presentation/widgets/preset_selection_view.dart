import 'package:flutter/material.dart';
import 'package:zan/core/constants/country_presets.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/core/extensions/enum_l10n_extensions.dart';
import 'package:zan/generated/l10n/app_localizations.dart';

class PresetSelectionView extends StatelessWidget {
  const PresetSelectionView({
    super.key,
    required this.country,
    required this.selectedIndices,
    required this.onToggle,
  });

  final CountryPreset country;
  final Set<int> selectedIndices;
  final void Function(int) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final groupedByType = <AccountType, List<MapEntry<int, PresetAccount>>>{};
    for (var i = 0; i < country.accounts.length; i++) {
      final account = country.accounts[i];
      groupedByType.putIfAbsent(account.type, () => []).add(MapEntry(i, account));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: groupedByType.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key.label(l10n),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...entry.value.map((mapEntry) {
              final index = mapEntry.key;
              final account = mapEntry.value;
              final isSelected = selectedIndices.contains(index);
              final localizedName = account.localizedName(locale);
              final showSubtitle = locale != 'en' && localizedName != account.nameEn;
              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => onToggle(index),
                title: Text(localizedName),
                subtitle: showSubtitle ? Text(account.nameEn) : null,
                secondary: Icon(
                  Icons.circle,
                  color: Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
                  size: 24,
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
