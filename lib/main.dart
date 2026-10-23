import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manobotar Mukti Foundation',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DonationFormPage(),
    const HistoryPage(),
    const ProfileAdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'দান করুন'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ইতিহাস'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'অ্যাডমিন'),
        ],
      ),
    );
  }
}

class DonationFormPage extends StatefulWidget {
  const DonationFormPage({super.key});

  @override
  State<DonationFormPage> createState() => _DonationFormPageState();
}

class _DonationFormPageState extends State<DonationFormPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitDonation() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নাম এবং টাকার পরিমাণ লিখুন')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _nameController.text,
        'amount': double.tryParse(_amountController.text) ?? 0,
        'phone': _phoneController.text,
        'date': Timestamp.now(),
      });

      _nameController.clear();
      _amountController.clear();
      _phoneController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ধন্যবাদ! আপনার দান সফলভাবে গ্রহণ করা হয়েছে।')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ত্রুটি ঘটেছে: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মানবতার মুক্তি ফাউন্ডেশন'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/app_logo.png',
                height: 100,
                errorBuilder: (_, __, ___) => const Icon(Icons.favorite, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 15),
              const Text(
                'মানবতার সেবায় আপনার সাহায্য পাঠাতেন',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'আপনার নাম', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (ঐচ্ছিক)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'দানের পরিমাণ (টাকা)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('দান জমা দিন', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সাম্প্রতিক অনুদানসমূহ'), backgroundColor: Colors.green[700]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('এখনো কোনো অনুদান জমা হয়নি।'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp?)?.toDate();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.attach_money, color: Colors.white)),
                  title: Text(data['name'] ?? 'বেনামী'),
                  subtitle: Text(date != null ? '${date.day}/${date.month}/${date.year}' : ''),
                  trailing: Text('৳${data['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  final _pinController = TextEditingController();
  bool _isAdminLoggedIn = false;

  void _verifyPin() {
    if (_pinController.text == '1234') {
      setState(() => _isAdminLoggedIn = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল পিন কোড!')),
      );
    }
  }

  Future<void> _generatePdf(List<QueryDocumentSnapshot> docs, String reportType) async {
    final pdf = pw.Document();

    double totalAmount = 0;
    final List<List<String>> tableData = [];

    final now = DateTime.now();

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp?)?.toDate();

      if (date == null) continue;

      bool isMatch = false;
      if (reportType == 'Monthly' && date.month == now.month && date.year == now.year) {
        isMatch = true;
      } else if (reportType == 'Yearly' && date.year == now.year) {
        isMatch = true;
      }

      if (isMatch) {
        final amount = (data['amount'] ?? 0).toDouble();
        totalAmount += amount;
        tableData.add([
          data['name'] ?? 'N/A',
          data['phone'] ?? 'N/A',
          'BDT ${amount.toStringAsFixed(2)}',
          '${date.day}/${date.month}/${date.year}'
        ]);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            cross: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Manobotar Mukti Foundation - $reportType Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Report Generated Date: ${now.day}/${now.month}/${now.year}'),
              pw.Text('Total Collection: BDT ${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Phone', 'Amount', 'Date'],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Donation_Report_$reportType.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdminLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('অ্যাডমিন লগইন'), backgroundColor: Colors.green[700]),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'অ্যাডমিন পিন কোড দিন (1234)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: const Text('প্রবেশ করুন', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন ড্যাশবোর্ড'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => setState(() => _isAdminLoggedIn = false),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          double totalSum = 0;
          for (var doc in docs) {
            totalSum += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
          }

          return Column(
            children: [
              Card(
                color: Colors.green[50],
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('সর্বমোট তহবিল:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('৳$totalSum', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _generatePdf(docs, 'Monthly'),
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text('মাসিক PDF'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _generatePdf(docs, 'Yearly'),
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text('বাৎসরিক PDF'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data['date'] as Timestamp?)?.toDate();
                    return ListTile(
                      title: Text('${data['name']} (${data['phone'] ?? "No Phone"})'),
                      subtitle: Text(date != null ? '${date.day}/${date.month}/${date.year}' : ''),
                      trailing: Text('৳${data['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
