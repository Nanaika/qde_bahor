import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qde_eco_bahor/core/theme/theme_border_styles.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_bloc.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        context.read<AuthBloc>().add(
              AuthEvent.login(
                _emailController.text.trim(),
                _passwordController.text,
              ),
            );
      } else {
        context.read<AuthBloc>().add(
              AuthEvent.register(
                _emailController.text.trim(),
                _passwordController.text,
                _nameController.text.trim(),
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ThemeDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLogin ? 'auth.login'.tr() : 'auth.register'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24.sp,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'auth.email'.tr(),
                  labelStyle: TextStyle(fontSize: 16.sp),
                  prefixIcon: Icon(Icons.email, size: 24.sp),
                  border: ThemeBorderStyles.inputBorder(context),
                  enabledBorder: ThemeBorderStyles.inputBorder(context),
                  focusedBorder: ThemeBorderStyles.inputBorderFocused(context),
                  errorBorder: ThemeBorderStyles.inputBorderError(context),
                  focusedErrorBorder: ThemeBorderStyles.inputBorderError(context),
                  disabledBorder: ThemeBorderStyles.inputBorderDisabled(context),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'auth.email_required'.tr();
                  }
                  if (!value.contains('@')) {
                    return 'auth.email_invalid'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'auth.name'.tr(),
                    labelStyle: TextStyle(fontSize: 16.sp),
                    prefixIcon: Icon(Icons.person, size: 24.sp),
                    border: ThemeBorderStyles.inputBorder(context),
                    enabledBorder: ThemeBorderStyles.inputBorder(context),
                    focusedBorder: ThemeBorderStyles.inputBorderFocused(context),
                    errorBorder: ThemeBorderStyles.inputBorderError(context),
                    focusedErrorBorder: ThemeBorderStyles.inputBorderError(context),
                    disabledBorder: ThemeBorderStyles.inputBorderDisabled(context),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.name_required'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'auth.password'.tr(),
                  labelStyle: TextStyle(fontSize: 16.sp),
                  prefixIcon: Icon(Icons.lock, size: 24.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: ThemeBorderStyles.inputBorder(context),
                  enabledBorder: ThemeBorderStyles.inputBorder(context),
                  focusedBorder: ThemeBorderStyles.inputBorderFocused(context),
                  errorBorder: ThemeBorderStyles.inputBorderError(context),
                  focusedErrorBorder: ThemeBorderStyles.inputBorderError(context),
                  disabledBorder: ThemeBorderStyles.inputBorderDisabled(context),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'auth.password_required'.tr();
                  }
                  if (value.length < 6) {
                    return 'auth.password_min_length'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: ThemeDimensions.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'auth.submit'.tr(),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'auth.no_account'.tr() : 'auth.has_account'.tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
