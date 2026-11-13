import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/rest_client/error_simulator.dart';

/// Выбор имитируемой ошибки — чтобы показать все состояния экрана импорта.
class ErrorSimulationSelector extends StatefulWidget {
  const ErrorSimulationSelector({super.key});

  @override
  State<ErrorSimulationSelector> createState() => _ErrorSimulationSelectorState();
}

class _ErrorSimulationSelectorState extends State<ErrorSimulationSelector> {
  final _interceptor = getIt<ErrorSimulationInterceptor>();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SimulatedError>(
      value: _interceptor.mode,
      decoration: softInput('Проверка ошибок', icon: Icons.bug_report_outlined),
      borderRadius: BorderRadius.circular(16),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Pastel.ink, fontSize: 14),
      items: [
        for (final mode in SimulatedError.values) DropdownMenuItem(value: mode, child: Text(mode.label)),
      ],
      onChanged: (mode) {
        if (mode == null) return;
        setState(() => _interceptor.mode = mode);
      },
    );
  }
}
