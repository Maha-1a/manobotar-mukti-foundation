import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ManobotarMuktiApp());
}

class ManobotarMuktiApp extends StatelessWidget {
  const ManobotarMuktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'মানবতার মুক্তি ফাউন্ডেশন',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DonationScreen(),
    const ActivitiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'অনুদান দিন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'আমাদের কার্যক্রম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}

// ----------------- অনুদান স্ক্রিন (Donation Screen) -----------------
class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String _selectedMethod = 'Bkash';
  final _amountController = TextEditingController();
  final _trxController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _submitDonation() async {
    if (_amountController.text.isEmpty || _trxController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে অনুদানের পরিমাণ ও TrxID দিন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Firestore এ ডাটা সেভ করা
      await FirebaseFirestore.instance.collection('donations').add({
        'method': _selectedMethod,
        'amount': _amountController.text,
        'trxId': _trxController.text,
        'phone': _phoneController.text,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ধন্যবাদ!'),
          content: Text(
            'আপনার ${_amountController.text} টাকার অনুদানের তথ্য সফলভাবে অনলাইনে জমা হয়েছে।\nঅ্যাডমিন যাচাই করার পর এটি অনুমোদিত হবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _amountController.clear();
                _trxController.clear();
                _phoneController.clear();
              },
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি হয়েছে: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মানবতার মুক্তি ফাউন্ডেশন'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[50],
              child: const ListTile(
                leading: Icon(Icons.notifications_active, color: Colors.green),
                title: Text(
                  'মাসিক ডোনেশন রিমাইন্ডার',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('নিয়মিত অনুদান দিয়ে মানবতার পাশে থাকুন।'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'আমাদের অ্যাকাউন্ট নম্বরসমূহ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildAccountCard('বিকাশ (Personal)', '01700-000000', Colors.pink[100]!, Colors.pink[900]!),
                _buildAccountCard('নগদ (Personal)', '01800-000000', Colors.orange[100]!, Colors.orange[900]!),
                _buildAccountCard('ব্যাংক অ্যাকাউন্ট', '1234 5678 9012\nIslami Bank', Colors.blue[100]!, Colors.blue[900]!),
                _buildAccountCard('ক্যাশ (Cash)', 'অফিসে সরাসরি জমা দিন', Colors.grey[200]!, Colors.black87),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'অনুদানের তথ্য জমা দিন',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম'),
              items: ['Bkash', 'Nagad', 'Bank', 'Cash']
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMethod = val;
                  });
                }
              },
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'অনুদানের পরিমাণ (টাকা)'),
            ),
            TextField(
              controller: _trxController,
              decoration: const InputDecoration(labelText: 'ট্রানজেকশন আইডি (TrxID) / রেফারেন্স'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'প্রেরকের মোবাইল নম্বর (ঐচ্ছিক)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _submitDonation,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'তথ্য জমা দিন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(String title, String number, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
          const SizedBox(height: 4),
          Text(number, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

// ----------------- কার্যক্রম স্ক্রিন (Activities Screen) -----------------
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমাদের কার্যক্রম'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('শীতবস্ত্র বিতরণ ২০২৬'),
              subtitle: Text('বান্দরবান ও দূরবর্তী অঞ্চলে ৫০০ পরিবারকে শীতবস্ত্র প্রদান।'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.school, color: Colors.blue),
              title: Text('এতিম শিক্ষা সহায়তা প্রকল্প'),
              subtitle: Text('৫০ জন এতিম শিক্ষার্থীর পড়াশোনার সার্বিক দায়িত্ব।'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.water_drop, color: Colors.teal),
              title: Text('বিশুদ্ধ খাবার পানি প্রকল্প'),
              subtitle: Text('উপকূলীয় অঞ্চলে ১০টি গভীর নলকূপ স্থাপন।'),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- প্রোফাইল ও অ্যাডমিন প্যানেল স্ক্রিন (Profile & Admin) -----------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showAdminLoginDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('অ্যাডমিন প্যানেল লগইন'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'সিক্রেট পিন দিন (যেমন: 1234)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == '1234') {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ভুল পিন! সঠিক পিন দিন (1234)'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('লগইন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'সম্মানিত ডোনার',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('মানবতার মুক্তি ফাউন্ডেশনের সাথে থাকার জন্য ধন্যবাদ।'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('মাসিক রিমাইন্ডার সেট করুন'),
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.green[800]),
              onPressed: () => _showAdminLoginDialog(context),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('অ্যাডমিন প্যানেল (Admin Panel)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- অ্যাডমিন ড্যাশবোর্ড (Admin Dashboard) -----------------
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন ড্যাশবোর্ড (অনুদান তালিকা)'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('এখনও কোনো অনুদানের তথ্য জমা পড়েনি।'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    'মাধ্যম: ${data['method']} | পরিমাণ: ৳${data['amount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'TrxID: ${data['trxId']}\nনম্বার: ${data['phone'] ?? 'নেই'}\nস্ট্যাটাস: ${data['status']}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('donations').doc(docId).update({
                        'status': 'Approved',
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
