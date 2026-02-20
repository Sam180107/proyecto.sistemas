import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  //valores por defecto si no hay datos en firebase
  int totalStudents = 500;
  int totalMaterials = 1200;
  double satisfaction = 95.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  //Estadisticas desde firebase
  Future<void> _loadStatistics() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnapshot = await firestore.collection('users').get();
      final materialsSnapshot = await firestore.collection('materials').get();
      final reviewsSnapshot = await firestore.collection('reviews').get();
      double avgRating = 0.0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] ?? 0.0) as double;
        }
        avgRating = (totalRating / reviewsSnapshot.docs.length) * 20;
      }

      setState(() {
        totalStudents = usersSnapshot.docs.isNotEmpty
            ? usersSnapshot.docs.length
            : 500;
        totalMaterials = materialsSnapshot.docs.isNotEmpty
            ? materialsSnapshot.docs.length
            : 1200;
        satisfaction = avgRating > 0 ? avgRating : 95.0;
      });
    } catch (e) {
      print('Error cargando estadísticas: $e');
    }
  }

  void _scrollToHowItWorks() {
    final context = _howItWorksKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildBodySection(context),
                Container(
                  key: _howItWorksKey,
                  child: _buildHowItWorksSection(),
                ),
                _buildBenefitsSection(),
                _buildCTASection(context),
                _buildFooter(),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),
        ],
      ),
    );
  }

  // header
  Widget _buildHeader(BuildContext context) {
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
          // Logo
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/sdi.assets.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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

  //body
  Widget _buildBodySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBodyContent(context)),
                const SizedBox(width: 60),
                Expanded(child: _buildBodyImage()),
              ],
            )
          : Column(
              children: [
                _buildBodyContent(context),
                const SizedBox(height: 40),
                _buildBodyImage(),
              ],
            ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Comenzar Ahora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: _scrollToHowItWorks,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                side: const BorderSide(color: Color(0xFF1976D2), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Conoce Más',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        Row(
          children: [
            _buildStatItem('$totalStudents+', 'Estudiantes Activos'),
            const SizedBox(width: 40),
            _buildStatItem('$totalMaterials+', 'Materiales Disponibles'),
            const SizedBox(width: 40),
            _buildStatItem(
              '${satisfaction.toStringAsFixed(0)}%',
              'Satisfacción',
            ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildBodyImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
          // Placeholder de imagen - aquí irá la imagen de la biblioteca
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/imagen1_landingpage.jpeg', // Asegúrate de que esté en tu pubspec.yaml
              height: 400,
              width: double.infinity, // Para que ocupe todo el ancho disponible
              fit: BoxFit.cover,
            ),
          ),

          //Cuadro de la imagen
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified, color: Color(0xFF1976D2), size: 24),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Verificado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Solo usuarios institucionales',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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

  //Parte Explicativa
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
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStepCard(
                        Icons.search,
                        '1. Busca Material',
                        'Encuentra libros, apuntes y material académico que necesitas para tus materias. Filtra por carrera, semestre y asignatura.',
                        const Color(0xFFE3F2FD),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildStepCard(
                        Icons.swap_horiz,
                        '2. Intercambia o Compra',
                        'Elige entre intercambiar tu material o comprarlo a precios justos. Contacta directamente con otros estudiantes verificados.',
                        const Color(0xFFE8F5E9),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildStepCard(
                        Icons.people,
                        '3. Construye Reputación',
                        'Recibe y deja reseñas después de cada transacción. Construye tu perfil de confianza en la comunidad estudiantil.',
                        const Color(0xFFFFF3E0),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStepCard(
                      Icons.search,
                      '1. Busca Material',
                      'Encuentra libros, apuntes y material académico que necesitas para tus materias. Filtra por carrera, semestre y asignatura.',
                      const Color(0xFFE3F2FD),
                    ),
                    const SizedBox(height: 24),
                    _buildStepCard(
                      Icons.swap_horiz,
                      '2. Intercambia o Compra',
                      'Elige entre intercambiar tu material o comprarlo a precios justos. Contacta directamente con otros estudiantes verificados.',
                      const Color(0xFFE8F5E9),
                    ),
                    const SizedBox(height: 24),
                    _buildStepCard(
                      Icons.people,
                      '3. Construye Reputación',
                      'Recibe y deja reseñas después de cada transacción. Construye tu perfil de confianza en la comunidad estudiantil.',
                      const Color(0xFFFFF3E0),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    IconData icon,
    String title,
    String description,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBenefitsList()),
                const SizedBox(width: 60),
                Expanded(child: _buildBenefitsImage()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildBenefitsList(),
                const SizedBox(height: 40),
                _buildBenefitsImage(),
              ],
            );
          }
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

  Widget _buildBenefitItem(
    IconData icon,
    String title,
    String description,
    Color bgColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/imagen2_landingpage.jpeg',
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  //Encima de pie de pagina
  Widget _buildCTASection(BuildContext context) {
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
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Únete a cientos de estudiantes que ya están ahorrando y compartiendo conocimiento',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Iniciar Sesión Ahora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Pie de pagina
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFooterColumn('Plataforma', [
                        {'label': 'Cómo Funciona', 'page': ComoFuncionaPage()},
                        {'label': 'Beneficios', 'page': BeneficiosPage()},
                        {
                          'label': 'Preguntas Frecuentes',
                          'page': PreguntasFrecuentesPage(),
                        },
                      ]),
                    ),
                    Expanded(
                      child: _buildFooterColumn('Soporte', [
                        {
                          'label': 'Centro de Ayuda',
                          'page': CentroDeAyudaPage(),
                        },
                        {
                          'label': 'Políticas de Uso',
                          'page': PoliticasDeUsoPage(),
                        },
                        {'label': 'Contacto', 'page': ContactoPage()},
                      ]),
                    ),
                    Expanded(
                      child: _buildFooterColumn('Legal', [
                        {
                          'label': 'Términos y Condiciones',
                          'page': TerminosYCondicionesPage(),
                        },
                        {'label': 'Privacidad', 'page': PrivacidadPage()},
                        {'label': 'Cookies', 'page': CookiesPage()},
                      ]),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterBrand(),
                    const SizedBox(height: 24),
                    _buildFooterColumn('Plataforma', [
                      {'label': 'Cómo Funciona', 'page': ComoFuncionaPage()},
                      {'label': 'Beneficios', 'page': BeneficiosPage()},
                      {
                        'label': 'Preguntas Frecuentes',
                        'page': PreguntasFrecuentesPage(),
                      },
                    ]),
                    const SizedBox(height: 24),
                    _buildFooterColumn('Soporte', [
                      {'label': 'Centro de Ayuda', 'page': CentroDeAyudaPage()},
                      {
                        'label': 'Políticas de Uso',
                        'page': PoliticasDeUsoPage(),
                      },
                      {'label': 'Contacto', 'page': ContactoPage()},
                    ]),
                    const SizedBox(height: 24),
                    _buildFooterColumn('Legal', [
                      {
                        'label': 'Términos y Condiciones',
                        'page': TerminosYCondicionesPage(),
                      },
                      {'label': 'Privacidad', 'page': PrivacidadPage()},
                      {'label': 'Cookies', 'page': CookiesPage()},
                    ]),
                  ],
                );
              }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
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
        const SizedBox(height: 12),
        const Text(
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['page']),
                );
              },
              child: Text(
                item['label'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
