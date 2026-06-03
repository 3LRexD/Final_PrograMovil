//interfaz del servicio de ml
//implementacion real la conecta el equipo de ml
abstract class SintomaService {
  Future<Diagnostico> analizar(String descripcion);
}

class Diagnostico {
  const Diagnostico({
    required this.causa,
    required this.descripcion,
    required this.tratamiento,
    required this.urgencia,
  });

  final String causa;
  final String descripcion;
  final String tratamiento;
  final String urgencia; //baja o media o alta
}

//mock para probar la ui siempre regresa infeccion estomacal
class MockSintomaService implements SintomaService {
  @override
  Future<Diagnostico> analizar(String descripcion) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return const Diagnostico(
      causa: 'Infección estomacal',
      descripcion:
          'Inflamación del tracto digestivo que puede causar dolor, náuseas y malestar general.',
      tratamiento:
          'Si el dolor es leve, intenta reposar, mantente hidratado con agua o suero y evita comidas pesadas o irritantes. Busca atención médica inmediata si: El dolor es intenso, repentino o empeora. Tienes fiebre alta, vómitos persistentes o sangre en las heces. Sientes rigidez abdominal o dolor localizado muy fuerte (especialmente en el lado inferior derecho).',
      urgencia: 'media',
    );
  }
}
