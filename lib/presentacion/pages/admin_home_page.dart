import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import 'gestion_publicaciones_page.dart';
import 'gestion_usuarios_page.dart';
import 'solicitudes_carrera_page.dart';
import 'gestion_reportes_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _totalLibros = 0;
  int _totalUsuarios = 0;
  int _totalIntercambios = 0;
  int _totalVentas = 0;
  Map<String, int> _categorias = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final librosSnapshot = await _firestore.collection('libros').get();
      final usuariosSnapshot = await _firestore.collection('usuarios').get();
      final usersSnapshot = await _firestore.collection('users').get();

      // Combinar ambos conteos para diagnóstico
      final totalUsuarios =
          usuariosSnapshot.docs.length + usersSnapshot.docs.length;

      int intercambios = 0;
      int ventas = 0;
      Map<String, int> categorias = {};

      for (final doc in librosSnapshot.docs) {
        final data = doc.data();
        final tipo = data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
        if (tipo == 'Intercambio') {
          intercambios++;
        } else {
          ventas++;
        }

        final materia = data['materia'] as String? ?? 'Otros';
        categorias[materia] = (categorias[materia] ?? 0) + 1;
      }

      if (!mounted) return;
      setState(() {
        _totalLibros = librosSnapshot.docs.length;
        _totalUsuarios = totalUsuarios;
        _totalIntercambios = intercambios;
        _totalVentas = ventas;
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error al obtener datos del dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF003870)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 32),
                  _buildAdminActions(context),
                  const SizedBox(height: 40),
                  _buildSummaryGrid(),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildRecentActivityCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildPieChartCard()),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildTopCategoriasCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Administrativo',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estadísticas y análisis en tiempo real de la plataforma BookSwap',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildActionButton(
          context,
          'Gestionar Publicaciones',
          Icons.library_books_outlined,
          const Color(0xFF1976D2),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GestionPublicacionesPage(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Gestionar Usuarios',
          Icons.people_outline,
          const Color(0xFF2E7D32),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GestionUsuariosPage(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Solicitudes de Carrera',
          Icons.assignment_ind_outlined,
          Colors.orange,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SolicitudesCarreraPage(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Gestión de Reportes',
          Icons.flag_outlined,
          Colors.redAccent,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GestionReportesPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            _totalLibros.toString(),
            'Total Libros',
            'Publicaciones activas',
            Icons.book_outlined,
            const Color(0xFFE3F2FD),
            const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            _totalUsuarios.toString(),
            'Usuarios Registrados',
            'Usuarios en plataforma',
            Icons.people_outline,
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            _totalVentas.toString(),
            'Publicaciones de Venta',
            'Libros en venta',
            Icons.attach_money,
            const Color(0xFFE1F5FE),
            const Color(0xFF0288D1),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            _totalIntercambios.toString(),
            'Intercambios',
            'Libros para intercambio',
            Icons.sync,
            const Color(0xFFFBE9E7),
            const Color(0xFFD84315),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    String trend,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  trend,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Últimas publicaciones en la plataforma',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('libros')
                .orderBy('fechaCreacion', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No hay publicaciones recientes.',
                    style: GoogleFonts.inter(color: Colors.black45),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final tipo =
                      data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (data['imageUrl'] != null &&
                                  (data['imageUrl'] as String).isNotEmpty)
                              ? Image.network(
                                  data['imageUrl'] as String,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[600],
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['titulo'] ?? 'Sin título',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${data['autor'] ?? 'Sin autor'} • $tipo',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (data['precio'] != null && tipo != 'Intercambio')
                          Text(
                            '\$ ${data['precio']}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1976D2),
                            ),
                          ),
                        if (tipo == 'Intercambio')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Trueque',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    final sortedCategorias = _categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategorias = sortedCategorias.take(5).toList();

    final List<Color> colores = [
      const Color(0xFF1976D2),
      const Color(0xFF009688),
      const Color(0xFFFFA000),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución por Materia',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          if (topCategorias.isEmpty)
            Center(
              child: Text(
                'Sin datos disponibles',
                style: GoogleFonts.inter(color: Colors.black45),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: PieChartPainter(
                    values: topCategorias
                        .map((e) => e.value.toDouble())
                        .toList(),
                    colors: colores,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(topCategorias.length, (i) {
                return _buildSimpleLegend(
                  '${topCategorias[i].key} (${topCategorias[i].value})',
                  colores[i % colores.length],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopCategoriasCard() {
    final sortedCategorias = _categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen por Materia',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cantidad de publicaciones por cada materia registrada',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 24),
          if (sortedCategorias.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No hay datos de materias disponibles.',
                  style: GoogleFonts.inter(color: Colors.black45),
                ),
              ),
            )
          else
            ...sortedCategorias.map((entry) {
              final percentage = _totalLibros > 0
                  ? (entry.value / _totalLibros * 100).toStringAsFixed(1)
                  : '0.0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${entry.value} publicaciones ($percentage%)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _totalLibros > 0
                            ? entry.value / _totalLibros
                            : 0,
                        backgroundColor: const Color(0xFFE8EAF0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1976D2),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSimpleLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    double startAngle = -0.5 * 3.14159;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * 3.14159;
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
