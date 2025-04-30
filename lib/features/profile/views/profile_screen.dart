import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/profile/controllers/profile_controller.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _calculateAge(String? birthdayString) {
    if (birthdayString == null || birthdayString.isEmpty) {
      return '-- yo';
    }
    try {
      final birthDate = DateFormat('yyyy-MM-dd').parse(birthdayString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age yo';
    } catch (e) {
      return '-- yo';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final userProfileAsync = ref.watch(userProfileProvider);

    return SafeArea(
      child: Scaffold(
        body: userProfileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (user) {
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not load profile data.'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => ref.refresh(userProfileProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final ageString = _calculateAge(user.birthday);

            ImageProvider? avatarProvider;
            if (user.avatar != null && user.avatar!.isNotEmpty) {
              avatarProvider = CachedNetworkImageProvider(user.avatar!);
            } else {
              avatarProvider = const AssetImage(
                'assets/images/heronfit_icon.png',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40 + 2 + 2,
                      backgroundColor: colorScheme.primary,
                      child: CircleAvatar(
                        radius: 40 + 2,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: avatarProvider,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child:
                              avatarProvider == null
                                  ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.first_name ?? ''} ${user.last_name ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? 'User Name'
                                : '${user.first_name ?? ''} ${user.last_name ?? ''}',
                            style: textTheme.titleLarge?.copyWith(
                              color: HeronFitTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 0),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Goal | ',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text: user.goal ?? 'Not Set',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.profileEdit);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: Colors.white,
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(
                      context,
                      '${user.height?.toString() ?? '--'} cm',
                      'Height',
                    ),
                    _buildInfoCard(
                      context,
                      '${user.weight?.toString() ?? '--'} kg',
                      'Weight',
                    ),
                    _buildInfoCard(context, ageString, 'Age'),
                  ],
                ),
                const SizedBox(height: 24.0),
                _buildAccountSection(context),
                const SizedBox(height: 16.0),
                _buildNotificationSection(context, isSingle: true),
                const SizedBox(height: 16.0),
                _buildOtherSection(context),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      ref.invalidate(userProfileProvider);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.go(AppRoutes.onboarding);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                          backgroundColor: HeronFitTheme.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    SolarIconsOutline.logout,
                    size: 24.0,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Logout',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: HeronFitTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: HeronFitTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(((0.7 * 255).round())),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(context, 'Account', [
      _buildSectionItem(context, SolarIconsOutline.user, 'Edit Profile', () {
        context.push(AppRoutes.profileEdit);
      }),
      _buildSectionItem(context, SolarIconsOutline.notebook, 'My Bookings', () {
        context.push(AppRoutes.bookings);
      }),
      _buildSectionItem(
        context,
        SolarIconsOutline.history,
        'Workout History',
        () {
          context.push(AppRoutes.profileHistory);
        },
      ),
    ]);
  }

  Widget _buildNotificationSection(
    BuildContext context, {
    bool isSingle = false,
  }) {
    return _buildSection(context, 'Notification', [
      _buildNotificationToggle(context),
    ], isSingle: isSingle);
  }

  Widget _buildNotificationToggle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // For demo: use a local StateProvider. In production, use a Riverpod provider and persist to Supabase.
    return Consumer(
      builder: (context, ref, _) {
        final notificationEnabled = ref.watch(_notificationToggleProvider);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  SolarIconsOutline.bell,
                  color: HeronFitTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text('Pop-up Notification', style: textTheme.bodyMedium),
              ],
            ),
            Switch(
              value: notificationEnabled,
              activeColor: Colors.white, // Thumb color when active
              activeTrackColor:
                  HeronFitTheme.primary, // Track color when active
              inactiveThumbColor: Colors.white, // Thumb color when inactive
              inactiveTrackColor: HeronFitTheme.primary.withOpacity(
                0.50,
              ), // Lighter primary, no black/grey
              onChanged: (val) {
                ref.read(_notificationToggleProvider.notifier).state = val;
                // TODO: Persist to Supabase/profile if needed
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return _buildSection(context, 'Other', [
      _buildSectionItem(context, SolarIconsOutline.letter, 'Contact Us', () {
        context.push(AppRoutes.profileContact);
      }),
      _buildSectionItem(
        context,
        SolarIconsOutline.shieldUser,
        'Privacy Policy',
        () {
          context.push(AppRoutes.profilePrivacy);
        },
      ),
      _buildSectionItem(
        context,
        SolarIconsOutline.documentText,
        'Terms Of Use',
        () {
          context.push(AppRoutes.profileTerms);
        },
      ),
    ]);
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> items, {
    bool isSingle = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: HeronFitTheme.cardShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isSingle ? 16 : 16, // Less vertical padding for single item
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (items.length == 1)
              items.first
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) => items[index],
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: colorScheme.outline.withAlpha(
                        ((0.3 * 255).round()),
                      ),
                      indent: 40,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      splashColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      focusColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      hoverColor: HeronFitTheme.primary.withAlpha(((0.05 * 255).round())),
      highlightColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: HeronFitTheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Icon(
              SolarIconsOutline.altArrowRight,
              color: colorScheme.onSurface.withAlpha(((0.6 * 255).round())),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// Local provider for demo. Move to controllers/ and persist in production.
final _notificationToggleProvider = StateProvider<bool>((ref) => true);
