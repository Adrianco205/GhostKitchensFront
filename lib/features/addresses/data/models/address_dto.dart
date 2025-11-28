class AddressDto {
  final int id;
  final String direccionTexto;
  final String? ciudad;
  final String? alias;

  AddressDto({
    required this.id,
    required this.direccionTexto,
    this.ciudad,
    this.alias,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'] as int,
      direccionTexto: json['direccion_texto'] as String,
      ciudad: json['ciudad'] as String?,
      alias: json['alias'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direccion_texto': direccionTexto,
      'ciudad': ciudad,
      'alias': alias,
    };
  }
}
