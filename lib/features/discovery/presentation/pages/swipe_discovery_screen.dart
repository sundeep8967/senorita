import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/profile.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/match_dialog.dart';
import '../widgets/paid_swipe_dialog.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../domain/usecases/paid_swipe_right.dart';

class SwipeDiscoveryScreen extends StatefulWidget {
  const SwipeDiscoveryScreen({super.key});

  @override
  State<SwipeDiscoveryScreen> createState() => _SwipeDiscoveryScreenState();
}

class _SwipeDiscoveryScreenState extends State<SwipeDiscoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late Animation<Offset> _cardAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<DiscoveryBloc>().add(LoadDiscoveryProfilesEvent());
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _cardAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _cardController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _handleSwipe(SwipeAction action, String profileId) {
    context.read<DiscoveryBloc>().add(
      SwipeProfileEvent(profileId: profileId, action: action),
    );
  }

  void _handlePaidSwipe(String profileId, Profile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaidSwipeDialog(
        profile: profile,
        onConfirmPaidSwipe: (packageType, hotelId, dateTime) {
          Navigator.of(context).pop();
          _processPaidSwipe(profileId, packageType, hotelId, dateTime);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _processPaidSwipe(
    String profileId,
    PackageType packageType,
    String hotelId,
    DateTime dateTime,
  ) {
    // TODO: Integrate with PaidSwipeRight use case
    // For now, show success message
    context.showSuccessSnackBar(
      'Payment successful! Waiting for her response...',
    );
    
    // Navigate to payment screen or show confirmation
    // This would typically trigger the PaidSwipeRight use case
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Discover',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to filters
            },
            icon: Icon(
              Icons.tune,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: BlocConsumer<DiscoveryBloc, DiscoveryState>(
        listener: (context, state) {
          if (state is MatchFound) {
            _showMatchDialog(state.matchedProfile);
          } else if (state is DiscoveryError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is DiscoveryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DiscoveryLoaded) {
            return _buildDiscoveryContent(state);
          } else if (state is DiscoveryError) {
            return _buildErrorContent(state.message);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDiscoveryContent(DiscoveryLoaded state) {
    if (state.profiles.isEmpty) {
      return _buildEmptyContent();
    }

    if (state.currentIndex >= state.profiles.length) {
      if (state.hasMoreProfiles) {
        context.read<DiscoveryBloc>().add(LoadMoreProfilesEvent());
        return const Center(child: CircularProgressIndicator());
      } else {
        return _buildNoMoreProfilesContent();
      }
    }

    final currentProfile = state.profiles[state.currentIndex];
    final nextProfile = state.currentIndex + 1 < state.profiles.length
        ? state.profiles[state.currentIndex + 1]
        : null;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Next card (background)
              if (nextProfile != null)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: ProfileCard(
                      profile: nextProfile,
                      isBackground: true,
                    ),
                  ),
                ),
              
              // Current card (foreground)
              Positioned.fill(
                child: SlideTransition(
                  position: _cardAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: ProfileCard(
                      profile: currentProfile,
                      onSwipe: (action) => _handleSwipe(action, currentProfile.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Action buttons
        Padding(
          padding: EdgeInsets.all(24.w),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ActionButtons(
              onPass: () => _handleSwipe(SwipeAction.pass, currentProfile.id),
              onLike: () => _handleSwipe(SwipeAction.like, currentProfile.id),
              onSuperLike: () => _handleSwipe(SwipeAction.superLike, currentProfile.id),
              onPaidSwipe: () => _handlePaidSwipe(currentProfile.id, currentProfile),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No profiles found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your preferences',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProfilesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for new profiles',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<DiscoveryBloc>().add(LoadDiscoveryProfilesEvent());
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<DiscoveryBloc>().add(LoadDiscoveryProfilesEvent());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showMatchDialog(Profile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        profile: profile,
        onSendMessage: () {
          Navigator.of(context).pop();
          // Navigate to chat screen
        },
        onKeepSwiping: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}