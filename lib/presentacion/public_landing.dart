import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../logic/auth_cubit.dart';
import 'login_screen.dart';
import 'como_funciona_page.dart';
import 'beneficios_page.dart';
import 'preguntas_frecuentes_page.dart';
import 'centro_de_ayuda_page.dart';
import 'politicas_de_uso_page.dart';
import 'contacto_page.dart';
import 'terminos_y_condiciones_page.dart';
import 'privacidad_page.dart';
import 'cookies_page.dart';

class PublicLanding extends StatefulWidget {
  const PublicLanding({super.key});

  @override
  State<PublicLanding> createState() => _PublicLandingState();
}

class _PublicLandingState extends State<PublicLanding> {
  final GlobalKey _howItWorksKey = GlobalKey();

  // Defaults si Firestore está vacío o falla
  int totalStudents = 500;
  int totalMaterials = 1200;
  double satisfaction = 95.0;

  bool _statsLoading = false;
  bool _disposed = false;

  void _log(String msg) => debugPrint("[PublicLanding] $msg");

  @override
  void initState() {
    super.initState();
    _log("initState()");
    _loadStatistics();
  }

  @override
  void dispose() {
    _disposed = true;
    _log("dispose()");
    super.dispose();
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Future<void> _loadStatistics() async {
    if (_statsLoading) return;
    _statsLoading = true;

    _log("📊 _loadStatistics(): iniciando...");

    try {
      final fs = FirebaseFirestore.instance;

      final usersSnap = await fs.collection('users').get();
      final materialsSnap = await fs.collection('materials').get();
      final reviewsSnap = await fs.collection('reviews').get();

      _log("📌 users docs: ${usersSnap.docs.length}");
      _log("📌 materials docs: ${materialsSnap.docs.length}");
      _log("📌 reviews docs: ${reviewsSnap.docs.length}");

      double avgRatingPercent = 0.0;
      if (reviewsSnap.docs.isNotEmpty) {
        double total = 0.0;
        for (final doc in reviewsSnap.docs) {
          total += _toDouble(doc.data()['rating']);
        }
        avgRatingPercent = (total / reviewsSnap.docs.length) * 20.0; // 0..5 -> 0..100
      }

      if (!mounted || _disposed) {
        _log("⚠️ Widget desmontado → no setState()");
        return;
      }

      setState(() {
        totalStudents = usersSnap.docs.isNotEmpty ? usersSnap.docs.length : 500;
        totalMaterials = materialsSnap.docs.isNotEmpty ? materialsSnap.docs.length : 1200;
        satisfaction = avgRatingPercent > 0 ? avgRatingPercent : 95.0;
      });

      _log("✅ Stats OK: students=$totalStudents, materials=$totalMaterials, satisfaction=$satisfaction");
    } catch (e, st) {
      _log("❌ Error cargando estadísticas: $e");
      _log("🧾 $st");
    } finally {
      _statsLoading = false;
    }
  }

  /// 🔥 NAVEGACIÓN ROBUSTA: mantiene el MISMO AuthCubit en el nuevo Route
  void _pushWithSameCubit(Widget page, {String? tag}) {
    final cubit = context.read<AuthCubit>();
    _log("➡️ push ${tag ?? page.runtimeType} (preservando AuthCubit)");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: page,
        ),
      ),
    );
  }

  void _goLogin() => _pushWithSameCubit(const LoginScreen(), tag: "LoginScreen");

  void _openPage(String label, Widget page) => _pushWithSameCubit(page, tag: label);

  void _scrollToHowItWorks() {
    final ctx = _howItWorksKey.currentContext;
    if (ctx == null) {
      _log("⚠️ No se pudo scrollear: howItWorks context null");
      return;
    }
    _log("🧭 Scroll → HowItWorks");
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Widget _safeAsset(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? radius,
  }) {
    final img = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stack) {
        _log("❌ Asset error ($path): $error");
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: const Color(0xFFE5E7EB),
          child: const Icon(Icons.broken_image, size: 40, color: Colors.black45),
        );
      },
    );

    if (radius == null) return img;
    return ClipRRect(borderRadius: radius, child: img);
  }

  @override
  Widget build(BuildContext context) {
    _log("build()");
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildBodySection(context),
                Container(key: _howItWorksKey, child: _buildHowItWorksSection()),
                _buildBenefitsSection(),
                _buildCTASection(),
                _buildFooter(),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: _safeAsset(
                  'assets/sdi.assets.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BookSwap',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  Text(
                    'Sistema de Intercambio Académico',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _goLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: Text(
              'Iniciar Sesión',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BODY
  Widget _buildBodySection(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1024;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBodyContent()),
                const SizedBox(width: 60),
                Expanded(child: _buildBodyImage()),
              ],
            )
          : Column(
              children: [
                _buildBodyContent(),
                const SizedBox(height: 40),
                _buildBodyImage(),
              ],
            ),
    );
  }

  Widget _buildBodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Plataforma Universitaria Oficial',
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Intercambia y Vende\nMaterial Académico con\nConfianza',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'La plataforma institucional para estudiantes que facilita el intercambio de libros, apuntes y material académico de forma segura y verificada.',
          style: TextStyle(fontSize: 18, color: Color(0xFF6B7280), height: 1.6),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton(
              onPressed: _goLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
              child: const Text(
                'Comenzar Ahora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: _scrollToHowItWorks,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                side: const BorderSide(color: Color(0xFF1976D2), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Conoce Más',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 40,
          runSpacing: 16,
          children: [
            _buildStatItem('$totalStudents+', 'Estudiantes Activos'),
            _buildStatItem('$totalMaterials+', 'Materiales Disponibles'),
            _buildStatItem('${satisfaction.toStringAsFixed(0)}%', 'Satisfacción'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildBodyImage() {
    final radius = BorderRadius.circular(24);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _safeAsset(
            'assets/imagen1_landingpage.jpeg',
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            radius: radius,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF1976D2), size: 24),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('100% Verificado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Solo usuarios institucionales', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HOW IT WORKS
  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            '¿Cómo Funciona?',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tres pasos simples para comenzar a intercambiar material académico',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;

              final steps = [
                _buildStepCard(
                  Icons.search,
                  '1. Busca Material',
                  'Encuentra libros, apuntes y material académico que necesitas para tus materias. Filtra por carrera, semestre y asignatura.',
                  const Color(0xFFE3F2FD),
                ),
                _buildStepCard(
                  Icons.swap_horiz,
                  '2. Intercambia o Compra',
                  'Elige entre intercambiar tu material o comprarlo a precios justos. Contacta directamente con otros estudiantes verificados.',
                  const Color(0xFFE8F5E9),
                ),
                _buildStepCard(
                  Icons.people,
                  '3. Construye Reputación',
                  'Recibe y deja reseñas después de cada transacción. Construye tu perfil de confianza en la comunidad estudiantil.',
                  const Color(0xFFFFF3E0),
                ),
              ];

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: steps[0]),
                    const SizedBox(width: 24),
                    Expanded(child: steps[1]),
                    const SizedBox(width: 24),
                    Expanded(child: steps[2]),
                  ],
                );
              }

              return Column(
                children: [
                  steps[0],
                  const SizedBox(height: 24),
                  steps[1],
                  const SizedBox(height: 24),
                  steps[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(IconData icon, String title, String description, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: const Color(0xFF1976D2)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // BENEFITS
  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildBenefitsList()),
                    const SizedBox(width: 60),
                    Expanded(child: _buildBenefitsImage()),
                  ],
                )
              : Column(
                  children: [
                    _buildBenefitsList(),
                    const SizedBox(height: 40),
                    _buildBenefitsImage(),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ahorra Dinero y Ayuda al\nMedio Ambiente',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        _buildBenefitItem(
          Icons.trending_up,
          'Reduce Costos Académicos',
          'Ahorra hasta un 70% en material académico comparado con compras nuevas.',
          const Color(0xFFE3F2FD),
        ),
        const SizedBox(height: 24),
        _buildBenefitItem(
          Icons.shield,
          'Seguridad Garantizada',
          'Solo estudiantes verificados con correo institucional pueden participar.',
          const Color(0xFFE8F5E9),
        ),
        const SizedBox(height: 24),
        _buildBenefitItem(
          Icons.recycling,
          'Economía Circular',
          'Da una segunda vida a tus libros y reduce el impacto ambiental.',
          const Color(0xFFFFF3E0),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description, Color bgColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsImage() {
    final radius = BorderRadius.circular(24);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: _safeAsset(
        'assets/imagen2_landingpage.jpeg',
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
        radius: radius,
      ),
    );
  }

  // CTA
  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF00BCD4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              '¿Listo para Comenzar?',
              style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Únete a cientos de estudiantes que ya están ahorrando y compartiendo conocimiento',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _goLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: const Text(
                'Iniciar Sesión Ahora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FOOTER
  Widget _buildFooter() {
    // ✅ IMPORTANTE: QUITÉ const AQUÍ para evitar tus errores “const_with_non_const”
    // Funcionalidad y navegación intactas.
    final platformItems = [
      {'label': 'Cómo Funciona', 'page': ComoFuncionaPage()},
      {'label': 'Beneficios', 'page': BeneficiosPage()},
      {'label': 'Preguntas Frecuentes', 'page': PreguntasFrecuentesPage()},
    ];

    final supportItems = [
      {'label': 'Centro de Ayuda', 'page': CentroDeAyudaPage()},
      {'label': 'Políticas de Uso', 'page': PoliticasDeUsoPage()},
      {'label': 'Contacto', 'page': ContactoPage()},
    ];

    final legalItems = [
      {'label': 'Términos y Condiciones', 'page': TerminosYCondicionesPage()},
      {'label': 'Privacidad', 'page': PrivacidadPage()},
      {'label': 'Cookies', 'page': CookiesPage()},
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFooterColumn('Plataforma', platformItems)),
                    Expanded(child: _buildFooterColumn('Soporte', supportItems)),
                    Expanded(child: _buildFooterColumn('Legal', legalItems)),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterBrand(),
                  const SizedBox(height: 24),
                  _buildFooterColumn('Plataforma', platformItems),
                  const SizedBox(height: 24),
                  _buildFooterColumn('Soporte', supportItems),
                  const SizedBox(height: 24),
                  _buildFooterColumn('Legal', legalItems),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            '© 2025 SDI BookSwap. Sistema de Intercambio Académico. Todos los derechos reservados.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: Color(0xFF1976D2), size: 32),
            SizedBox(width: 8),
            Text(
              'SDI BookSwap',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Sistema de Intercambio y Venta de Material\nAcadémico Institucional',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          final label = item['label'] as String;
          final page = item['page'] as Widget;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _openPage(label, page),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}