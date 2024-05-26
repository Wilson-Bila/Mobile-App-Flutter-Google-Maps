class Usuario {
  String _nomeCompleto;
  String _contacto;

  Usuario({
    required String nomeCompleto,
    required String contacto,
  })  : _nomeCompleto = nomeCompleto,
        _contacto = contacto;

  String get nomeCompleto => _nomeCompleto;
  set nomeCompleto(String nomeCompleto) => _nomeCompleto = nomeCompleto;

  String get contacto => _contacto;
  set contacto(String contacto) => _contacto = contacto;
}
