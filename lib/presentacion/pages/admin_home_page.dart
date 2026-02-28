import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart'; // Asegúrate de que la ruta a tu widget sea correcta

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // USAMOS TU CUSTOM APP BAR CON CEREBRO DE NAVEGACIÓN
      appBar: const CustomAppBar(), 
      body: SingleChildScrollView(
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
                Expanded(flex: 3, child: _buildLineChartCard()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildPieChartCard()),
              ],
            ),
            const SizedBox(height: 40),
            _buildBarChartCard(),
          ],
        ),
      ),
    );
  }

  // --- SECCIÓN DE TÍTULO ---
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
          'Estadísticas y análisis de la plataforma BookSwap',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  // --- BOTONES DE ACCIÓN RÁPIDA ---
  Widget _buildAdminActions(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          'Gestionar Publicaciones',
          Icons.library_books_outlined,
          const Color(0xFF1976D2),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context,
          'Gestionar Usuarios',
          Icons.people_outline,
          const Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Acción: $label (No implementado)')),
        );
      },
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

  // --- TARJETAS DE RESUMEN (MÉTRICAS) ---
  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            '324',
            'Total Libros',
            '+12% este mes',
            Icons.book_outlined,
            const Color(0xFFE3F2FD),
            const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            '1,249',
            'Usuarios Activos',
            '+8% este mes',
            Icons.people_outline,
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            '\$8.4M',
            'Valor Transaccionado',
            '+24% este mes',
            Icons.attach_money,
            const Color(0xFFE1F5FE),
            const Color(0xFF0288D1),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            '567',
            'Intercambios Realizados',
            '+18% este mes',
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
              Icon(Icons.trending_up, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- GRÁFICOS (PAINTERS) ---
  Widget _buildLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 400,
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
            'Tendencia Mensual',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(painter: LineChartPainter()),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Intercambios', const Color(0xFF009688)),
              const SizedBox(width: 24),
              _buildLegendItem('Ventas', const Color(0xFF1976D2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 400,
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
          Center(
            child: Container(
              width: 220,
              height: 220,
              child: CustomPaint(painter: PieChartPainter()),
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildSimpleLegend('Matemáticas', const Color(0xFF1976D2)),
              _buildSimpleLegend('Física', const Color(0xFF009688)),
              _buildSimpleLegend('Informática', const Color(0xFFFFA000)),
              _buildSimpleLegend('Química', const Color(0xFF9C27B0)),
              _buildSimpleLegend('Otros', const Color(0xFFE91E63)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
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
            'Top 5 Libros Más Vendidos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBar('Cálculo', 45, 22),
                _buildBar('Física', 38, 30),
                _buildBar('Química', 32, 18),
                _buildBar('Algoritmos', 28, 25),
                _buildBar('Literatura', 22, 35),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Intercambios', const Color(0xFF009688)),
              const SizedBox(width: 24),
              _buildLegendItem('Ventas', const Color(0xFF1976D2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double val1, double val2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: val1 * 5,
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: val2 * 5,
              decoration: const BoxDecoration(
                color: Color(0xFF009688),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
        ),
      ],
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

// --- CLASES PAINTER (SIN CAMBIOS) ---
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = const Color(0xFF009688)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.4, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.6, size.height * 0.55, size.width * 0.8, size.height * 0.3);
    path1.lineTo(size.width, size.height * 0.2);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(size.width * 0.2, size.height * 0.8, size.width * 0.4, size.height * 0.65);
    path2.quadraticBezierTo(size.width * 0.6, size.height * 0.68, size.width * 0.8, size.height * 0.5);
    path2.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);

    final gridPaint = Paint()..color = Colors.black.withOpacity(0.05)..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paints = [
      Paint()..color = const Color(0xFF1976D2),
      Paint()..color = const Color(0xFF009688),
      Paint()..color = const Color(0xFFFFA000),
      Paint()..color = const Color(0xFF9C27B0),
      Paint()..color = const Color(0xFFE91E63),
    ];
    double startAngle = -0.5 * 3.14;
    final angles = [1.2, 0.8, 1.0, 0.6, 0.6];
    for (int i = 0; i < angles.length; i++) {
      canvas.drawArc(rect, startAngle, angles[i], true, paints[i]);
      startAngle += angles[i];
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}