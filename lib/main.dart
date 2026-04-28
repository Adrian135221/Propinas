import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculadoraPropinasApp());
}

/// Punto de entrada de la aplicación. Define el tema global Indigo y Slate.
class CalculadoraPropinasApp extends StatelessWidget {
  const CalculadoraPropinasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Propinas Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          // 'surfaceVariant' is deprecated. Use 'surfaceContainerHighest' instead.
          surfaceContainerHighest: const Color(0xFF1E293B), // Slate 800 (Contenedores)
          surface: const Color(0xFF0F172A), // Slate 900 (Fondo principal)
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(color: Color(0xFF94A3B8)), // Slate 400
        ),
      ),
      home: const PantallaCalculadora(),
    );
  }
}

/// Pantalla principal que maneja el estado y la lógica de la calculadora.
class PantallaCalculadora extends StatefulWidget {
  const PantallaCalculadora({super.key});

  @override
  State<PantallaCalculadora> createState() => _PantallaCalculadoraState();
}

class _PantallaCalculadoraState extends State<PantallaCalculadora> {
  // Variables de estado
  double _montoFactura = 0.0;
  int _porcentajePropina = 15;
  int _cantidadPersonas = 1;
  bool _esPersonalizado = false;
  double _porcentajeCustom = 0.0;

  // Controladores para los campos de texto
  final TextEditingController _controladorMonto = TextEditingController();
  final TextEditingController _controladorPropinaCustom = TextEditingController();

  // Lógica de cálculo
  double get _porcentajeActual => _esPersonalizado ? _porcentajeCustom : _porcentajePropina.toDouble();
  double get _propinaTotal => _montoFactura * (_porcentajeActual / 100);
  double get _montoTotalFinal => _montoFactura + _propinaTotal;
  double get _totalPorPersona => _montoTotalFinal / _cantidadPersonas;

  @override
  void dispose() {
    _controladorMonto.dispose();
    _controladorPropinaCustom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector para ocultar el teclado al tocar fuera
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Calculadora de Propinas'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de Resultado Principal
              _construirTarjetaResultado(),
              const SizedBox(height: 32),

              // Sección de Entrada de Monto
              _construirSeccionEtiqueta('Monto de la Cuenta'),
              const SizedBox(height: 8),
              _construirCampoMonto(),
              const SizedBox(height: 24),

              // Sección de Porcentaje de Propina
              _construirSeccionEtiqueta('Porcentaje de Propina'),
              const SizedBox(height: 12),
              _construirSelectorPropina(),
              const SizedBox(height: 24),

              // Sección de Cantidad de Personas
              _construirSeccionEtiqueta('Dividir entre'),
              const SizedBox(height: 12),
              _construirSelectorPersonas(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget que muestra el resultado final destacado.
  Widget _construirTarjetaResultado() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // FIX: Reemplazado Colors.indigo.withOpacity(0.3) con Colors.indigo.withAlpha(77)
            // (0.3 * 255).round() = 76.5.round() = 77
            color: Colors.indigo.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total por Persona',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              '\$${_totalPorPersona.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _construirInfoMini(
                'Propina Total',
                '\$${_propinaTotal.toStringAsFixed(2)}',
              ),
              _construirInfoMini(
                'Cuenta + Propina',
                '\$${_montoTotalFinal.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para mostrar información secundaria en la tarjeta.
  Widget _construirInfoMini(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Etiqueta estilizada para las secciones.
  Widget _construirSeccionEtiqueta(String texto) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Campo de entrada para el monto total.
  Widget _construirCampoMonto() {
    return TextField(
      controller: _controladorMonto,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: const TextStyle(fontSize: 20, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.attach_money, color: Colors.indigo),
        hintText: '0.00',
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onChanged: (valor) {
        setState(() {
          _montoFactura = double.tryParse(valor) ?? 0.0;
        });
      },
    );
  }

  /// Selector de porcentaje usando ChoiceChips y opción personalizada.
  Widget _construirSelectorPropina() {
    final porcentajes = [10, 15, 20, 25];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...porcentajes.map((porcentaje) {
              final seleccionado = !_esPersonalizado && _porcentajePropina == porcentaje;
              return ChoiceChip(
                label: Text('$porcentaje%'),
                selected: seleccionado,
                onSelected: (bool valor) {
                  setState(() {
                    _esPersonalizado = false;
                    _porcentajePropina = porcentaje;
                  });
                },
                selectedColor: Colors.indigo,
                backgroundColor: const Color(0xFF1E293B),
                labelStyle: TextStyle(
                  color: seleccionado ? Colors.white : Colors.white70,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide.none,
              );
            }),
            ChoiceChip(
              label: const Text('Otro'),
              selected: _esPersonalizado,
              onSelected: (bool valor) {
                setState(() {
                  _esPersonalizado = true;
                });
              },
              selectedColor: Colors.indigo,
              backgroundColor: const Color(0xFF1E293B),
              labelStyle: TextStyle(
                color: _esPersonalizado ? Colors.white : Colors.white70,
                fontWeight: _esPersonalizado ? FontWeight.bold : FontWeight.normal,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          ],
        ),
        if (_esPersonalizado) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _controladorPropinaCustom,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ingresa porcentaje (0-100)',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              suffixText: '%',
              suffixStyle: const TextStyle(color: Colors.indigo),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (valor) {
              double? numero = double.tryParse(valor);
              setState(() {
                if (numero != null && numero <= 100) {
                  _porcentajeCustom = numero;
                } else if (numero != null && numero > 100) {
                  _porcentajeCustom = 100.0;
                  _controladorPropinaCustom.text = '100';
                  _controladorPropinaCustom.selection = TextSelection.fromPosition(
                    const TextPosition(offset: 3),
                  );
                } else {
                  _porcentajeCustom = 0.0;
                }
              });
            },
          ),
        ],
      ],
    );
  }

  /// Selector de cantidad de personas con botones + y -.
  Widget _construirSelectorPersonas() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _cantidadPersonas > 1
                ? () => setState(() => _cantidadPersonas--)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.indigo,
            disabledColor: Colors.white10,
          ),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                '$_cantidadPersonas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _cantidadPersonas == 1 ? 'Persona' : 'Personas',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _cantidadPersonas++),
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}