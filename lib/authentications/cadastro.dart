import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadastro_teste/model/usuario.dart';
import 'perfil.dart'; // Importe a classe Perfil aqui

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  late TextEditingController _nomeController;
  late TextEditingController _contactoController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _contactoController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  Future<void> _salvarUsuario(BuildContext context) async {
    Usuario usuario = Usuario(
      nomeCompleto: _nomeController.text,
      contacto: _contactoController.text,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nomeCompleto', usuario.nomeCompleto);
    await prefs.setString('contacto', usuario.contacto);
    // Após salvar o usuário, navegue para a página de perfil
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Perfil(usuario: usuario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/imagem/loginpur.png',
                      width: 230,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "CADASTRAR NOVA CONTA",
                      style: TextStyle(
                        fontSize: 37,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.3),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 2) {
                            return "Insira o seu nome";
                          }
                        },
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: InputBorder.none,
                          labelText: "Nome",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.3),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Insira o seu contacto";
                          }
                          if (value.length < 9 || value.length > 9) {
                            return "Insira 9 números";
                          }
                        },
                        keyboardType: TextInputType.phone,
                        controller: _contactoController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.phone),
                          labelText: "Contacto",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      width: MediaQuery.of(context).size.width * 9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF8F3AB7)),
                      child: TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _salvarUsuario(context);
                            }
                          },
                          child: Text(
                            "CADASTRAR-SE",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
