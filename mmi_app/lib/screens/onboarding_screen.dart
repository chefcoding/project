import 'package:flutter/material.dart';

import '../models/child_profile.dart';

/// 첫 실행 시(또는 프로필 수정 시) 아이의 개인정보를 입력받는 화면.
///
/// 여기서 모은 정보는 AI가 맞춤 가이드를 만들 때 함께 참고된다.
class OnboardingScreen extends StatefulWidget {
  /// 수정 모드일 때 기존 프로필 (신규 입력이면 null)
  final ChildProfile? initial;

  /// 저장 완료 시 호출
  final void Function(ChildProfile profile) onComplete;

  const OnboardingScreen({super.key, this.initial, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _diagnosis;
  late final TextEditingController _triggers;
  late final TextEditingController _calming;
  late final TextEditingController _notes;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _age = TextEditingController(text: p != null ? p.age.toString() : '');
    _diagnosis = TextEditingController(text: p?.diagnosis ?? '');
    _triggers = TextEditingController(text: p?.knownTriggers.join(', ') ?? '');
    _calming = TextEditingController(text: p?.calmingMethods.join(', ') ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    _gender = p?.gender ?? '남자';
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _diagnosis.dispose();
    _triggers.dispose();
    _calming.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<String> _splitList(String raw) => raw
      .split(RegExp(r'[,\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profile = ChildProfile(
      name: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      gender: _gender,
      diagnosis: _diagnosis.text.trim(),
      knownTriggers: _splitList(_triggers.text),
      calmingMethods: _splitList(_calming.text),
      notes: _notes.text.trim(),
    );
    widget.onComplete(profile);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(isEdit ? '아이 정보 수정' : '아이 정보 입력'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222222),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!isEdit) ...[
                const Text(
                  '우리 아이를 알려주세요',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '입력한 정보는 이 기기에만 저장되며, AI가 아이에게 꼭 맞는 진정 가이드를 만드는 데 사용됩니다.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 24),
              ],
              _field(
                controller: _name,
                label: '이름 (또는 별칭)',
                hint: '예: 민준',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '이름을 입력해 주세요' : null,
              ),
              _field(
                controller: _age,
                label: '나이 (만)',
                hint: '예: 7',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 0 || n > 30) return '올바른 나이를 입력해 주세요';
                  return null;
                },
              ),
              _genderField(),
              _field(
                controller: _diagnosis,
                label: '진단 / 특성 (선택)',
                hint: '예: 자폐 스펙트럼, 감각 과민',
              ),
              _field(
                controller: _triggers,
                label: '알고 있는 트리거 (선택, 쉼표로 구분)',
                hint: '예: 큰 소리, 갑작스러운 일정 변화',
                maxLines: 2,
              ),
              _field(
                controller: _calming,
                label: '효과 있었던 진정 방법 (선택, 쉼표로 구분)',
                hint: '예: 좋아하는 노래, 꼭 안아주기',
                maxLines: 2,
              ),
              _field(
                controller: _notes,
                label: '기타 메모 (선택)',
                hint: '보호자가 남기고 싶은 내용',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: Text(isEdit ? '저장' : '시작하기',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _gender,
        decoration: InputDecoration(
          labelText: '성별',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        items: const [
          DropdownMenuItem(value: '남자', child: Text('남자')),
          DropdownMenuItem(value: '여자', child: Text('여자')),
          DropdownMenuItem(value: '기타', child: Text('기타')),
        ],
        onChanged: (v) => setState(() => _gender = v ?? '남자'),
      ),
    );
  }
}
