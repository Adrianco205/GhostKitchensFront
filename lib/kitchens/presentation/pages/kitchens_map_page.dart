import 'package:flutter/material.dart';

class KitchensMapPage extends StatelessWidget {
  const KitchensMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: integrar google_maps_flutter y mostrar los markers de las cocinas.
    // Aquí solo dejamos una estructura básica de UI.
    return const SafeArea(
      child: Center(
        child: Text(
          'Aquí verás el mapa con las cocinas cercanas.\n'
          'Próximamente: Google Maps + markers por cocina 👀',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
