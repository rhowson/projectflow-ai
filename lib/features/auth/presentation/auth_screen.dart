import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _showEmailForm = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Check for biometric authentication on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAuth();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAuth() async {
    final hasLoggedInOnce = ref.read(hasLoggedInOnceProvider);
    final isBiometricEnabled = ref.read(isBiometricEnabledProvider);

    if (hasLoggedInOnce && isBiometricEnabled) {
      try {
        final success = await ref
            .read(authNotifierProvider.notifier)
            .authenticateWithBiometrics(
              reason: 'Sign in to ProjectFlow AI with biometrics',
            );

        if (success && mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        // Biometric authentication failed, show regular auth options
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: CustomNeumorphicTheme.errorRed,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildAuthContent(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Clean header
          _buildCleanHeader(),
          SizedBox(height: 56.h),
          
          // Main authentication content (flat design)
          _buildFlatAuthContent(),
        ],
      ),
    );
  }

  Widget _buildFlatAuthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_showEmailForm) ...[
          // Social sign-in options (flat)
          _buildFlatSocialButtons(),
          SizedBox(height: 32.h),
          
          // Divider
          _buildCleanDivider(),
          SizedBox(height: 32.h),
          
          // Email sign-in button (flat)
          _buildFlatEmailButton(),
        ] else ...[
          // Email form (flat)
          _buildFlatEmailForm(),
        ],
      ],
    );
  }

  Widget _buildCleanHeader() {
    return Column(
      children: [
        // App logo matching splash screen
        NeumorphicContainer(
          width: 80.w,
          height: 80.w,
          borderRadius: BorderRadius.circular(20.r),
          color: CustomNeumorphicTheme.primaryPurple,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomNeumorphicTheme.primaryPurple,
                  CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: CustomPaint(
                      painter: _LogoPatternPainter(),
                    ),
                  ),
                ),
                
                // Main logo content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AI Brain icon
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      
                      // Project management lines
                      Container(
                        width: 20.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8.w,
                            height: 1.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(0.5.r),
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Container(
                            width: 8.w,
                            height: 1.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(0.5.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
        
        // App title
        Text(
          'ProjectFlow AI',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: CustomNeumorphicTheme.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Subtitle
        Text(
          'Smart project management with AI',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CustomNeumorphicTheme.lightText,
          ),
        ),
      ],
    );
  }


  Widget _buildFlatSocialButtons() {
    return Column(
      children: [
        // Google Sign-In (flat)
        _buildFlatSignInButton(
          onPressed: _signInWithGoogle,
          icon: Icons.g_mobiledata,
          text: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: CustomNeumorphicTheme.darkText,
          borderColor: AppColors.border,
        ),
        
        // Apple Sign-In (iOS only, not available on web) - temporarily disabled
        if (false && !kIsWeb && Platform.isIOS) ...[
          SizedBox(height: 16.h),
          _buildFlatSignInButton(
            onPressed: _signInWithApple,
            icon: Icons.apple,
            text: 'Continue with Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildFlatSignInButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatEmailButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.baseColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _showEmailForm = true),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  color: CustomNeumorphicTheme.primaryPurple,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Continue with Email',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CustomNeumorphicTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => setState(() => _showEmailForm = false),
            icon: Icon(
              Icons.arrow_back_ios,
              color: CustomNeumorphicTheme.lightText,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Form title
        Text(
          _isSignUp ? 'Create Account' : 'Sign In',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CustomNeumorphicTheme.darkText,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        
        // Form fields
        if (_isSignUp) ...[
          _buildFlatTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
          _buildFlatTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
        ],
        
        _buildFlatTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        
        _buildFlatTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 32.h),
        
        // Submit button (flat)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.3),
                offset: Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submitEmailForm,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        
        // Toggle sign up/sign in
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(
            _isSignUp 
              ? 'Already have an account? Sign In'
              : 'Don\'t have an account? Sign Up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CustomNeumorphicTheme.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlatTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.baseColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: CustomNeumorphicTheme.darkText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
            color: CustomNeumorphicTheme.lightText,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            icon,
            color: CustomNeumorphicTheme.lightText,
            size: 20.sp,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildCleanSocialButtons() {
    return Column(
      children: [
        // Google Sign-In
        _buildCleanSignInButton(
          onPressed: _signInWithGoogle,
          icon: Icons.g_mobiledata,
          text: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: CustomNeumorphicTheme.darkText,
          borderColor: AppColors.border,
        ),
        
        // Apple Sign-In (iOS only, not available on web) - temporarily disabled until Firebase configured
        if (false && !kIsWeb && Platform.isIOS) ...[
          SizedBox(height: 16.h),
          _buildCleanSignInButton(
            onPressed: _signInWithApple,
            icon: Icons.apple,
            text: 'Continue with Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildCleanSignInButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return NeumorphicButton(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildCleanEmailButton() {
    return NeumorphicButton(
      onPressed: () => setState(() => _showEmailForm = true),
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: CustomNeumorphicTheme.baseColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.email_outlined,
            color: CustomNeumorphicTheme.primaryPurple,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            'Continue with Email',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CustomNeumorphicTheme.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => setState(() => _showEmailForm = false),
            icon: Icon(
              Icons.arrow_back_ios,
              color: CustomNeumorphicTheme.lightText,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Form title
        Text(
          _isSignUp ? 'Create Account' : 'Sign In',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CustomNeumorphicTheme.darkText,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        
        // Form fields
        if (_isSignUp) ...[
          _buildCleanTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
          _buildCleanTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
        ],
        
        _buildCleanTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        
        _buildCleanTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 32.h),
        
        // Submit button
        NeumorphicButton(
          onPressed: _submitEmailForm,
          borderRadius: BorderRadius.circular(16.r),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          color: CustomNeumorphicTheme.primaryPurple,
          child: Text(
            _isSignUp ? 'Create Account' : 'Sign In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        
        // Toggle sign up/sign in
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(
            _isSignUp 
              ? 'Already have an account? Sign In'
              : 'Don\'t have an account? Sign Up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CustomNeumorphicTheme.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return NeumorphicContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      borderRadius: BorderRadius.circular(12.r),
      color: CustomNeumorphicTheme.baseColor,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: CustomNeumorphicTheme.darkText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
            color: CustomNeumorphicTheme.lightText,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            icon,
            color: CustomNeumorphicTheme.lightText,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        NeumorphicContainer(
          width: 120.w,
          height: 120.w,
          borderRadius: BorderRadius.circular(30.r),
          color: CustomNeumorphicTheme.primaryPurple,
          child: Icon(
            Icons.rocket_launch,
            size: 60.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'ProjectFlow AI',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'AI-powered project management',
          style: TextStyle(
            fontSize: 16.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBiometricOption() {
    final hasLoggedInOnce = ref.watch(hasLoggedInOnceProvider);
    final isBiometricEnabled = ref.watch(isBiometricEnabledProvider);

    if (!hasLoggedInOnce || !isBiometricEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        NeumorphicButton(
          onPressed: _authenticateWithBiometrics,
          isSelected: true,
          selectedColor: CustomNeumorphicTheme.primaryPurple,
          borderRadius: BorderRadius.circular(16.r),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Sign in with Biometrics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _buildDivider(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSocialSignInButtons() {
    return Column(
      children: [
        // Google Sign-In
        NeumorphicButton(
          onPressed: _signInWithGoogle,
          borderRadius: BorderRadius.circular(16.r),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Continue with Google',
                style: TextStyle(
                  color: CustomNeumorphicTheme.darkText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Apple Sign-In (iOS only, not available on web) - temporarily disabled until Firebase configured
        if (false && !kIsWeb && Platform.isIOS) ...[
          NeumorphicButton(
            onPressed: _signInWithApple,
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Continue with Apple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ],
    );
  }

  Widget _buildEmailSignInButton() {
    return NeumorphicButton(
      onPressed: () {
        setState(() {
          _showEmailForm = true;
        });
      },
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.email_outlined,
            color: CustomNeumorphicTheme.primaryPurple,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            'Continue with Email',
            style: TextStyle(
              color: CustomNeumorphicTheme.primaryPurple,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle between Sign In and Sign Up
          _buildSignInSignUpToggle(),
          SizedBox(height: 24.h),

          // First Name and Last Name (Sign Up only)
          if (_isSignUp) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: (value) {
                      if (_isSignUp && (value == null || value.isEmpty)) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: (value) {
                      if (_isSignUp && (value == null || value.isEmpty)) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Password
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (_isSignUp && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Confirm Password (Sign Up only)
          if (_isSignUp) ...[
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (_isSignUp && value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
          ],

          // Submit Button
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authNotifierProvider);
              return NeumorphicButton(
                onPressed: authState.isLoading ? null : _submitEmailForm,
                isSelected: true,
                selectedColor: CustomNeumorphicTheme.primaryPurple,
                borderRadius: BorderRadius.circular(16.r),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: authState.isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),

          // Forgot Password (Sign In only)
          if (!_isSignUp) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: CustomNeumorphicTheme.primaryPurple,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignInSignUpToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSignUp = false;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: !_isSignUp ? CustomNeumorphicTheme.primaryPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !_isSignUp ? Colors.white : CustomNeumorphicTheme.darkText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSignUp = true;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: _isSignUp ? CustomNeumorphicTheme.primaryPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isSignUp ? Colors.white : CustomNeumorphicTheme.darkText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return NeumorphicContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      borderRadius: BorderRadius.circular(12.r),
      color: CustomNeumorphicTheme.baseColor,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: CustomNeumorphicTheme.lightText,
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: CustomNeumorphicTheme.lightText,
                    size: 20.sp,
                  ),
                )
              : null,
        ),
        style: TextStyle(
          fontSize: 16.sp,
          color: CustomNeumorphicTheme.darkText,
        ),
      ),
    );
  }

  Widget _buildBackToSocialButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _showEmailForm = false;
        });
      },
      child: Text(
        'Back to other sign-in options',
        style: TextStyle(
          color: CustomNeumorphicTheme.primaryPurple,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.h,
            color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'or',
            style: TextStyle(
              color: CustomNeumorphicTheme.lightText,
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.h,
            color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final userCredential = await ref
          .read(authNotifierProvider.notifier)
          .signInWithGoogle();

      if (userCredential != null && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      // Error is handled by the listener
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final userCredential = await ref
          .read(authNotifierProvider.notifier)
          .signInWithApple();

      if (userCredential != null && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      // Error is handled by the listener
    }
  }

  Future<void> _submitEmailForm() async {
    if (_showEmailForm && !_validateEmailForm()) return;

    try {
      if (_isSignUp) {
        // Create new account
        final userCredential = await ref.read(authNotifierProvider.notifier).createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );

        if (userCredential != null && mounted) {
          // Show success message for account creation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully! Please check your email for verification.'),
              backgroundColor: CustomNeumorphicTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
          context.go('/dashboard');
        }
      } else {
        // Sign in existing user
        final userCredential = await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (userCredential != null && mounted) {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      // Enhanced error handling with specific messages
      if (mounted) {
        String errorMessage = _getErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: CustomNeumorphicTheme.errorRed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _validateEmailForm() {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      _showError('Email is required');
      return false;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }
    
    if (_passwordController.text.isEmpty) {
      _showError('Password is required');
      return false;
    }
    
    if (_isSignUp) {
      if (_firstNameController.text.trim().isEmpty) {
        _showError('First name is required');
        return false;
      }
      
      if (_lastNameController.text.trim().isEmpty) {
        _showError('Last name is required');
        return false;
      }
      
      if (_passwordController.text.length < 6) {
        _showError('Password must be at least 6 characters long');
        return false;
      }
    }
    
    return true;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
    }
  }

  String _getErrorMessage(String error) {
    // Firebase Auth error codes mapping
    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('internal-error')) {
      return 'An internal error occurred. Please try again.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .authenticateWithBiometrics(
            reason: 'Sign in to ProjectFlow AI',
          );

      if (success && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric authentication failed: $e'),
          backgroundColor: CustomNeumorphicTheme.errorRed,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: CustomNeumorphicTheme.lightText,
                fontSize: 14.sp,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                try {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .resetPassword(emailController.text.trim());
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: CustomNeumorphicTheme.errorRed,
                    ),
                  );
                }
              }
            },
            isSelected: true,
            selectedColor: CustomNeumorphicTheme.primaryPurple,
            borderRadius: BorderRadius.circular(10.r),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Send Reset Link',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the logo background pattern (matching splash screen)
class _LogoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw interconnected nodes pattern
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = (size.width / 4) * (i + 1);
        final y = (size.height / 4) * (j + 1);
        
        // Draw node
        canvas.drawCircle(Offset(x, y), 1.5, paint);
        
        // Draw connections
        if (i < 2) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + size.width / 4, y),
            paint,
          );
        }
        if (j < 2) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + size.height / 4),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}