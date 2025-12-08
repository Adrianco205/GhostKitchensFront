class PqrDto {
  final int id;
  final int pedidoId;
  final String motivo;
  final String estado;
  final String? descripcion; // Puede venir nulo en lista

  PqrDto({required this.id, required this.pedidoId, required this.motivo, required this.estado, this.descripcion});

  factory PqrDto.fromJson(Map<String, dynamic> json) {
    return PqrDto(
      id: json['id'],
      pedidoId: json['pedido_id'],
      motivo: json['motivo'],
      estado: json['estado'],
      descripcion: json['descripcion'], // Solo en detalle
    );
  }
}

class PqrCreateDto {
  final int pedidoId;
  final String motivo;
  final String descripcion;

  PqrCreateDto({required this.pedidoId, required this.motivo, required this.descripcion});

  Map<String, dynamic> toJson() => {
    'pedido_id': pedidoId,
    'motivo': motivo,
    'descripcion': descripcion,
  };
}