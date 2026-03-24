import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_logger.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../models/subscription.dart';
import '../services/profile_service.dart';
import '../services/nutrition_calculator_service.dart';
import '../providers/subscription_provider.dart';
import '../utils/app_page_route.dart';
import '../utils/app_snackbar.dart';
import '../utils/input_sanitizer.dart';
import '../widgets/keyboard_toolbar.dart';
import 'subscription_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _weeklyTargetController = TextEditingController();

  final _heightFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _targetWeightFocusNode = FocusNode();
  final _weeklyTargetFocusNode = FocusNode();

  String _selectedGender = 'male';
  String _selectedGoal = 'maintaining';
  String _selectedActivityKey = 'sedentary';
  DateTime? _dateOfBirth;

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  UserProfile? _currentProfile;

  final List<String> _genders = ['male', 'female'];
  final List<String> _goals = [
    'maintaining',
    'weight_loss',
    'weight_gain',
    'hypertrophy'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Refresh subscription status when screen loads
    Future.microtask(() {
      ref.read(subscriptionNotifierProvider.notifier).fetchSubscriptionStatus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _weeklyTargetController.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    _targetWeightFocusNode.dispose();
    _weeklyTargetFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);

    try {
      final profileService = ProfileService();
      final profile = await profileService.getUserProfile();

      if (profile != null) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.fullName ?? '';
          _heightController.text = profile.heightCm.toString();
          _weightController.text = profile.currentWeightKg.toString();
          _targetWeightController.text =
              profile.targetWeightKg?.toString() ?? '';
          _weeklyTargetController.text =
              profile.weeklyWeightLossTarget.toString();
          _selectedGender = profile.gender;
          _selectedGoal = profile.goal;
          _selectedActivityKey =
              NutritionCalculatorService.getActivityKey(profile.activityLevel);
          _dateOfBirth = profile.dateOfBirth;
        });
      } else {
        // Initialize with defaults for new profile
        _weeklyTargetController.text = '0.5';
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error loading profile: $e');
      }
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileService = ProfileService();

      AppLogger.logUserAction('profile_creation_attempt');
      // Note: Profile data not logged for privacy
      // Weekly target not logged for privacy

      final profile = UserProfile(
        id: _currentProfile?.id,
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
        heightCm: InputSanitizer.parseDouble(_heightController.text)!,
        currentWeightKg: InputSanitizer.parseDouble(_weightController.text)!,
        targetWeightKg: _targetWeightController.text.isNotEmpty
            ? InputSanitizer.parseDouble(_targetWeightController.text)
            : null,
        dateOfBirth: _dateOfBirth,
        goal: _selectedGoal,
        activityLevel:
            NutritionCalculatorService.getPALValue(_selectedActivityKey),
        weeklyWeightLossTarget: InputSanitizer.parseDouble(_weeklyTargetController.text)!,
        weightLossStartDate: _selectedGoal == 'weight_loss' &&
                _currentProfile?.weightLossStartDate == null
            ? DateTime.now()
            : _currentProfile?.weightLossStartDate,
        initialWeightKg: _selectedGoal == 'weight_loss' &&
                _currentProfile?.initialWeightKg == null
            ? InputSanitizer.parseDouble(_weightController.text)
            : _currentProfile?.initialWeightKg,
      );

      AppLogger.debug('Profile object created');
      AppLogger.debug(
          'Has required data: ${profile.hasRequiredDataForCalculations}');

      final savedProfile = await profileService.saveUserProfile(profile);
      AppLogger.info('Profile saved successfully');

      if (mounted) {
        AppSnackbar.success(context, 'Profile saved successfully!');
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving profile', e, stackTrace);

      if (mounted) {
        AppSnackbar.error(context, 'Error saving profile: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
    );

    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  String _getGoalDisplayName(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'maintaining':
        return 'Maintaining';
      case 'hypertrophy':
        return 'Hypertrophy';
      default:
        return goal;
    }
  }

  Widget _buildSubscriptionCard() {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscription = subscriptionState.subscription;

    if (subscriptionState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUBSCRIPTION',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: CircularProgressIndicator(color: AppTheme.neonGreen),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUBSCRIPTION',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              _buildStatusBadge(subscription),
            ],
          ),
          const SizedBox(height: 20),
          _buildSubscriptionDetails(subscription),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Subscription? subscription) {
    Color badgeColor;
    Color textColor;
    IconData icon;
    String statusText;

    if (subscription == null ||
        subscription.status == SubscriptionStatus.free) {
      badgeColor = AppTheme.surfaceContainerHigh;
      textColor = AppTheme.textSecondary;
      icon = Icons.star_border;
      statusText = 'Free';
    } else {
      switch (subscription.status) {
        case SubscriptionStatus.trialing:
          badgeColor = AppTheme.neonBlue.withOpacity(0.12);
          textColor = AppTheme.neonBlue;
          icon = Icons.access_time;
          statusText = 'Trial';
          break;
        case SubscriptionStatus.active:
          badgeColor = AppTheme.neonGreen.withOpacity(0.12);
          textColor = AppTheme.neonGreen;
          icon = Icons.check_circle;
          statusText = 'Premium';
          break;
        case SubscriptionStatus.pastDue:
          badgeColor = AppTheme.neonOrange.withOpacity(0.12);
          textColor = AppTheme.neonOrange;
          icon = Icons.warning_amber;
          statusText = 'Past Due';
          break;
        case SubscriptionStatus.canceled:
          badgeColor = AppTheme.neonRed.withOpacity(0.12);
          textColor = AppTheme.neonRed;
          icon = Icons.cancel;
          statusText = 'Canceled';
          break;
        default:
          badgeColor = AppTheme.surfaceContainerHigh;
          textColor = AppTheme.textSecondary;
          icon = Icons.star_border;
          statusText = 'Free';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(Subscription? subscription) {
    if (subscription == null ||
        subscription.status == SubscriptionStatus.free) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: 'Free Tier',
            valueColor: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.star_border,
            label: 'Plan',
            value: 'Limited features',
            valueColor: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  AppPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade to Premium'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.neonGreen,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          icon: Icons.card_membership,
          label: 'Plan',
          value: subscription.tier?.toDisplayString() ?? 'N/A',
          valueColor: AppTheme.textPrimary,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          icon: Icons.check_circle_outline,
          label: 'Status',
          value: subscription.status.toDisplayString(),
          valueColor: AppTheme.textPrimary,
        ),
        if (subscription.status == SubscriptionStatus.trialing &&
            subscription.trialEndsAt != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Trial Ends',
            value: _formatRemainingTime(subscription.trialEndsAt!),
            valueColor: _getTimeColor(subscription.trialEndsAt!),
          ),
        ],
        if (subscription.status == SubscriptionStatus.active &&
            subscription.subscriptionEndDate != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Next Payment',
            value: _formatRemainingTime(subscription.subscriptionEndDate!),
            valueColor: AppTheme.textPrimary,
          ),
        ],
        if (subscription.subscriptionEndDate != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.event,
            label: 'Renewal Date',
            value: _formatDate(subscription.subscriptionEndDate!),
            valueColor: AppTheme.textSecondary,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRemainingTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months month${months > 1 ? 's' : ''}';
    }

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }

    if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    }

    return 'Less than 1 hour';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTimeColor(DateTime date) {
    final difference = date.difference(DateTime.now());

    if (difference.inDays <= 1) {
      return AppTheme.neonRed;
    } else if (difference.inDays <= 3) {
      return AppTheme.neonOrange;
    }

    return AppTheme.textPrimary;
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadProfile(),
      ref.read(subscriptionNotifierProvider.notifier).fetchSubscriptionStatus(),
    ]);
  }

  // Silent input decoration helper for profile fields
  InputDecoration _silentInput({
    required String label,
    String? suffixText,
    Widget? suffixIcon,
    String? hintText,
    Widget? prefixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AppTheme.neonGreen, fontSize: 12),
      hintText: hintText,
      hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      suffixText: suffixText,
      suffixStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon != null
          ? IconTheme(
              data: const IconThemeData(color: AppTheme.textTertiary, size: 18),
              child: prefixIcon,
            )
          : null,
      helperText: helperText,
      helperStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.15), width: 1),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.15), width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.neonGreen, width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.neonRed.withOpacity(0.6), width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.neonRed, width: 1.5),
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          title: const Text('YOUR PROFILE'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'YOUR PROFILE',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.08,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.neonGreen,
        backgroundColor: AppTheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // --- Personal Information ---
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERSONAL',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: _silentInput(
                            label: 'Full Name',
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          dropdownColor: AppTheme.surfaceContainerLow,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                          iconEnabledColor: AppTheme.textTertiary,
                          decoration: _silentInput(
                            label: 'Gender',
                            prefixIcon: const Icon(Icons.wc),
                          ),
                          items: _genders.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender.capitalize()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGender = value!);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: _silentInput(
                            label: 'Date of Birth',
                            prefixIcon: const Icon(Icons.cake),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.textTertiary,
                            ),
                            hintText: _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select date of birth',
                          ),
                          onTap: _selectDateOfBirth,
                          validator: (value) {
                            if (_dateOfBirth == null) {
                              return 'Please select your date of birth';
                            }
                            final age = DateTime.now().year - _dateOfBirth!.year;
                            if (age < 13 || age > 100) {
                              return 'Please enter a valid date of birth';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Subscription Status ---
                  _buildSubscriptionCard(),

                  const SizedBox(height: 16),

                  // --- Physical Characteristics ---
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BODY',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyboardToolbar(
                          focusNode: _heightFocusNode,
                          label: 'Height',
                          child: TextFormField(
                            controller: _heightController,
                            focusNode: _heightFocusNode,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: _silentInput(
                              label: 'Height',
                              prefixIcon: const Icon(Icons.height),
                              suffixText: 'cm',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your height';
                              }
                              final height = InputSanitizer.parseDouble(value);
                              if (height == null || height < 100 || height > 250) {
                                return 'Please enter a valid height (100-250 cm)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyboardToolbar(
                          focusNode: _weightFocusNode,
                          label: 'Current Weight',
                          child: TextFormField(
                            controller: _weightController,
                            focusNode: _weightFocusNode,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: _silentInput(
                              label: 'Current Weight',
                              prefixIcon: const Icon(Icons.monitor_weight),
                              suffixText: 'kg',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current weight';
                              }
                              final weight = InputSanitizer.parseDouble(value);
                              if (weight == null || weight < 30 || weight > 300) {
                                return 'Please enter a valid weight (30-300 kg)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyboardToolbar(
                          focusNode: _targetWeightFocusNode,
                          label: 'Target Weight',
                          child: TextFormField(
                            controller: _targetWeightController,
                            focusNode: _targetWeightFocusNode,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: _silentInput(
                              label: 'Target Weight — Optional',
                              prefixIcon: const Icon(Icons.flag),
                              suffixText: 'kg',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final weight = InputSanitizer.parseDouble(value);
                                if (weight == null || weight < 30 || weight > 300) {
                                  return 'Please enter a valid target weight (30-300 kg)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Goals & Targets ---
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GOALS',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Primary Goal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: -0.26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _goals.map((goal) {
                            final isSelected = _selectedGoal == goal;
                            return ChoiceChip(
                              label: Text(_getGoalDisplayName(goal)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedGoal = goal);
                              },
                              selectedColor: AppTheme.neonGreen,
                              backgroundColor: AppTheme.surfaceContainerHigh,
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF003919)
                                    : AppTheme.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide.none,
                              ),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        if (_selectedGoal == 'weight_loss' ||
                            _selectedGoal == 'weight_gain') ...[
                          const SizedBox(height: 20),
                          KeyboardToolbar(
                            focusNode: _weeklyTargetFocusNode,
                            label: 'Weekly Target',
                            child: TextFormField(
                              controller: _weeklyTargetController,
                              focusNode: _weeklyTargetFocusNode,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: _silentInput(
                                label: _selectedGoal == 'weight_loss'
                                    ? 'Weekly Weight Loss Target'
                                    : 'Weekly Weight Gain Target',
                                prefixIcon: const Icon(Icons.trending_down),
                                suffixText: 'kg/week',
                                helperText:
                                    'Recommended: 0.5-1.0 kg/week for sustainable results',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter weekly target';
                                }
                                final target =
                                    InputSanitizer.parseDouble(value);
                                if (target == null ||
                                    target <= 0 ||
                                    target > 2.0) {
                                  return 'Please enter a valid target (0.1-2.0 kg/week)';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Activity Level ---
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACTIVITY',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...NutritionCalculatorService.activityLevels.entries
                            .map((entry) {
                          final isSelected = _selectedActivityKey == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: InkWell(
                              onTap: () => setState(
                                  () => _selectedActivityKey = entry.key),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.surfaceContainerHigh
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: entry.key,
                                      groupValue: _selectedActivityKey,
                                      onChanged: (value) => setState(() =>
                                          _selectedActivityKey = value!),
                                      activeColor: AppTheme.neonGreen,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            NutritionCalculatorService
                                                    .activityDescriptions[
                                                entry.key]!,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textSecondary,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'PAL: ${entry.value}',
                                            style: const TextStyle(
                                              color: AppTheme.textTertiary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- Save Button: neon green with glow ---
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isLoading ? [] : AppTheme.neonGlowShadow(),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? AppTheme.surfaceContainerHigh
                            : AppTheme.neonGreen,
                        foregroundColor: _isLoading
                            ? AppTheme.textSecondary
                            : const Color(0xFF003919),
                        padding: const EdgeInsets.all(18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.textSecondary,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Profile'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
