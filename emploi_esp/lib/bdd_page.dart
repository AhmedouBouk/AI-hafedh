import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseData {
  final String codeEM;
  final String titre;
  final int creditsEM;
  final int cm;
  final int td;
  final int tp;
  final int? mp;
  final int? vhtEM;
  final String profCM;
  final String profTD;
  final String profTP;
  final String? profMP;
  final String salleCM;
  final String salleTP;

  CourseData({
    required this.codeEM,
    required this.titre,
    required this.creditsEM,
    required this.cm,
    required this.td,
    required this.tp,
    this.mp,
    this.vhtEM,
    required this.profCM,
    required this.profTD,
    required this.profTP,
    this.profMP,
    required this.salleCM,
    required this.salleTP,
  });
}

class BDDPage extends StatefulWidget {
  const BDDPage({super.key});

  @override
  State<BDDPage> createState() => _BDDPageState();
}

class _BDDPageState extends State<BDDPage> {
  String _searchQuery = '';
  String _sortBy = 'code';
  bool _ascending = true;
  final _scrollController = ScrollController();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFF3949AB);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color accentColor = Color(0xFF2962FF);

  final List<CourseData> courses = [
    CourseData(
      codeEM: 'IRT31',
      titre: 'Développement JEE',
      creditsEM: 3,
      cm: 6,
      td: 6,
      tp: 12,
      profCM: 'Aboubecrine',
      profTD: 'Aboubecrine',
      profTP: 'Aboubecrine',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'IRT32',
      titre: 'Intelligence artificielle',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'Hafedh',
      profTD: 'Hafedh',
      profTP: 'Hafedh',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'IRT33',
      titre: 'Théorie des langages et compilation',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'Hafedh',
      profTD: 'Hafedh',
      profTP: 'Hafedh',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'IRT34',
      titre: 'Communications numériques',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'El Aoun',
      profTD: 'El Aoun',
      profTP: 'Moktar/Elhacen',
      salleCM: '104',
      salleTP: 'Labo IRT',
    ),
    CourseData(
      codeEM: 'IRT35',
      titre: 'Architecture des ordinateurs',
      creditsEM: 3,
      cm: 8,
      td: 8,
      tp: 8,
      profCM: 'Sass',
      profTD: 'Sass',
      profTP: 'Sass',
      salleCM: '104',
      salleTP: 'Lab Electro.',
    ),
    CourseData(
      codeEM: 'IRT36',
      titre: 'Réseaux mobiles',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'Moktar',
      profTD: 'Moktar',
      profTP: 'Moktar',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'IRT37',
      titre: 'Réseaux d\'opérateurs',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'El Aoun',
      profTD: 'El Aoun',
      profTP: 'El Aoun',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'IRT38',
      titre: 'IoT',
      creditsEM: 2,
      cm: 5,
      td: 5,
      tp: 6,
      profCM: 'Elhacen',
      profTD: 'Elhacen',
      profTP: 'Elhacen',
      salleCM: '104',
      salleTP: '104',
    ),
    CourseData(
      codeEM: 'PIE',
      titre: 'Projet industriel en Entreprise (PIE)',
      creditsEM: 2,
      cm: 0,
      td: 24,
      tp: 0,
      vhtEM: 48,
      profCM: 'Enseignants du dpt.',
      profTD: 'Enseignants du dpt.',
      profTP: 'Enseignants du dpt.',
      profMP: 'Enseignants du dpt.',
      salleCM: '104',
      salleTP: '104',
    ),
  ];

  List<CourseData> get filteredAndSortedCourses {
    return courses
        .where((course) =>
            course.codeEM.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.profCM.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
      ..sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'code':
            comparison = a.codeEM.compareTo(b.codeEM);
            break;
          case 'titre':
            comparison = a.titre.compareTo(b.titre);
            break;
          case 'credits':
            comparison = a.creditsEM.compareTo(b.creditsEM);
            break;
          default:
            comparison = 0;
        }
        return _ascending ? comparison : -comparison;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildSortingHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: filteredAndSortedCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredAndSortedCourses[index];
                  return _buildCourseCard(course);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, secondaryColor],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par code, titre ou professeur...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      title: Text(
        'Base de Données',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSortingHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Trier par:',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          _buildSortButton('code', 'Code'),
          _buildSortButton('titre', 'Titre'),
          _buildSortButton('credits', 'Crédits'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String sortType, String label) {
    bool isSelected = _sortBy == sortType;

    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? accentColor.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () => _updateSort(sortType),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? accentColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 4),
              Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateSort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _ascending = !_ascending;
      } else {
        _sortBy = sortBy;
        _ascending = true;
      }
    });
  }

  Widget _buildCourseCard(CourseData course) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(16),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.codeEM,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                course.titre,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${course.creditsEM}',
                    style: GoogleFonts.inter(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          _buildDetailSection(
            'Volume horaire',
            [
              _buildDetailRow('CM', '${course.cm}h'),
              _buildDetailRow('TD', '${course.td}h'),
              _buildDetailRow('TP', '${course.tp}h'),
              if (course.vhtEM != null)
                _buildDetailRow('VHT', '${course.vhtEM}h'),
            ],
          ),
          Divider(height: 24),
          _buildDetailSection(
            'Professeurs',
            [
              _buildDetailRow('CM', course.profCM),
              _buildDetailRow('TD', course.profTD),
              _buildDetailRow('TP', course.profTP),
              if (course.profMP != null) _buildDetailRow('MP', course.profMP!),
            ],
          ),
          Divider(height: 24),
          _buildDetailSection(
            'Salles',
            [
              _buildDetailRow('CM', course.salleCM),
              _buildDetailRow('TP', course.salleTP),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        ...details,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 16),
          Container(
            width: 40,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
