
import 'package:flutter/material.dart';

import 'chats_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';



import 'dart:async';
import '../services/location_service.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/nearby_user.dart';
import '../services/api_service.dart';
import '../widgets/proximity_map.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  // Current discovery radius in meters.
  double radius = 500;

  // Users returned by the Spring Boot backend.
  List<NearbyUser> users = [];

  bool isLoadingUsers = true;
  String? nearbyError;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();

    _initializeLocation();
  }
  Future<void> _initializeLocation() async {
    try {
      await LocationService.updateCurrentLocation();
    } catch (e) {
      debugPrint('Location update failed: $e');
    }

    // Load nearby users after attempting to update
    // the current user's location.
    await loadNearbyUsers();

    // Refresh location every 2 minutes while Nearby
    // screen is open.
    _locationTimer = Timer.periodic(
      const Duration(minutes: 2),
          (_) async {
        try {
          await LocationService.updateCurrentLocation();
          await loadNearbyUsers();
        } catch (e) {
          debugPrint('Periodic location update failed: $e');
        }
      },
    );
  }
  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // LOAD NEARBY USERS
  // ============================================================

  Future<void> loadNearbyUsers() async {
    setState(() {
      isLoadingUsers = true;
      nearbyError = null;
    });

    try {
      final result = await ApiService.getNearbyUsers(radius);

      if (!mounted) return;

      setState(() {
        users = result;
        isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        nearbyError = e
            .toString()
            .replaceFirst('Exception: ', '');
        isLoadingUsers = false;
      });
    }
  }

  // ============================================================
  // OPEN USER PROFILE
  // ============================================================

  void openUser(NearbyUser user) {
    final hasProfilePicture =
        user.profilePicture != null &&
            user.profilePicture!.isNotEmpty;

    // Fetch the interaction status as soon as the profile opens.
    final interactionStatusFuture =
    ApiService.getInteractionStatus(user.userId);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // Drag indicator
                // ------------------------------------------------

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------------------------
                // Profile picture
                // ------------------------------------------------

                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.primarySoft,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasProfilePicture
                        ? Image.network(
                      user.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: AppColors.primarySoft,
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: AppColors.primarySoft,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 42,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------
                // Name
                // ------------------------------------------------

                Text(
                  user.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                // ------------------------------------------------
                // Distance
                // ------------------------------------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDistance(
                        user.distanceMeters,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // Nearby information
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'This person is currently discoverable near you.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // Discoverability indicator
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 19,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Currently discoverable nearby',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // Interaction status / action
                // ------------------------------------------------

                FutureBuilder<Map<String, dynamic>>(
                  future: interactionStatusFuture,
                  builder: (
                      context,
                      snapshot,
                      ) {
                    // ------------------------------------------
                    // Loading status
                    // ------------------------------------------

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }

                    // ------------------------------------------
                    // Error loading status
                    // ------------------------------------------

                    if (snapshot.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 20,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Unable to check connection status.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                  AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                openUser(user);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // ------------------------------------------
                    // Read backend status
                    // ------------------------------------------

                    final data = snapshot.data ?? {};

                    final String? status =
                    data['status']?.toString();

                    final int? interactionId =
                    data['interactionId'];

                    // ------------------------------------------
                    // ACCEPTED
                    // ------------------------------------------

                    if (status == 'ACCEPTED') {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                size: 19,
                              ),
                              label: const Text(
                                'Connected',
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: interactionId == null
                                  ? null
                                  : () async {
                                try {
                                  final conversation =
                                  await ApiService
                                      .createConversationFromInteraction(
                                    interactionId,
                                  );

                                  if (!sheetContext.mounted) {
                                    return;
                                  }

                                  Navigator.pop(sheetContext);

                                  if (!mounted) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        conversationId:
                                        conversation.id,
                                        otherUserId:
                                        user.userId,
                                        otherUserName:
                                        user.displayName,
                                        otherUserPicture:
                                        user.profilePicture,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!sheetContext.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      behavior:
                                      SnackBarBehavior.floating,
                                      backgroundColor:
                                      AppColors.danger,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      content: Text(
                                        e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 19,
                              ),
                              label: const Text(
                                'Message',
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // ------------------------------------------
                    // PENDING
                    // ------------------------------------------

                    if (status == 'PENDING') {
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(
                            Icons.schedule_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Request Pending',
                          ),
                        ),
                      );
                    }

                    // ------------------------------------------
                    // NONE / DECLINED
                    //
                    // Both allow the user to send a new request.
                    // ------------------------------------------

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ApiService.sendInteraction(
                              user.userId,
                            );

                            if (!sheetContext.mounted) {
                              return;
                            }

                            Navigator.pop(sheetContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                behavior:
                                SnackBarBehavior.floating,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                content: Text(
                                  'Connection request sent to ${user.displayName}',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!sheetContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                behavior:
                                SnackBarBehavior.floating,
                                backgroundColor:
                                AppColors.danger,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                content: Text(
                                  e.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.waving_hand_rounded,
                          size: 19,
                        ),
                        label: const Text(
                          'Say Hi',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ------------------------------------------------
                // Close
                // ------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text(
                      'Not now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ============================================================
  // RADIUS SHEET
  // ============================================================

  void openRadiusSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        double tempRadius = radius;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  4,
                  24,
                  30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discovery radius',
                      style: AppTextStyles.heading,
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Choose how far Centroid should look for people.',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 26),

                    Row(
                      children: [
                        const Text(
                          'Within',
                          style: AppTextStyles.body,
                        ),
                        const Spacer(),
                        Text(
                          _formatRadius(tempRadius),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      min: 50,
                      max: 5000,
                      divisions: 99,
                      value: tempRadius,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setSheetState(() {
                          tempRadius = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            radius = tempRadius;
                          });

                          Navigator.pop(sheetContext);

                          loadNearbyUsers();
                        },
                        child: const Text(
                          'Apply radius',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DISTANCE FORMATTING
  // ============================================================

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()} m away';
    }

    final kilometers = distance / 1000;

    return '${kilometers.toStringAsFixed(1)} km away';
  }

  String _formatRadius(double value) {
    if (value < 1000) {
      return '${value.round()} m';
    }

    final kilometers = value / 1000;

    return '${kilometers.toStringAsFixed(1)} km';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Centroid',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration:
                              const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Nearby now',
                              style:
                              AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Profile shortcut
                  Material(
                    color: AppColors.primarySoft,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Expanded(
              child: Builder(
                builder: (context) {
                  // --------------------------------------------
                  // Loading
                  // --------------------------------------------

                  if (isLoadingUsers) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Finding people nearby...',
                            style:
                            AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    );
                  }

                  // --------------------------------------------
                  // Error
                  // --------------------------------------------

                  if (nearbyError != null) {
                    return Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration:
                              const BoxDecoration(
                                color:
                                AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                size: 28,
                                color:
                                AppColors.primary,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Couldn’t load nearby people',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.w700,
                                color:
                                AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              nearbyError!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles
                                  .bodySecondary,
                            ),

                            const SizedBox(height: 18),

                            OutlinedButton(
                              onPressed:
                              loadNearbyUsers,
                              child: const Text(
                                'Try again',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // --------------------------------------------
                  // Empty
                  // --------------------------------------------

                  if (users.isEmpty) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter:
                            const _EmptyRingsPainter(),
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration:
                              const BoxDecoration(
                                color:
                                AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.radar_rounded,
                                size: 32,
                                color:
                                AppColors.primary,
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'No one nearby yet',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight.w700,
                                color:
                                AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'Try increasing your discovery radius.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles
                                  .bodySecondary,
                            ),

                            const SizedBox(height: 18),

                            OutlinedButton(
                              onPressed:
                              openRadiusSheet,
                              child: const Text(
                                'Increase radius',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  // --------------------------------------------
                  // Users available
                  // --------------------------------------------

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: ProximityMap(
                      users: users,
                      maxDistance: radius,
                      onUserTap: openUser,
                    ),
                  );
                },
              ),
            ),

            // ==================================================
            // DISCOVERY CONTROL
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                12,
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: openRadiusSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            size: 19,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discovery radius',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'People you can discover nearby',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatRadius(radius),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 21,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // BOTTOM NAVIGATION
            // ==================================================

            Container(
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const _NavItem(
                      icon: Icons.radar_rounded,
                      label: 'Nearby',
                      selected: true,
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatsScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const _NavItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chats',
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION ITEM
// ============================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 38,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primarySoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color: selected
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selected
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE RINGS
// ============================================================

class _EmptyRingsPainter extends CustomPainter {
  const _EmptyRingsPainter();

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final maxRadius = size.shortestSide * 0.40;

    final radii = [
      maxRadius * 0.40,
      maxRadius * 0.65,
      maxRadius * 0.88,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border.withValues(
        alpha: 0.55,
      );

    for (final ringRadius in radii) {
      canvas.drawCircle(
        center,
        ringRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _EmptyRingsPainter oldDelegate,
      ) {
    return false;
  }
}