import 'package:flutter/material.dart';

void main() {
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

  void _submitDonation() {
    if (_amountController.text.isEmpty || _trxController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে অনুদানের পরিমাণ ও TrxID দিন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ধন্যবাদ!'),
        content: Text(
          'আপনার ${_amountController.text} টাকার অনুদানের তথ্য সফলভাবে জমা নেওয়া হয়েছে।\nমাধ্যম: $_selectedMethod\nTrxID: ${_trxController.text}',
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
            // Reminder Card
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

            // Accounts Header
            const Text(
              'আমাদের অ্যাকাউন্ট নম্বরসমূহ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Accounts Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildAccountCard(
                  'বিকাশ (Personal)',
                  '01700-000000',
                  Colors.pink[100]!,
                  Colors.pink[900]!,
                ),
                _buildAccountCard(
                  'নগদ (Personal)',
                  '01800-000000',
                  Colors.orange[100]!,
                  Colors.orange[900]!,
                ),
                _buildAccountCard(
                  'ব্যাংক অ্যাকাউন্ট',
                  '1234 5678 9012\nIslami Bank',
                  Colors.blue[100]!,
                  Colors.blue[900]!,
                ),
                _buildAccountCard(
                  'ক্যাশ (Cash)',
                  'অফিসে সরাসরি জমা দিন',
                  Colors.grey[200]!,
                  Colors.black87,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form
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
              decoration: const InputDecoration(
                labelText: 'অনুদানের পরিমাণ (টাকা)',
              ),
            ),
            TextField(
              controller: _trxController,
              decoration: const InputDecoration(
                labelText: 'ট্রানজেকশন আইডি (TrxID) / রেফারেন্স',
              ),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'প্রেরকের মোবাইল নম্বর (ঐচ্ছিক)',
              ),
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
                onPressed: _submitDonation,
                child: const Text(
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

  Widget _buildAccountCard(
      String title, String number, Color bg, Color textColor) {
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          ],
        ),
      ),
    );
  }
}
