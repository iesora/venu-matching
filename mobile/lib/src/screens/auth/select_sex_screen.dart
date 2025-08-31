import 'package:flutter/material.dart';
import 'package:mobile/src/screens/auth/certificate_screen.dart';
import 'package:mobile/src/screens/auth/create_account.dart';
import 'package:mobile/src/widgets/default_button.dart';
import 'package:mobile/src/widgets/terms_of_service_row.dart';
import 'package:mobile/utils/userInfo.dart';

class SelectSexScreen extends StatefulWidget {
  final String email;
  const SelectSexScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<SelectSexScreen> createState() => _SelectSexScreenState();
}

class _SelectSexScreenState extends State<SelectSexScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;
  Sex? _selectedSex;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildSexButton(Sex sex, IconData icon, Color baseColor) {
    bool isSelected = _selectedSex == sex;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? baseColor.withOpacity(0.2) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? baseColor : Colors.grey,
            width: 1,
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          if (_selectedSex == sex) {
            _selectedSex = null;
          } else {
            _selectedSex = sex;
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? baseColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            sex.japanName,
            style: TextStyle(
              color: isSelected ? baseColor : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Text(
                    "性別の選択",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "あなたの性別を選択してください",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSexButton(Sex.MALE, Icons.male, Colors.blue),
                          _buildSexButton(
                              Sex.FEMALE, Icons.female, Colors.pink),
                          /*
                          _buildSexButton(
                              Sex.LESBIAN, Icons.female, Colors.deepOrange),
                          _buildSexButton(
                              Sex.GAY, Icons.male, Colors.deepPurple),
                          _buildSexButton(
                              Sex.BISEXUAL, Icons.favorite, Colors.orange),
                          _buildSexButton(
                              Sex.TRANSGENDER, Icons.transgender, Colors.teal),
                          _buildSexButton(Sex.QUESTIONING, Icons.help_outline,
                              Colors.green),
                          */
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DefaultButton(
                          backgroundColor: Colors.deepOrangeAccent,
                          onPressed: _selectedSex == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CertificateScreen(
                                        email: widget.email,
                                        sex: _selectedSex!.value,
                                      ),
                                    ),
                                  );
                                },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "次へ",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CertificateScreen(
                                  email: widget.email,
                                  // sex omitted to allow null
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "スキップする",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TermsOfServiceRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
