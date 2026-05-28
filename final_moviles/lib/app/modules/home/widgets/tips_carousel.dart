import 'dart:async';

import 'package:flutter/material.dart';

class TipsCarousel extends StatefulWidget {
  const TipsCarousel({super.key});

  @override
  State<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<TipsCarousel> {
  late final PageController _pageController;
  Timer? _timer;

  static const _tips = <_Tip>[
    _Tip(
      icon: Icons.landslide_rounded,
      color: Color(0xFFFF7043),
      categoria: 'Sismos',
      titulo: '¿Qué hacer durante un sismo?',
      descripcion: 'Cúbrete bajo una mesa sólida y aléjate de ventanas. Mantén la calma hasta que cese el movimiento.',
    ),
    _Tip(
      icon: Icons.water_rounded,
      color: Color(0xFF29B6F6),
      categoria: 'Inundaciones',
      titulo: 'Ante una inundación',
      descripcion: 'Dirígete a zonas altas de inmediato. Nunca cruces corrientes de agua: 15 cm bastan para tirarte.',
    ),
    _Tip(
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFF57C00),
      categoria: 'Incendios',
      titulo: 'Si hay humo, ve al suelo',
      descripcion: 'El aire limpio está abajo. Sal agachado, activa la alarma y nunca uses el elevador. Llama al 911.',
    ),
    _Tip(
      icon: Icons.medical_services_rounded,
      color: Color(0xFF43A047),
      categoria: 'Primeros Auxilios',
      titulo: 'Quemadura leve: agua fría',
      descripcion: 'Enfría con agua fría (no helada) por 10 minutos. Nunca apliques hielo, mantequilla ni pasta de dientes.',
    ),
    _Tip(
      icon: Icons.air_rounded,
      color: Color(0xFF7B1FA2),
      categoria: 'Atragantamiento',
      titulo: 'Maniobra de Heimlich',
      descripcion: 'Rodea el abdomen por detrás y da empujes firmes hacia arriba. Repite hasta liberar la obstrucción.',
    ),
    _Tip(
      icon: Icons.favorite_rounded,
      color: Color(0xFFE53935),
      categoria: '¿Sabías que...?',
      titulo: 'El ritmo de la RCP',
      descripcion: '"Stayin\' Alive" de los Bee Gees tiene 103 BPM, el ritmo ideal para hacer compresiones de RCP. ¡En serio!',
    ),
    _Tip(
      icon: Icons.bloodtype_rounded,
      color: Color(0xFFC62828),
      categoria: 'Primeros Auxilios',
      titulo: 'Hemorragia: presión directa',
      descripcion: 'Aplica presión firme y constante con gasa o tela limpia. No retires el material aunque se empape; agrega más encima.',
    ),
    _Tip(
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF0288D1),
      categoria: 'Hipotermia',
      titulo: 'Cuerpo frío, cabeza caliente',
      descripcion: 'Retira ropa mojada, cubre a la persona con mantas y da bebidas calientes si está consciente. Nunca alcohol.',
    ),
    _Tip(
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFFDD835),
      categoria: 'Golpe de Calor',
      titulo: 'Temperatura peligrosa',
      descripcion: 'Lleva a la persona a la sombra, aplica agua fría en cuello, axilas e ingles. Es una emergencia: llama al 911.',
    ),
    _Tip(
      icon: Icons.electric_bolt_rounded,
      color: Color(0xFFFFB300),
      categoria: 'Electrocución',
      titulo: 'Nunca toques a la víctima',
      descripcion: 'Corta la corriente antes de ayudar. Si no puedes, usa un objeto no conductor para alejar a la persona de la fuente.',
    ),
    _Tip(
      icon: Icons.backpack_rounded,
      color: Color(0xFF00897B),
      categoria: '¿Sabías que...?',
      titulo: 'Kit de emergencias básico',
      descripcion: 'Agua (4 L por persona), linterna, radio a pilas, botiquín, documentos y comida no perecedera para 72 horas.',
    ),
    _Tip(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFFF6F00),
      categoria: '¿Sabías que...?',
      titulo: 'Los primeros 3 minutos importan',
      descripcion: 'El cerebro empieza a sufrir daño irreversible a los 4-6 minutos sin oxígeno. Actuar rápido marca la diferencia.',
    ),
    _Tip(
      icon: Icons.pool_rounded,
      color: Color(0xFF039BE5),
      categoria: 'Ahogamiento',
      titulo: 'No te lances si no eres nadador',
      descripcion: 'Usa cuerdas, ramas o ropa anudada. Un rescatador inexperto puede convertirse en segunda víctima.',
    ),
    _Tip(
      icon: Icons.coronavirus_rounded,
      color: Color(0xFF6D4C41),
      categoria: 'Fracturas',
      titulo: 'Inmoviliza, no enderezes',
      descripcion: 'Si sospechas una fractura, inmoviliza el área con tablillas improvisadas. Nunca intentes acomodar el hueso.',
    ),
  ];

  static final int _virtualCount = _tips.length * 1000;
  static final int _initialPage = _tips.length * 500;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.88,
    );
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            'Consejos de Seguridad',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _virtualCount,
            itemBuilder: (context, i) =>
                _TipCard(tip: _tips[i % _tips.length]),
          ),
        ),
      ],
    );
  }
}

class _Tip {
  const _Tip({
    required this.icon,
    required this.color,
    required this.categoria,
    required this.titulo,
    required this.descripcion,
  });

  final IconData icon;
  final Color color;
  final String categoria;
  final String titulo;
  final String descripcion;
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final _Tip tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 3,
        shadowColor: tip.color.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: tip.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tip.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(tip.icon, color: tip.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tip.categoria,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tip.color,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tip.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.descripcion,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
