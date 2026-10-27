import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../services/attendance_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = AttendanceService();

  final _regNoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _setDefaultsForTab(0); // Faculty default
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _setDefaultsForTab(_tabController.index);
    }
  }

  void _setDefaultsForTab(int index) {
    setState(() {
      _errorMessage = null;
      if (index == 0) {
        _regNoController.text = 'FAC001';
        _passwordController.text = 'Faculty@123';
      } else if (index == 1) {
        _regNoController.text = '24B01A12I1'; // CR I1
        _passwordController.text = 'Cr@123';
      } else {
        _regNoController.text = 'ADMIN';
        _passwordController.text = 'Admin@123';
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final role = _tabController.index == 0
        ? UserRole.faculty
        : _tabController.index == 1
            ? UserRole.cr
            : UserRole.admin;

    try {
      await _service.login(
        regNo: _regNoController.text,
        password: _passwordController.text,
        expectedRole: role,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade800, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.25, 0.45],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // App Branding
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: const Icon(Icons.school, size: 48, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CAMPUS ATTENDANCE',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const Text(
                    'Student Attendance Management App',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Real-Time Asia/Kolkata Clock Display
                  StreamBuilder<DateTime>(
                    stream: _service.timeStream,
                    initialData: _service.nowKolkata,
                    builder: (context, snapshot) {
                      final time = snapshot.data ?? _service.nowKolkata;
                      final dayStr = DateFormat('EEEE').format(time);
                      final dateStr = DateFormat('dd MMMM yyyy').format(time);
                      final timeStr = DateFormat('hh:mm:ss a').format(time);

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1E3A8A)),
                                  const SizedBox(width: 6),
                                  Text('$dayStr, $dateStr', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: Colors.teal),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$timeStr IST',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                  ),
                                ],
                              ),
                              const Text('College Timezone: Asia/Kolkata (Live)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Login Form Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF1E3A8A),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF1E3A8A),
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Faculty'),
                              Tab(text: 'CR (I1/F7)'),
                              Tab(text: 'Admin'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Notice for CR page restriction
                          if (_tabController.index == 1)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: const Text(
                                'CR Access Policy: Only students I1 (24B01A12I1) and F7 (24B01A12F7) are authorized Class Representatives.',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.brown),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          TextField(
                            controller: _regNoController,
                            decoration: InputDecoration(
                              labelText: _tabController.index == 2 ? 'Admin Username' : 'Registration Number',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Personal Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Login to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Pre-Configured Test Logins:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('Faculty (FAC001)'),
                        onPressed: () {
                          _tabController.animateTo(0);
                          _regNoController.text = 'FAC001';
                          _passwordController.text = 'Faculty@123';
                        },
                      ),
                      ActionChip(
                        label: const Text('CR I1 (24B01A12I1)'),
                        backgroundColor: Colors.blue.shade50,
                        onPressed: () {
                          _tabController.animateTo(1);
                          _regNoController.text = '24B01A12I1';
                          _passwordController.text = 'Cr@123';
                        },
                      ),
                      ActionChip(
                        label: const Text('CR F7 (24B01A12F7)'),
                        backgroundColor: Colors.blue.shade50,
                        onPressed: () {
                          _tabController.animateTo(1);
                          _regNoController.text = '24B01A12F7';
                          _passwordController.text = 'Cr@123';
                        },
                      ),
                      ActionChip(
                        label: const Text('Admin'),
                        onPressed: () {
                          _tabController.animateTo(2);
                          _regNoController.text = 'ADMIN';
                          _passwordController.text = 'Admin@123';
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
