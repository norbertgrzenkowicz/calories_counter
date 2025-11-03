import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_logger.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../models/subscription.dart';
import '../services/profile_service.dart';
import '../services/nutrition_calculator_service.dart';
import '../providers/subscription_provider.dart';
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  void _loadProfile() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
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
        heightCm: double.parse(_heightController.text),
        currentWeightKg: double.parse(_weightController.text),
        targetWeightKg: _targetWeightController.text.isNotEmpty
            ? double.parse(_targetWeightController.text)
            : null,
        dateOfBirth: _dateOfBirth,
        goal: _selectedGoal,
        activityLevel:
            NutritionCalculatorService.getPALValue(_selectedActivityKey),
        weeklyWeightLossTarget: double.parse(_weeklyTargetController.text),
        weightLossStartDate: _selectedGoal == 'weight_loss' &&
                _currentProfile?.weightLossStartDate == null
            ? DateTime.now()
            : _currentProfile?.weightLossStartDate,
        initialWeightKg: _selectedGoal == 'weight_loss' &&
                _currentProfile?.initialWeightKg == null
            ? double.parse(_weightController.text)
            : _currentProfile?.initialWeightKg,
      );

      AppLogger.debug('Profile object created');
      AppLogger.debug(
          'Has required data: ${profile.hasRequiredDataForCalculations}');

      final savedProfile = await profileService.saveUserProfile(profile);
      AppLogger.info('Profile saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving profile', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscription',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _buildStatusBadge(subscription),
              ],
            ),
            const SizedBox(height: 20),
            _buildSubscriptionDetails(subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Subscription? subscription) {
    if (subscription == null || subscription.status == SubscriptionStatus.free) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              'Free',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    Color badgeColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (subscription.status) {
      case SubscriptionStatus.trialing:
        badgeColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.access_time;
        statusText = 'Trial';
        break;
      case SubscriptionStatus.active:
        badgeColor = AppTheme.neonGreen.withOpacity(0.1);
        textColor = AppTheme.neonGreen;
        icon = Icons.check_circle;
        statusText = 'Premium';
        break;
      case SubscriptionStatus.pastDue:
        badgeColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.warning_amber;
        statusText = 'Past Due';
        break;
      case SubscriptionStatus.canceled:
        badgeColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        statusText = 'Canceled';
        break;
      default:
        badgeColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.star_border;
        statusText = 'Free';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
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
    if (subscription == null || subscription.status == SubscriptionStatus.free) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: 'Free Tier',
            valueColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.star_border,
            label: 'Plan',
            value: 'Limited features',
            valueColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
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
      return Colors.red.shade700;
    } else if (difference.inDays <= 3) {
      return Colors.orange.shade700;
    }

    return AppTheme.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          title: const Text('Your Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
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
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wc),
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
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.cake),
                            suffixIcon: const Icon(Icons.calendar_today),
                            hintText: _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select date of birth',
                          ),
                          onTap: _selectDateOfBirth,
                          validator: (value) {
                            if (_dateOfBirth == null) {
                              return 'Please select your date of birth';
                            }
                            final age =
                                DateTime.now().year - _dateOfBirth!.year;
                            if (age < 13 || age > 100) {
                              return 'Please enter a valid date of birth';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subscription Status Card
                _buildSubscriptionCard(),

                const SizedBox(height: 20),

                // Physical Characteristics Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Physical Characteristics',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.height),
                            suffixText: 'cm',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final height = double.tryParse(value);
                            if (height == null ||
                                height < 100 ||
                                height > 250) {
                              return 'Please enter a valid height (100-250 cm)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Current Weight (kg)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight),
                            suffixText: 'kg',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current weight';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight < 30 || weight > 300) {
                              return 'Please enter a valid weight (30-300 kg)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _targetWeightController,
                          decoration: const InputDecoration(
                            labelText: 'Target Weight (kg) - Optional',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.flag),
                            suffixText: 'kg',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final weight = double.tryParse(value);
                              if (weight == null ||
                                  weight < 30 ||
                                  weight > 300) {
                                return 'Please enter a valid target weight (30-300 kg)';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Goals Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goals & Targets',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Primary Goal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
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
                              backgroundColor: AppTheme.borderColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.darkBackground
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedGoal == 'weight_loss' ||
                            _selectedGoal == 'weight_gain') ...[
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _weeklyTargetController,
                            decoration: InputDecoration(
                              labelText: _selectedGoal == 'weight_loss'
                                  ? 'Weekly Weight Loss Target (kg)'
                                  : 'Weekly Weight Gain Target (kg)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.trending_down),
                              suffixText: 'kg/week',
                              helperText:
                                  'Recommended: 0.5-1.0 kg/week for sustainable results',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter weekly target';
                              }
                              final target = double.tryParse(value);
                              if (target == null ||
                                  target <= 0 ||
                                  target > 2.0) {
                                return 'Please enter a valid target (0.1-2.0 kg/week)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Activity Level Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Level',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        ...NutritionCalculatorService.activityLevels.entries
                            .map((entry) {
                          final isSelected = _selectedActivityKey == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () => setState(
                                  () => _selectedActivityKey = entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.neonGreen.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.neonGreen
                                        : AppTheme.borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: entry.key,
                                      groupValue: _selectedActivityKey,
                                      onChanged: (value) => setState(
                                          () => _selectedActivityKey = value!),
                                      activeColor: AppTheme.neonGreen,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            NutritionCalculatorService
                                                    .activityDescriptions[
                                                entry.key]!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                          Text(
                                            'PAL: ${entry.value}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
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
                ),

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: AppTheme.darkBackground,
                    padding: const EdgeInsets.all(16),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Profile'),
                ),
              ],
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
