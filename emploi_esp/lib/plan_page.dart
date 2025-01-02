import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionData {
  final String code;
  final String type;
  final bool isEmpty;
  final bool isSpecial;
  final String specialText;

  SessionData({
    this.code = '',
    this.type = '',
    this.isEmpty = true,
    this.isSpecial = false,
    this.specialText = '',
  });
}

class DaySchedule {
  final List<SessionData> p1;
  final List<SessionData> p2;
  final List<SessionData> p3;
  final List<SessionData> p4;
  final List<SessionData> p5;

  DaySchedule({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.p5,
  });
}

class PlanPage extends StatelessWidget {
  PlanPage({super.key});

  // Modern color scheme
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFF3949AB);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  final Map<String, Color> typeColors = {
    'CM': Color(0xFFE3F2FD),
    'TP': Color(0xFFE8F5E9),
    'TD': Color(0xFFF3E5F5),
    'DV': Color(0xFFFFEBEE),
  };

  final Map<String, IconData> typeIcons = {
    'CM': Icons.school_outlined,
    'TP': Icons.engineering_outlined,
    'TD': Icons.edit_note_outlined,
    'DV': Icons.assignment_outlined,
  };

  final Map<String, DaySchedule> schedule = {
    'Lundi': DaySchedule(
      p1: [
        SessionData(type: 'CM', code: 'IRT31', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT32', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT36', isEmpty: false),
      ],
      p2: [
        SessionData(type: 'CM', code: 'IRT37', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT37', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT36', isEmpty: false),
      ],
      p3: [
        SessionData(type: 'CM', code: 'IRT33', isEmpty: false),
        SessionData(type: 'TP', code: 'IRT31', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT38', isEmpty: false),
      ],
      p4: [
        SessionData(type: 'CM', code: 'IRT34', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT34', isEmpty: false),
        SessionData(type: 'CM', code: 'IRT34', isEmpty: false),
      ],
      p5: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
    ),
    'Mardi': DaySchedule(
      p1: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
      p2: [
        SessionData(),
        SessionData(),
        SessionData(isSpecial: true, specialText: 'Soutenance Stage'),
      ],
      p3: [
        SessionData(),
        SessionData(),
        SessionData(isSpecial: true, specialText: 'Soutenance Stage'),
      ],
      p4: [
        SessionData(type: 'CM', code: 'IRT31', isEmpty: false),
        SessionData(type: 'TD', code: 'IRT34', isEmpty: false),
        SessionData(type: 'TD', code: 'IRT36', isEmpty: false),
      ],
      p5: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
    ),
    'Mercredi': DaySchedule(
      p1: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
      p2: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
      p3: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
      p4: [
        SessionData(isSpecial: true, specialText: 'Encadrement militaire'),
        SessionData(isSpecial: true, specialText: 'Encadrement militaire'),
        SessionData(isSpecial: true, specialText: 'Encadrement militaire'),
      ],
      p5: [
        SessionData(),
        SessionData(),
        SessionData(),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
        ],
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _buildColumnHeaders(),
                ...schedule.entries
                    .map((entry) => _buildDayRow(entry.key, entry.value)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
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
      title: Text(
        'Plan des études',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => _showLegend(context),
        ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      margin: EdgeInsets.all(16),
      width: 800,
      decoration: BoxDecoration(
        color: Colors.white,
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
          SizedBox(
            width: 120,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Jour',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildHeaderCell('S1'),
                _buildHeaderCell('S2'),
                _buildHeaderCell('S3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(String day, DaySchedule schedule) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: 800,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPeriodRow(day, 'P1', schedule.p1),
          _buildPeriodRow('', 'P2', schedule.p2),
          _buildPeriodRow('', 'P3', schedule.p3),
          _buildPeriodRow('', 'P4', schedule.p4),
          _buildPeriodRow('', 'P5', schedule.p5),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(
      String day, String period, List<SessionData> sessions) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (day.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        day,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      period,
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: sessions
                    .map((session) => _buildSessionCell(session))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCell(SessionData session) {
    if (session.isEmpty) {
      return Expanded(
        child: Container(
          height: 80,
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
        ),
      );
    }

    if (session.isSpecial) {
      return Expanded(
        child: Container(
          height: 80,
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 20, color: Colors.orange[700]),
              SizedBox(height: 4),
              Flexible(
                child: Text(
                  session.specialText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        height: 80,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: typeColors[session.type],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: typeColors[session.type]!.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              typeIcons[session.type],
              size: 20,
              color: secondaryColor,
            ),
            SizedBox(height: 4),
            Text(
              session.type,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              session.code,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Légende',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(
                'CM - Cours Magistral', typeColors['CM']!, typeIcons['CM']!),
            _buildLegendItem(
                'TP - Travaux Pratiques', typeColors['TP']!, typeIcons['TP']!),
            _buildLegendItem(
                'TD - Travaux Dirigés', typeColors['TD']!, typeIcons['TD']!),
            _buildLegendItem(
                'DV - Devoir', typeColors['DV']!, typeIcons['DV']!),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.inter(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: secondaryColor),
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
