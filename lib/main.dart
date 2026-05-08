import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransformX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      ),
      home: const ConverterPage(),
    );
  }
}

enum ConversionType { temperature, length, weight }

class UnitOption {
  const UnitOption({required this.label, required this.symbol});

  final String label;
  final String symbol;
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _inputController = TextEditingController(
    text: '1',
  );

  ConversionType _type = ConversionType.temperature;
  int _fromIndex = 0;
  int _toIndex = 1;
  String _result = '0';

  final Map<ConversionType, List<UnitOption>> _units = {
    ConversionType.temperature: const [
      UnitOption(label: 'Celsius', symbol: 'C'),
      UnitOption(label: 'Fahrenheit', symbol: 'F'),
      UnitOption(label: 'Kelvin', symbol: 'K'),
    ],
    ConversionType.length: const [
      UnitOption(label: 'Meter', symbol: 'm'),
      UnitOption(label: 'Kilometer', symbol: 'km'),
      UnitOption(label: 'Centimeter', symbol: 'cm'),
      UnitOption(label: 'Mile', symbol: 'mi'),
      UnitOption(label: 'Foot', symbol: 'ft'),
    ],
    ConversionType.weight: const [
      UnitOption(label: 'Kilogram', symbol: 'kg'),
      UnitOption(label: 'Gram', symbol: 'g'),
      UnitOption(label: 'Pound', symbol: 'lb'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final value = double.tryParse(
      _inputController.text.trim().replaceAll(',', '.'),
    );
    if (value == null) {
      setState(() {
        _result = 'Entrée invalide';
      });
      return;
    }

    final converted = _convertValue(value, _type, _fromIndex, _toIndex);
    setState(() {
      _result = _formatNumber(converted);
    });
  }

  double _convertValue(double value, ConversionType type, int from, int to) {
    if (from == to) {
      return value;
    }

    switch (type) {
      case ConversionType.temperature:
        final celsius = switch (from) {
          0 => value,
          1 => (value - 32) * 5 / 9,
          2 => value - 273.15,
          _ => value,
        };
        return switch (to) {
          0 => celsius,
          1 => celsius * 9 / 5 + 32,
          2 => celsius + 273.15,
          _ => celsius,
        };
      case ConversionType.length:
        const metersFactor = [1.0, 1000.0, 0.01, 1609.344, 0.3048];
        final inMeters = value * metersFactor[from];
        return inMeters / metersFactor[to];
      case ConversionType.weight:
        const kilosFactor = [1.0, 0.001, 0.45359237];
        final inKilos = value * kilosFactor[from];
        return inKilos / kilosFactor[to];
    }
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Erreur';
    }

    final fixed = value.toStringAsFixed(6);
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _typeLabel(ConversionType type) {
    return switch (type) {
      ConversionType.temperature => 'Temperature',
      ConversionType.length => 'Longueur',
      ConversionType.weight => 'Poids',
    };
  }

  @override
  Widget build(BuildContext context) {
    final options = _units[_type]!;

    return Scaffold(
      appBar: AppBar(title: const Text('TransformX')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ConversionType>(
              segments: ConversionType.values
                  .map(
                    (type) => ButtonSegment<ConversionType>(
                      value: type,
                      label: Text(_typeLabel(type)),
                    ),
                  )
                  .toList(),
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  _fromIndex = 0;
                  _toIndex = 1;
                });
                _convert();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('inputField'),
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valeur a convertir',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'De',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButton<int>(
                      key: const Key('fromUnitDropdown'),
                      value: _fromIndex,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (var i = 0; i < options.length; i++)
                          DropdownMenuItem<int>(
                            value: i,
                            child: Text(options[i].label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _fromIndex = value;
                        });
                        _convert();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Vers',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButton<int>(
                      key: const Key('toUnitDropdown'),
                      value: _toIndex,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (var i = 0; i < options.length; i++)
                          DropdownMenuItem<int>(
                            value: i,
                            child: Text(options[i].label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _toIndex = value;
                        });
                        _convert();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      key: const Key('resultText'),
                      '$_result ${options[_toIndex].symbol}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
