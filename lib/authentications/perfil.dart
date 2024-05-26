import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadastro_teste/model/usuario.dart';
import 'cadastro.dart';

class Perfil extends StatelessWidget {
  const Perfil({Key? key, required this.usuario}) : super(key: key);

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8F3AB7),
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ação ao clicar no botão de voltar
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Cadastro()), // Substitua MinhaClasse pela classe desejada
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .start, // Mudei para MainAxisAlignment.start para alinhar no topo
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50), // Espaço vazio adicionado
            Image.asset(
              'lib/assets/imagem/loginpur.png',
              width: 150,
            ),

            const Text(
              "Perfil",
              style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F3AB7)),
            ),
            const SizedBox(height: 25),

            Container(
              margin: EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.deepPurple.withOpacity(.3),
              ),
              child: Text(
                'Nome: ${usuario.nomeCompleto}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              margin: EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.deepPurple.withOpacity(.3),
              ),
              child: Text(
                'Contacto: ${usuario.contacto}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
