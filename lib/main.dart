import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Ninja Zitate',
      home: QuoteSwitchScreen(),
    );
  }
}

class QuoteSwitchScreen extends StatefulWidget {
  const QuoteSwitchScreen({super.key});

  @override
  _QuoteSwitchScreenState createState() => _QuoteSwitchScreenState();
}

class _QuoteSwitchScreenState extends State<QuoteSwitchScreen> {
  // hier stehen die Werte beim Start drin
  String quote = "Lade ein Zitat";
  String author = "Unbekannt";
  String category = "unbekannt";

  //! Liste für Author etc
  List<String> authorsList = [];
  List<String> categoryList = [];
  List<String> quotesList = [];
  // dann wird dies ausgeführt
  @override
  void initState() {
    super.initState();
    _loadQuoteFromPrefs();
  }

  Future<void> _randomQuote() async {
    final Uri uri = Uri.https("api.api-ninjas.com", "/v1/quotes");
    final headers = {"X-Api-Key": "tn/NzdwIhYvvODdidg44/Q==WaiKKWqcBteD6lRP"};
    final http.Response response = await http.get(uri, headers: headers);
//!------ Hier nachfragen wie in eine Liste speichern
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        quote = data[0]['quote'];
        author = data[0]['author'];
        category = data[0]["category"];
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
                style: TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
                "Zitat erfolgreich geladen ")));
      });
      _saveQuoteToPrefs(quote, author, category);
    }
  }

// hier werden die Sachen in die SP geschrieben
  Future<void> _saveQuoteToPrefs(
      String quote, String author, String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quote', quote);
    await prefs.setString('author', author);
    await prefs.setString("category", category);
  }

  Future<void> _loadQuoteFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuote = prefs.getString('quote');
    final savedAuthor = prefs.getString('author');
    final savedCategory = prefs.getString("category");

    if (savedQuote != null && savedAuthor != null && savedCategory != null) {
      setState(() {
        quote = savedQuote;
        author = savedAuthor;
        category = savedCategory;
      });
    }
  }

// hier wird das Zitat gelöscht
  Future<void> _clearQuote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quote');
    await prefs.remove("author");
    await prefs.remove("category");
    setState(() {
      quote = 'Lade ein Zitat...';
      author = "";
      category = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade200,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Dirks Zitate App  © api-ninjas.com")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text('"$quote"',
                  style: const TextStyle(
                      fontSize: 20, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            Text(" Author: $author",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(" Kategorie: $category",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _randomQuote,
                child: const Text("Neues Zitat holen")),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _clearQuote,
                child: const Text("Letztes Zitat löschen")),
          ],
        ),
      ),
    );
  }
}
