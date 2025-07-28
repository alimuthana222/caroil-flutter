import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ar';
  String _selectedRegion = 'Middle East';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      if (AuthService.isAuthenticated) {
        final profile = await AuthService.getUserProfile();
        setState(() {
          _userProfile = profile;
          _notificationsEnabled = profile?.notificationsEnabled ?? true;
          _selectedLanguage = profile?.preferredLanguage ?? 'ar';
          _selectedRegion = profile?.region ?? 'Middle East';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (AuthService.isAuthenticated) ...[
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildAppPreferences(),
                  const SizedBox(height: 24),
                  _buildNotificationSettings(),
                  const SizedBox(height: 24),
                  _buildSupportSection(),
                  const SizedBox(height: 24),
                  if (AuthService.isAuthenticated) ...[
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الملف الشخصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                backgroundImage: _userProfile?.avatarUrl != null
                    ? NetworkImage(_userProfile!.avatarUrl!)
                    : null,
                child: _userProfile?.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.blue[700],
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?.fullName ?? 'المستخدم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_userProfile?.phoneNumber != null)
                      Text(
                        _userProfile!.phoneNumber!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences() {
    return _buildSection(
      title: 'تفضيلات التطبيق',
      children: [
        _buildSettingsTile(
          title: 'اللغة',
          subtitle: _selectedLanguage == 'ar' ? 'العربية' : 'English',
          icon: Icons.language,
          onTap: _showLanguageDialog,
        ),
        _buildSettingsTile(
          title: 'المنطقة',
          subtitle: _selectedRegion,
          icon: Icons.location_on,
          onTap: _showRegionDialog,
        ),
        _buildSettingsTile(
          title: 'الوحدات',
          subtitle: 'كيلومتر، لتر',
          icon: Icons.straighten,
          onTap: _showUnitsDialog,
        ),
        _buildSettingsTile(
          title: 'العملة',
          subtitle: 'ريال سعودي (SAR)',
          icon: Icons.money,
          onTap: _showCurrencyDialog,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSection(
      title: 'الإشعارات',
      children: [
        _buildSwitchTile(
          title: 'تذكير الصيانة',
          subtitle: 'إشعارات موعد الصيانة القادمة',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _updateNotificationSettings();
          },
        ),
        _buildSwitchTile(
          title: 'تحديثات التطبيق',
          subtitle: 'إشعارات الميزات الجديدة',
          value: true,
          onChanged: (value) {},
        ),
        _buildSwitchTile(
          title: 'العروض الخاصة',
          subtitle: 'إشعارات العروض والخصومات',
          value: false,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'الدعم والمساعدة',
      children: [
        _buildSettingsTile(
          title: 'الأسئلة الشائعة',
          icon: Icons.help_outline,
          onTap: () => _showFeatureNotImplemented('الأسئلة الشائعة'),
        ),
        _buildSettingsTile(
          title: 'تواصل معنا',
          icon: Icons.support_agent,
          onTap: () => _showFeatureNotImplemented('تواصل معنا'),
        ),
        _buildSettingsTile(
          title: 'تقييم التطبيق',
          icon: Icons.star_rate,
          onTap: () => _showFeatureNotImplemented('تقييم التطبيق'),
        ),
        _buildSettingsTile(
          title: 'مشاركة التطبيق',
          icon: Icons.share,
          onTap: () => _showFeatureNotImplemented('مشاركة التطبيق'),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'الحساب',
      children: [
        _buildSettingsTile(
          title: 'تغيير كلمة المرور',
          icon: Icons.lock,
          onTap: _changePassword,
        ),
        _buildSettingsTile(
          title: 'تصدير البيانات',
          icon: Icons.download,
          onTap: () => _showFeatureNotImplemented('تصدير البيانات'),
        ),
        _buildSettingsTile(
          title: 'حذف الحساب',
          icon: Icons.delete_forever,
          textColor: Colors.red,
          onTap: _showDeleteAccountDialog,
        ),
        _buildSettingsTile(
          title: 'تسجيل الخروج',
          icon: Icons.logout,
          onTap: _signOut,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'حول التطبيق',
      children: [
        _buildSettingsTile(
          title: 'الإصدار',
          subtitle: '1.0.0',
          icon: Icons.info,
          showArrow: false,
        ),
        _buildSettingsTile(
          title: 'الشروط والأحكام',
          icon: Icons.description,
          onTap: () => _showFeatureNotImplemented('الشروط والأحكام'),
        ),
        _buildSettingsTile(
          title: 'سياسة الخصوصية',
          icon: Icons.privacy_tip,
          onTap: () => _showFeatureNotImplemented('سياسة الخصوصية'),
        ),
        _buildSettingsTile(
          title: 'التراخيص مفتوحة المصدر',
          icon: Icons.code,
          onTap: () => _showFeatureNotImplemented('التراخيص'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? textColor,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500]),
            )
          : null,
      trailing: showArrow && onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey[400])
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500]),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue[700],
    );
  }

  void _editProfile() {
    // TODO: Implement profile editing
    _showFeatureNotImplemented('تعديل الملف الشخصي');
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
                _updateLanguage();
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
                _updateLanguage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionDialog() {
    final regions = [
      'Middle East',
      'USA',
      'Europe',
      'Asia',
      'Africa',
      'Australia',
      'South America',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار المنطقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: regions
              .map((region) => RadioListTile<String>(
                    title: Text(region),
                    value: region,
                    groupValue: _selectedRegion,
                    onChanged: (value) {
                      setState(() => _selectedRegion = value!);
                      Navigator.pop(context);
                      _updateRegion();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    _showFeatureNotImplemented('إعدادات الوحدات');
  }

  void _showCurrencyDialog() {
    _showFeatureNotImplemented('إعدادات العملة');
  }

  void _changePassword() {
    // TODO: Implement password change
    _showFeatureNotImplemented('تغيير كلمة المرور');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ سيتم حذف جميع بياناتك نهائياً ولا يمكن استرجاعها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureNotImplemented('حذف الحساب');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await AuthService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تسجيل الخروج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateNotificationSettings() {
    // TODO: Update notification settings in database
  }

  void _updateLanguage() {
    // TODO: Update language preference
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث اللغة')),
    );
  }

  void _updateRegion() {
    // TODO: Update region preference
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث المنطقة')),
    );
  }

  void _showFeatureNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ميزة "$feature" قيد التطوير')),
    );
  }
}