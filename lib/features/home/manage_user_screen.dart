import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/user/manage-user',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md + 4, AppSpacing.md + 4, AppSpacing.md + 4, 96),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [_HeaderSection(), SizedBox(height: AppSpacing.md + 2), _SearchAndActions(), SizedBox(height: AppSpacing.md + 2), _UserTableCard()]),
                ),
              ),
              const _BottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: AppPalette.surface, border: Border(bottom: BorderSide(color: AppPalette.borderNeutral))),
      child: Row(children: [const Icon(Icons.menu, color: AppPalette.brandBlue, size: 32), const SizedBox(width: 20), Expanded(child: Text('Staff Accounts', style: AppTextStyles.headline2.copyWith(fontWeight: FontWeight.w700, color: AppPalette.brandBlue))), const CircleAvatar(radius: 21, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA173mSbZZbn77Sf7eEWre2WlkHJK0pLUYYKNG4LKVSPKaKhyoQpekjr0R2NsMs1AMBKVUtg4BqVK7ygXaBfjXtH5YmkMElqSQZrTb-P3QaEW50jDoQpoewU0EhJXU_sUGqzEJQqUQ_hydLBnd0h4y6bBAVUjDmxKlWteTckGxeRNtezojlGs0alS_EJRT1NC-R57XtGk6O7T9H-mG0OtFgUDAWuX7p9IlJ5h56gT-6uTEdGv_vKKv9OoQDkHaTXyQzhZXNPMXpX3E'))]),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Employee Directory', style: AppTextStyles.headline1.copyWith(fontSize: 42, height: 1.1)),
      const SizedBox(height: 6),
      const Text('Manage and monitor your global staff\naccounts', style: AppTextStyles.subtitle1),
      const SizedBox(height: 16),
      Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFFE8ECFF), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            _viewBtn(Icons.grid_view_rounded, false),
            const SizedBox(width: 8),
            _viewBtn(Icons.list, true),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 64,
            decoration: BoxDecoration(color: AppPalette.brandBlue, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x22004AC6), blurRadius: 15, offset: Offset(0, 6))]),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_alt_1_rounded, color: Colors.white), SizedBox(width: 8), Text('Add Member', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))]),
          ),
        )
      ]),
    ]);
  }

  Widget _viewBtn(IconData icon, bool active) {
    return Container(
      width: 64,
      height: 54,
      decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(14), boxShadow: active ? const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3))] : null),
      child: Icon(icon, color: const Color(0xFF2F3546)),
    );
  }
}

class _SearchAndActions extends StatelessWidget {
  const _SearchAndActions();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(22, 12, 10, 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD1DFFE)), boxShadow: const [BoxShadow(color: Color(0x14004AC6), blurRadius: 16, offset: Offset(0, 6))]),
        child: Row(children: [const Expanded(child: Text('Search in bideshgami', style: TextStyle(fontSize: 33 / 2, color: Color(0xFF60708A)))), Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.search, color: Colors.white))]),
      ),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _actionBtn(Icons.filter_list, 'Filters')), const SizedBox(width: 14), Expanded(child: _actionBtn(Icons.download_rounded, 'Export'))]),
    ]);
  }

  Widget _actionBtn(IconData icon, String label) => Container(
    height: 62,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFBFC6DA))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF636A7D)), const SizedBox(width: 10), Text(label, style: AppTextStyles.subtitle1.copyWith(fontSize: 17, color: AppPalette.textPrimary))]),
  );
}

class _UserTableCard extends StatelessWidget {
  const _UserTableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFE0E5F3))),
      child: Column(
        children: [
          _tableHeader(),
          ..._rows(),
          const Divider(height: 1, color: Color(0xFFD9DEEA)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(children: [
              const Text('Showing 1 - 4 of 42 staff members', style: AppTextStyles.subtitle1),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _pageBtn(Icons.chevron_left, false),
                _numBtn('1', true),
                _numBtn('2', false),
                _numBtn('3', false),
                const Text('...', style: TextStyle(fontSize: 24, color: Color(0xFF6B7385))),
                _numBtn('11', false),
                _pageBtn(Icons.chevron_right, true),
              ])
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
    decoration: const BoxDecoration(color: Color(0xFFEDEFFF), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    child: const Row(children: [Expanded(flex: 2, child: Text('USER\nID', style: _h)), Expanded(flex: 3, child: Text('NAME &\nROLE', style: _h)), Expanded(flex: 2, child: Text('EMAIL ADI', style: _h))]),
  );

  List<Widget> _rows() => const [
    _UserRow(id: '#STF-\n92841', name: 'Sarah\nJenkins', role: 'Senior\nArchitect', roleBg: Color(0xFFE7EEFF), roleColor: Color(0xFF004AC6), avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCS53u7NLTg8uSq5u7tXyfzv4haUbTqPQ4hF7gIqXdDi1hN0VtyjDTAF0O_2_-_-Zq6yv4ozig2AtwUtnr2uuXXP3cC6oVJPOwNQ5k9PDBncsQgxnspbgAW47VUHh_-dFgpkr-1mNGbZOeqTELh0EPp9pdUNCUuH77ZLJYJGrYQKHS7W5PIRpqk6gHgpDOLjW_NhEQLAA3QHncwfb_mQkhhK-wQA0pPN53Q05-qn7MHHfo64S21rJj7jvBs8JsGpyFu3kTbZrgth1U', email: 's.jenkins@e'),
    _UserRow(id: '#STF-\n88219', name: 'Marcus\nThorne', role: 'Product\nManager', roleBg: Color(0xFFFFEFE4), roleColor: Color(0xFFC2410C), avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfwPn_qVoRL6K7HE0wY3EsfPDX2vRhAyfnygRdbByTOyBmwjx-6hsoGdnTWRxZIWQWGIzFAWDXuqob1zjmJBOuYyk0FIFUfFMuValLavQ_9fO8gVPAwbcjd7o4u7hEwRyIoiwmgv45vzEB5BZgM73_lNpZnHrLYMmiLu-3b8ZjRp_V2Op-cDP8FcLV6XOt_vBmlKdrDkurbcAb7Urnrida7Fh8Z3UL98V9XtLnKyazzFZQQ1-vmbUVz6ay75MZyYIOSmXNxz4hBKE', email: 'm.thorne@e'),
    _UserRow(id: '#STF-\n77402', name: 'Amara\nOkafor', role: 'Operations\nLead', roleBg: Color(0xFFF3EDFF), roleColor: Color(0xFF6D28D9), avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXn6i2xTINZUhvekLo4kMWXs_vHp4pFLVInxucDIqSfKA9urbsfIOy4w8XODbj7t9Kks4HYxpzoxTGDjtNZrzX8GKqRaAeeP1dgkNO1iKKqBSeIfZESWuPGzA-aeSHNYEj_D3lHHJnSm62pCXnqvuWpYd9STrqVV9qsvRu6CRNN9QF9kTRWfPv3NRhvXeSDys-X6_Mxb5sJDRAoMYlDiZ0s1ytQmkbZwsXfAES2YJjcqTdF3NYXXp3jd-mJLTRPG_flpLbiJ19g-U', email: 'a.okafor@e'),
    _UserRow(id: '#STF-\n65128', name: 'David\nTuan', role: 'QA\nLead', roleBg: Color(0xFFE4F7ED), roleColor: Color(0xFF047857), initials: 'DT', email: 'd.tuan@ent'),
  ];

  Widget _numBtn(String text, bool active) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(color: active ? const Color(0xFF004AC6) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
    alignment: Alignment.center,
    child: Text(text, style: TextStyle(fontSize: 30 / 2, color: active ? Colors.white : const Color(0xFF252B3A), fontWeight: FontWeight.w600)),
  );

  Widget _pageBtn(IconData icon, bool enabled) => Container(width: 52, height: 52, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC9D0E1)), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: enabled ? const Color(0xFF3A4356) : const Color(0xFFC9CEDA)));
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.id, required this.name, required this.role, required this.roleBg, required this.roleColor, this.avatar, this.initials, required this.email});
  final String id;
  final String name;
  final String role;
  final Color roleBg;
  final Color roleColor;
  final String? avatar;
  final String? initials;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD9DEEA)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(id, style: const TextStyle(fontSize: 38 / 2, color: Color(0xFF6B7385), height: 1.25))),
        Expanded(
          flex: 3,
          child: Row(children: [
            avatar != null
                ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar!))
                : CircleAvatar(radius: 20, backgroundColor: const Color(0xFFC8D7F8), child: Text(initials!, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF004AC6)))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.1)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(999)), child: Text(role, style: TextStyle(fontSize: 32 / 2, color: roleColor, height: 1.2)))])),
          ]),
        ),
        Expanded(flex: 2, child: Text(email, style: const TextStyle(fontSize: 35 / 2, color: Color(0xFF1E2433)))),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(color: AppPalette.surface, border: Border(top: BorderSide(color: AppPalette.borderNeutral))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
        _Nav(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        _Nav(icon: Icons.group_outlined, label: 'Staff', active: true),
        _Nav(icon: Icons.assignment_outlined, label: 'Tasks'),
        _Nav(icon: Icons.settings_outlined, label: 'Settings'),
      ]),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({required this.icon, required this.label, this.active = false});
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: active ? 14 : 8, vertical: 4),
      decoration: active ? BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(14)) : null,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF1F2536)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 18 / 1.3, color: Color(0xFF1F2536)))]),
    );
  }
}

const TextStyle _h = TextStyle(fontSize: 32 / 2, fontWeight: FontWeight.w600, color: Color(0xFF323848), height: 1.15);
