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
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    constraints: const BoxConstraints(maxWidth: 700),
                    padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
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
                                  hintText: "Buscar por título, autor...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF003870),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F4F7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(
                                Icons.filter_list_rounded,
                                size: 28,
                              ),
                              onPressed: () => _showFilterDialog(context),
                              tooltip: 'Filtros',
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(16),
                                backgroundColor: const Color(0xFFF2F4F7),
                                foregroundColor: const Color(0xFF003870),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<SearchCubit>().search(
                              query: _searchController.text,
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.search_rounded),
                          label: const Text(
                            'Buscar',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003870),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                            shadowColor: const Color(
                              0xFF003870,
                            ).withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -20,
                    left: -20, // Changed from right to left
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons
                              .arrow_back_rounded, // Changed from Icons.close_rounded
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
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

  // In a real app, these would come from a remote source
  final List<String> _carreras = [
    'Ingeniería Informática',
    'Ingeniería Civil',
    'Derecho',
    'Psicología',
  ];
  final List<String> _materias = [
    'Cálculo I',
    'Programación II',
    'Derecho Romano',
    'Psicología General',
  ];
  final List<String> _transacciones = [
    'Todos',
    'Venta',
    'Intercambio',
    'Donación',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.filter_list_rounded, color: Color(0xFF003870)),
              SizedBox(width: 8),
              Text('Filtros de Búsqueda'),
            ],
          ),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown(
              'Carrera',
              Icons.school_outlined,
              _carreras,
              _selectedCarrera,
              (val) => setState(() => _selectedCarrera = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Materia',
              Icons.book_outlined,
              _materias,
              _selectedMateria,
              (val) => setState(() => _selectedMateria = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Tipo de Transacción',
              Icons.swap_horiz_outlined,
              _transacciones,
              _selectedTransaccion,
              (val) => setState(() => _selectedTransaccion = val ?? 'Todos'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: () {
              context.read<SearchCubit>().search(
                carrera: _selectedCarrera,
                materia: _selectedMateria,
                transaccion: _selectedTransaccion == 'Todos'
                    ? null
                    : _selectedTransaccion,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003870),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: const Color(0xFF003870).withOpacity(0.4),
            ),
            child: const Text(
              'Aplicar Filtros',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text('Seleccionar ${label.toLowerCase()}'),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
