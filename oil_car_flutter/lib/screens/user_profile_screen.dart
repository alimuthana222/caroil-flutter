import 'package:flutter/material.dart';
import 'package:oil_finder/services/supabase_auth_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await SupabaseAuthService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showAlert(QuickAlertType.error, 'فشل في تحميل الملف الشخصي');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseAuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sign_out':
                  _signOut();
                  break;
                case 'delete_account':
                  _showDeleteAccountDialog();
                  break;
                case 'refresh':
                  _refreshProfile();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('تحديث'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_account',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف الحساب', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.withOpacity(0.1),
                        backgroundImage: _getProfileImageUrl() != null
                            ? NetworkImage(_getProfileImageUrl()!)
                            : null,
                        child: _getProfileImageUrl() == null
                            ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.green,
                        )
                            : null,
                      ),

                      SizedBox(height: 16),

                      // Name
                      Text(
                        _getDisplayName(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8),

                      // Email
                      Text(
                        user?.email ?? 'لا يوجد بريد إلكتروني',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16),

                      // Provider Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getProviderIcon(),
                              size: 16,
                              color: Colors.green[700],
                            ),
                            SizedBox(width: 6),
                            Text(
                              _getProviderName(),
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Account Information
              _buildInfoSection(),

              SizedBox(height: 24),

              // Session Information
              _buildSessionSection(),

              SizedBox(height: 24),

              // Data & Privacy
              _buildDataSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final user = SupabaseAuthService.currentUser;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحساب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),

            SizedBox(height: 16),

            _buildInfoRow(
              'تاريخ الإنشاء',
              _userProfile?['created_at'] != null
                  ? _formatDate(_userProfile!['created_at'])
                  : user?.createdAt != null
                  ? _formatDate(user!.createdAt)
                  : 'غير محدد',
              Icons.calendar_today,
            ),

            _buildInfoRow(
              'آخر تحديث',
              _userProfile?['updated_at'] != null
                  ? _formatDate(_userProfile!['updated_at'])
                  : 'غير محدد',
              Icons.update,
            ),

            _buildInfoRow(
              'معرف المستخدم',
              user?.id ?? 'غير محدد',
              Icons.fingerprint,
            ),

            _buildInfoRow(
              'البريد الإلكتروني',
              user?.email ?? 'غير محدد',
              Icons.email,
            ),

            if (user?.phone != null)
              _buildInfoRow(
                'رقم الهاتف',
                user!.phone!,
                Icons.phone,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSection() {
    final session = SupabaseAuthService.currentSession;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الجلسة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),

            SizedBox(height: 16),

            _buildInfoRow(
              'حالة الجلسة',
              session != null ? 'نشطة' : 'غير نشطة',
              Icons.circle,
              valueColor: session != null ? Colors.green : Colors.red,
            ),

            if (session != null) ...[
              _buildInfoRow(
                'انتهاء الجلسة',
                session.expiresAt != null
                    ? _formatDate(session.expiresAt!)
                    : 'غير محدد',
                Icons.schedule,
              ),

              _buildInfoRow(
                'نوع الرمز المميز',
                session.tokenType ?? 'Bearer',
                Icons.security,
              ),

              _buildInfoRow(
                'آخر تحديث للرمز',
                session.refreshToken != null ? 'متوفر' : 'غير متوفر',
                Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البيانات والخصوصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: Icon(Icons.refresh, color: Colors.blue),
              title: Text('تحديث الجلسة'),
              subtitle: Text('تحديث رمز المصادقة'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _refreshSession,
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.edit, color: Colors.orange),
              title: Text('تحديث الملف الشخصي'),
              subtitle: Text('تعديل اسم العرض'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _editProfile,
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('تصدير البيانات'),
              subtitle: Text('تحميل نسخة من بياناتك'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _exportData,
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.purple),
              title: Text('سياسة الخصوصية'),
              subtitle: Text('اطلع على كيفية استخدام بياناتك'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPrivacyPolicy,
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text('حذف الحساب', style: TextStyle(color: Colors.red)),
              subtitle: Text('حذف نهائي للحساب وجميع البيانات'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getProfileImageUrl() {
    final user = SupabaseAuthService.currentUser;
    return _userProfile?['photo_url'] ??
        user?.userMetadata?['avatar_url'] ??
        user?.userMetadata?['picture'];
  }

  String _getDisplayName() {
    final user = SupabaseAuthService.currentUser;
    return _userProfile?['display_name'] ??
        user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        'مستخدم';
  }

  IconData _getProviderIcon() {
    final user = SupabaseAuthService.currentUser;
    final provider = _userProfile?['provider'] ??
        user?.appMetadata?['provider'];

    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      default:
        return Icons.account_circle;
    }
  }

  String _getProviderName() {
    final user = SupabaseAuthService.currentUser;
    final provider = _userProfile?['provider'] ??
        user?.appMetadata?['provider'];

    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return 'غير محدد';

    try {
      DateTime date;
      if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else if (dateInput is DateTime) {
        date = dateInput;
      } else {
        return 'غير محدد';
      }

      // Format to local time
      final localDate = date.toLocal();
      return '${localDate.day}/${localDate.month}/${localDate.year} ${localDate.hour}:${localDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    await _loadUserProfile();
  }

  Future<void> _refreshSession() async {
    try {
      await SupabaseAuthService.refreshSession();
      await _refreshProfile();
      _showAlert(QuickAlertType.success, 'تم تحديث الجلسة بنجاح');
    } catch (e) {
      _showAlert(QuickAlertType.error, 'فشل في تحديث الجلسة: ${e.toString()}');
    }
  }

  Future<void> _editProfile() async {
    final currentDisplayName = _getDisplayName();
    final TextEditingController nameController = TextEditingController(
      text: currentDisplayName != 'مستخدم' ? currentDisplayName : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديث الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم العرض',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDisplayName(nameController.text.trim());
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDisplayName(String newName) async {
    if (newName.isEmpty) {
      _showAlert(QuickAlertType.warning, 'يرجى إدخال اسم صحيح');
      return;
    }

    try {
      await SupabaseAuthService.updateUserProfile({
        'display_name': newName,
      });

      await _refreshProfile();
      _showAlert(QuickAlertType.success, 'تم تحديث الاسم بنجاح');
    } catch (e) {
      _showAlert(QuickAlertType.error, 'فشل في تحديث الاسم: ${e.toString()}');
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseAuthService.signOut();
      // AuthWrapper will handle navigation
    } catch (e) {
      _showAlert(QuickAlertType.error, 'فشل في تسجيل الخروج: ${e.toString()}');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الحساب'),
        content: Text(
          'هل أنت متأكد من حذف حسابك؟\n\n'
              'سيتم حذف جميع البيانات نهائياً ولا يمكن استرجاعها.\n\n'
              'ملاحظة: سيتم حذف البيانات وتسجيل الخروج.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تأكيد أخير'),
          content: Text(
            'هذا الإجراء لا يمكن التراجع عنه.\n\n'
                'اكتب "حذف" للتأكيد:',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await SupabaseAuthService.deleteAccount();
        // AuthWrapper will handle navigation
      }
    } catch (e) {
      _showAlert(
        QuickAlertType.error,
        'فشل في حذف الحساب: ${e.toString()}',
      );
    }
  }

  Future<void> _exportData() async {
    _showAlert(QuickAlertType.info, 'ميزة تصدير البيانات ستكون متاحة قريباً');
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سياسة الخصوصية'),
        content: SingleChildScrollView(
          child: Text(
            'سياسة الخصوصية لتطبيق Car Oil Finder\n\n'
                '1. جمع البيانات:\n'
                '   - نجمع المعلومات الأساسية للحساب\n'
                '   - سجلات تغيير الزيت التي تدخلها\n'
                '   - معلومات السيارات\n\n'
                '2. استخدام البيانات:\n'
                '   - تقديم خدمة تتبع تغيير الزيت\n'
                '   - إرسال تذكيرات الصيانة\n'
                '   - تحسين الخدمة\n\n'
                '3. حماية البيانات:\n'
                '   - جميع البيانات محمية بتشفير\n'
                '   - لا نشارك البيانات مع أطراف ثالثة\n'
                '   - يمكنك حذف حسابك في أي وقت\n\n'
                '4. حقوقك:\n'
                '   - الوصول إلى بياناتك\n'
                '   - تعديل بياناتك\n'
                '   - حذف حسابك\n'
                '   - تصدير بياناتك',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showAlert(QuickAlertType type, String message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: type,
        text: message,
        confirmBtnText: 'موافق',
      );
    }
  }
}