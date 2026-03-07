import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cubits/search_cubit.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // To prevent dialog from closing when clicking inside
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Buscar libros, materias, autores...",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF003870)),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.tune, size: 30),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                          tooltip: 'Filtros',
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.grey[200],
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<SearchCubit>().search(query: _searchController.text);
                        Navigator.pop(context); // Close overlay after search
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003870),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<SearchCubit>(context),
          child: const _FilterDialog(),
        );
      },
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog();

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
    String? _selectedCarrera;
  String? _selectedMateria;
  String _selectedTransaccion = 'Todos';

  final List<String> _carreras = ['Ingeniería Informática', 'Ingeniería Civil', 'Derecho', 'Psicología'];
  final List<String> _materias = ['Cálculo I', 'Programación II', 'Derecho Romano', 'Psicología General'];
  final List<String> _transacciones = ['Todos', 'Venta', 'Intercambio', 'Donación'];


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Filtros de Búsqueda', textAlign: TextAlign.center),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown('Carrera', _carreras, _selectedCarrera, (val) {
              setState(() => _selectedCarrera = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Materia', _materias, _selectedMateria, (val) {
              setState(() => _selectedMateria = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Tipo de Transacción', _transacciones, _selectedTransaccion, (val) {
              if (val != null) {
                setState(() => _selectedTransaccion = val);
              }
            }, isRequired: true),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: ElevatedButton(
            onPressed: () {
              context.read<SearchCubit>().search(
                carrera: _selectedCarrera,
                materia: _selectedMateria,
                transaccion: _selectedTransaccion == 'Todos' ? null : _selectedTransaccion,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003870),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Aplicar Filtros'),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text('Seleccionar ${label.toLowerCase()}'),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired ? (value) => value == null ? 'Campo requerido' : null : null,
    );
  }
}