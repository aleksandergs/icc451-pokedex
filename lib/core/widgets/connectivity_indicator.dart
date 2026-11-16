import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/localization/strings.dart';
import '../sync/sync_state.dart';

/// Indicador global de conectividad.
class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncState? state = ref.watch(syncStateProvider).value;

    final String label = state == null
        ? AppStrings.checking
        : (state.isOnline ? AppStrings.online : AppStrings.offline);
    final _IndicatorStyle style = state == null
        ? _IndicatorStyle.checking
        : (state.isOnline ? _IndicatorStyle.online : _IndicatorStyle.offline);

    return Semantics(
      liveRegion: true,
      label: '${AppStrings.appTitle}, $label',
      child: ExcludeSemantics(
        child: Material(
          color: style.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: <Widget>[
                Icon(style.icon, size: 18, color: style.foreground),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorStyle {
  const _IndicatorStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  static const _IndicatorStyle online = _IndicatorStyle(
    icon: Icons.cloud_done_outlined,
    background: Color(0xFFDDF3E4),
    foreground: Color(0xFF10562B),
  );

  static const _IndicatorStyle offline = _IndicatorStyle(
    icon: Icons.cloud_off_outlined,
    background: Color(0xFFE6E4EB),
    foreground: Color(0xFF3B3540),
  );

  static const _IndicatorStyle checking = _IndicatorStyle(
    icon: Icons.hourglass_empty,
    background: Color(0xFFE7E7EA),
    foreground: Color(0xFF3A3A40),
  );

  final IconData icon;
  final Color background;
  final Color foreground;
}
