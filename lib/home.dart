import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Estudiante {
  final String nombre;
  final String correo;
  final String fechaNacimiento;
  final String fotoUrl;
  final String carrera;
  final String ciclo;

  Estudiante({
    required this.nombre,
    required this.correo,
    required this.fechaNacimiento,
    required this.fotoUrl,
    required this.carrera,
    required this.ciclo,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    final user = json['results'][0];
    final nombreCompleto = '${user['name']['first']} ${user['name']['last']}';
    return Estudiante(
      nombre: nombreCompleto,
      correo: user['email'],
      fechaNacimiento: user['dob']['date'].substring(0, 10),
      fotoUrl: user['picture']['large'],
      carrera: "DAW",
      ciclo: "4to. Ciclo",
    );
  }
}

Future<Estudiante> fetchEstudiante() async {
  final response = await http.get(Uri.parse('https://randomuser.me/api/'));
  if (response.statusCode == 200) {
    return Estudiante.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Fallo al cargar los datos del estudiante');
  }
}

class CarnetEstudiantil extends StatefulWidget {
  const CarnetEstudiantil({super.key});

  @override
  State<CarnetEstudiantil> createState() => _CarnetEstudiantilState();
}

class _CarnetEstudiantilState extends State<CarnetEstudiantil> {
  late Future<Estudiante> estudiante;

  @override
  void initState() {
    super.initState();
    estudiante = fetchEstudiante();
  }

  void recargarEstudiante() {
    setState(() {
      estudiante = fetchEstudiante();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carnet Estudiantil')),
      body: FutureBuilder<Estudiante>(
        future: estudiante,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final est = snapshot.data!;
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.blue[50],
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'images/logo_ISTL_01.png',
                        height: 60,
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            est.fotoUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Datos
                      Text(est.nombre,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(est.correo, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Nacimiento: ${est.fechaNacimiento}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Carrera: ${est.carrera}',
                          style: const TextStyle(fontSize: 18)),
                      Text('Ciclo: ${est.ciclo}',
                          style: const TextStyle(fontSize: 18)),

                      const SizedBox(height: 30),

                      const SizedBox(height: 20),
                      Image.asset(
                        'images/qrCode.png',
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Código QR',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      ElevatedButton.icon(
                        onPressed: recargarEstudiante,
                        icon: const Icon(Icons.refresh),
                        label: const Text("recargar"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
