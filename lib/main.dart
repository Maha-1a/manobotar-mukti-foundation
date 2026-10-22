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
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DonationScreen(),
    const ActivitiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'মানবতার মুক্তি ফাউন্ডেশন',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 2,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
  final _formKey = GlobalKey<FormState>();
  String? _selectedMethod = 'Bkash';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _trxController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _submitDonation() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ধন্যবাদ!'),
          content: Text(
            'আপনার অনুদানের তথ্য সফলভাবে জমা হয়েছে।\n\n'
            'মেথড: $_selectedMethod\n'
            'পরিমাণ: ৳${_amountController.text}\n'
            'TrxID: ${_trxController.text}\n\n'
            'যাচাই বাছাই শেষে আপনার প্রোফাইলে ডিজিটাল রিসিপ্ট যুক্ত হবে।',
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
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.green.shade200),
            ),
            child: const ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.green),
              title: Text(
                'মাসিক ডোনেশন রিমাইন্ডার',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('নিয়মিত অনুদান দিয়ে মানবতার পাশে থাকুন।'),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'আমাদের অ্যাকাউন্ট নম্বরসমূহ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildAccountCard('বিকাশ (Personal)', '01700-000000', Colors.pink.shade100),
              const SizedBox(width: 10),
              _buildAccountCard('নগদ (Personal)', '01800-000000', Colors.orange.shade100),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildAccountCard('ব্যাংক অ্যাকাউন্ট', '1234 5678 9012\nIslami Bank', Colors.blue.shade100),
              const SizedBox(width: 10),
              _buildAccountCard('ক্যাশ (Cash)', 'অফিসে সরাসরি জমা দিন', Colors.grey.shade200),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'অনুদানের তথ্য জমা দিন',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম'),
                    items: ['Bkash', 'Nagad', 'Bank', 'Cash'].map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMethod = val),
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'অনুদানের পরিমাণ (টাকা)'),
                    validator: (val) => val == null || val.isEmpty ? 'পরিমাণ লিখুন' : null,
                  ),
                  TextFormField(
                    controller: _trxController,
                    decoration: const InputDecoration(labelText: 'ট্রানজেকশন আইডি (TrxID) / রেফারেন্স'),
                    validator: (val) => val == null || val.isEmpty ? 'TrxID দিন' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'প্রেরকের মোবাইল নম্বর (ঐচ্ছিক)'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _submitDonation,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                      child: const Text('তথ্য জমা দিন', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(String title, String number, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 5),
            Text(number, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'আমাদের সংরক্ষণ ও কার্যক্রমসমূহ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildActivityCard(
          'বন্যাদুর্গতদের ত্রাণ বিতরণ',
          'স্থান: ফেনী ও নোয়াখালী',
          'সম্পন্ন প্রজেক্ট',
          Colors.green,
        ),
        _buildActivityCard(
          'মেধাবী ছাত্রবৃত্তি প্রকল্প',
          '১০ জন শিক্ষার্থীকে আর্থিক সহায়তা প্রদান',
          'চলমান প্রজেক্ট',
          Colors.orange,
        ),
        _buildActivityCard(
          'বিনামূল্যে চিকিৎসা ক্যাম্প',
          'স্থান: সদর হাসপাতাল প্রাঙ্গণ',
          'আর্কাইভ / ফাইল',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildActivityCard(String title, String details, String status, Color tagColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: tagColor,
                )
              ],
            ),
            const SizedBox(height: 5),
            Text(details, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              child: const Text('বিস্তারিত দেখুন'),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text('সম্মানিত ডোনার', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('আমার ডোনেশন হিস্ট্রি'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.card_membership),
            title: Text('ডিজিটাল রিসিপ্ট ও সার্টিফিকেট'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
