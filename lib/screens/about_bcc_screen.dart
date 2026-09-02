import 'package:flutter/material.dart';

class AboutBccScreen extends StatelessWidget {
  final Function(String) navigate;
  const AboutBccScreen({super.key, required this.navigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang BCC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigate('dashboard'),
        ),
      ),
      body: const Center(
        child: Text('Informasi edukasi tentang Basal Cell Carcinoma (BCC).'),
      ),
    );
  }
}
