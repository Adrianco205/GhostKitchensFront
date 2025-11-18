// lib/core/network/api_endpoints.dart

/// Rutas relativas del backend, tal cual el Swagger.
/// OJO: respetar mayúsculas, minúsculas y slashes finales.
class ApiEndpoints {
  // ========= AUTENTICACIÓN =========
  static const String authRegister = '/auth/register/';
  static const String authLogin = '/auth/login/';
  static const String authMe = '/auth/me/';
  static const String authRefresh = '/auth/refresh/';
  static const String authLogout = '/auth/logout/';
  static const String authRequestOtp = '/auth/request-otp/';
  static const String authVerifyOtp = '/auth/verify-otp/';
  static const String authPasswordForgot = '/auth/password/forgot/';
  static const String authPasswordReset = '/auth/password/reset/';
  static const String authPasswordChange = '/auth/password/change/';

  // ========= USUARIOS / DIRECCIONES =========
  static const String usuarios = '/usuarios/';
  static String usuarioById(int id) => '/usuarios/$id/';
  static String usuarioRoles(int id) => '/usuarios/$id/roles/';
  static const String direcciones = '/direcciones/';
  static String direccionById(int id) => '/direcciones/$id/';

  // ========= COCINAS =========
  static const String cocinas = '/cocinas/';
  static String cocinaById(int id) => '/cocinas/$id/';
  static String cocinaHorario(int id) => '/cocinas/$id/horario/';

  // ========= MENÚ =========
  static const String categorias = '/categorias/';
  static String categoriaById(int id) => '/categorias/$id/';
  static const String platos = '/platos/';
  static String platoById(int id) => '/platos/$id/';

  // ========= CARRITO =========
  static const String cart = '/cart/';
  static const String cartItems = '/cart/items/';
  static String cartItemById(String itemId) => '/cart/items/$itemId/';

  // ========= PEDIDOS =========
  static const String pedidos = '/pedidos/';
  static String pedidoById(int id) => '/pedidos/$id/';
  static String pedidoCancelar(int id) => '/pedidos/$id/cancelar/';
  static String pedidoHistorial(int id) => '/pedidos/$id/historial/';

  // ========= COCINA & EMPAQUE =========
  static String cocinaComandas(int cocinaId) =>
      '/cocinas/$cocinaId/comandas/';
  static String comandaAceptar(int id) => '/comandas/$id/aceptar/';
  static String comandaEstado(int id) => '/comandas/$id/estado/';

  // ========= REPARTO =========
  static const String repartosAsignaciones = '/repartos/asignaciones/';
  static String repartoEstado(int id) => '/repartos/$id/estado/';
  static String repartoEvidencia(int id) => '/repartos/$id/evidencia/';

  // ========= PAGOS =========
  static const String pagosIntent = '/pagos/intent/';
  static String pagoById(int id) => '/pagos/$id/';
  static String pagosWebhook(String proveedor) =>
      '/pagos/webhook/$proveedor/';

  // ========= SOPORTE / PQR =========
  static const String soporteTickets = '/soporte/tickets/';
  static String soporteTicketById(int id) => '/soporte/tickets/$id/';
  static const String pqr = '/pqr/';
  static String pqrById(int id) => '/pqr/$id/';

  // ========= ADMIN / REPORTES =========
  static const String reportesOperativos = '/admin/reportes/operativos/';

  // ========= NOTIFICACIONES =========
  static const String notificacionesPushToken = '/notificaciones/push-token/';
  static const String notificacionesTest = '/notificaciones/test/';
}
