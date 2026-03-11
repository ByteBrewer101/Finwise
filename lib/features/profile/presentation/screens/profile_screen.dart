import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../domain/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                e.toString(),
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (profile) => _ProfileContent(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneDisplay = (profile.phone == null || profile.phone!.trim().isEmpty)
        ? 'Not set'
        : profile.phone!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Profile',
                  style: AppTextStyles.headingLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ProfileHeader(
                profile: profile,
                onEditPressed: () => _showEditProfileSheet(context, ref, profile),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Account Settings',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => _showEditProfileSheet(context, ref, profile),
              ),
              _SettingsTile(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                trailingText: phoneDisplay,
                onTap: () => _showEditProfileSheet(context, ref, profile),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => _showChangePasswordSheet(context, ref),
              ),
              _SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(
            label: 'Logout',
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).signOut();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section is not available yet')),
    );
  }

  Future<void> _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    final avatarUrlController = TextEditingController(text: profile.avatarUrl ?? '');
    var isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Profile', style: AppTextStyles.headingMedium),
                        const SizedBox(height: AppSpacing.lg),
                        AppInputField(
                          label: 'Full Name',
                          controller: fullNameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppInputField(
                          label: 'Phone Number',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppInputField(
                          label: 'Avatar URL',
                          controller: avatarUrlController,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: isSaving ? 'Saving...' : 'Save',
                          isLoading: isSaving,
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;

                                  setState(() => isSaving = true);
                                  try {
                                    await ref.read(profileProvider.notifier).updateProfile(
                                          fullName: fullNameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                          avatarUrl: avatarUrlController.text.trim(),
                                        );

                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile updated'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isSaving = false);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }

  Future<void> _showChangePasswordSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change Password', style: AppTextStyles.headingMedium),
                        const SizedBox(height: AppSpacing.lg),
                        AppInputField(
                          label: 'Current Password',
                          controller: currentPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppInputField(
                          label: 'New Password',
                          controller: newPasswordController,
                          obscureText: true,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return 'Enter new password';
                            if (trimmed.length < 8 || trimmed.length > 32) {
                              return 'Password must be 8-32 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppInputField(
                          label: 'Confirm Password',
                          controller: confirmPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').trim() != newPasswordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: isSaving ? 'Updating...' : 'Update Password',
                          isLoading: isSaving,
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setState(() => isSaving = true);
                                  try {
                                    await ref.read(authRepositoryProvider).changePassword(
                                          currentPassword:
                                              currentPasswordController.text.trim(),
                                          newPassword:
                                              newPasswordController.text.trim(),
                                        );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password updated'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Current password is incorrect or password update failed',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isSaving = false);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPressed;
  static const String _sampleAvatarUrl =
      'https://i.pravatar.cc/300?img=12';

  const _ProfileHeader({
    required this.profile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.card,
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.divider,
                backgroundImage: NetworkImage(_sampleAvatarUrl),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: GestureDetector(
                  onTap: onEditPressed,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(profile.fullName, style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(profile.email, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        trailing: trailingText == null
            ? const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingText!,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
