import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/app_localizations.dart';
import '../../../providers/auth_provider.dart';

class VolunteerLeaderboardScreen extends StatefulWidget {
  const VolunteerLeaderboardScreen({super.key});

  @override
  State<VolunteerLeaderboardScreen> createState() =>
      _VolunteerLeaderboardScreenState();
}

class _VolunteerLeaderboardScreenState
    extends State<VolunteerLeaderboardScreen> {
  int _selectedTab = 0; // 0: Nearby, 1: Global
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.leaderboard,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.black),
            onPressed: () => _showShareDialog(context, l10n),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildTabSelector(l10n),
            const SizedBox(height: 30),
            _buildPodium(l10n),
            const SizedBox(height: 40),
            _buildTopVolunteersList(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    l10n.nearby,
                    style: TextStyle(
                      color: _selectedTab == 0
                          ? Colors.blue
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    l10n.global,
                    style: TextStyle(
                      color: _selectedTab == 1
                          ? Colors.blue
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumItem(
            name: 'Elena R.',
            points: '2,480',
            rank: '2',
            badgeLabel: l10n.silverBadge,
            badgeColor: Colors.blue.shade100,
            textColor: Colors.blue.shade700,
            imageUrl: 'https://i.pravatar.cc/150?img=1',
            radius: 45,
            rankY: 0,
            isCenter: false,
          ),
          // 1st Place
          _buildPodiumItem(
            name: 'James Miller',
            points: '3,120',
            rank: '1',
            badgeLabel: l10n.goldBadge,
            badgeColor: Colors.amber.shade100,
            textColor: Colors.amber.shade800,
            imageUrl: 'https://i.pravatar.cc/150?img=2',
            radius: 55,
            rankY: -10,
            isCenter: true,
          ),
          // 3rd Place
          _buildPodiumItem(
            name: 'Sarah K.',
            points: '2,150',
            rank: '3',
            badgeLabel: l10n.bronzeBadge,
            badgeColor: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
            imageUrl: 'https://i.pravatar.cc/150?img=3',
            radius: 40,
            rankY: 0,
            isCenter: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required String name,
    required String points,
    required String rank,
    required String badgeLabel,
    required Color badgeColor,
    required Color textColor,
    required String imageUrl,
    required double radius,
    required double rankY,
    required bool isCenter,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCenter ? Colors.amber : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            if (isCenter)
              Positioned(
                top: -15,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.black,
          ),
        ),
        Text(
          '$points pts',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeLabel,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopVolunteersList(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.topVolunteers,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.blue.shade900.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildVolunteerListItem(
            rank: '4',
            name: 'Marcus Chen',
            stats: '18 sessions • 1,890 pts',
            change: '+12%',
            changeColor: Colors.blue,
            imageUrl: 'https://i.pravatar.cc/150?img=4',
            hasBadge: true,
          ),
          _buildVolunteerListItem(
            rank: '5',
            name: 'Chloe Davis',
            stats: '15 sessions • 1,650 pts',
            change: l10n.steady,
            changeColor: Colors.grey,
            imageUrl: 'https://i.pravatar.cc/150?img=5',
            hasBadge: true,
            badgeIcon: Icons.verified_user,
          ),
          _buildYourRankCard(l10n),
          _buildVolunteerListItem(
            rank: '6',
            name: 'David Wilson',
            stats: '12 sessions • 1,420 pts',
            change: '-2',
            changeColor: Colors.red.shade300,
            imageUrl: 'https://i.pravatar.cc/150?img=6',
          ),
          _buildVolunteerListItem(
            rank: '7',
            name: 'Sophia Martinez',
            stats: '11 sessions • 1,380 pts',
            change: '+5',
            changeColor: Colors.blue,
            imageUrl: 'https://i.pravatar.cc/150?img=7',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildVolunteerListItem({
    required String rank,
    required String name,
    required String stats,
    required String change,
    required Color changeColor,
    required String imageUrl,
    bool hasBadge = false,
    IconData? badgeIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              rank,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.black,
                      ),
                    ),
                    if (hasBadge) ...[
                      const SizedBox(width: 4),
                      Icon(
                        badgeIcon ?? Icons.military_tech,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  stats,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourRankCard(AppLocalizations l10n) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100, width: 2),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 30,
                child: Text(
                  '12',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  user.profileImageUrl?.isNotEmpty == true
                      ? user.profileImageUrl!
                      : 'https://i.pravatar.cc/150?img=12',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.you} (${user.name})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${user.completedTasks} sessions • ${user.points} pts',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.yourRank,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_up, color: Colors.blue),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    l10n.shareRank,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent,
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.imMakingADifference,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Alex',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Rank #12',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '940 pts',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.volunteer_activism,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'SENIOR CARE CONNECTOR',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.shareYourAchievement,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialIcon(
                    FontAwesomeIcons.instagram,
                    l10n.instagram,
                    onTap: () => _shareOnPlatform(l10n, 'Instagram'),
                  ),
                  _buildSocialIcon(
                    FontAwesomeIcons.whatsapp,
                    l10n.whatsapp,
                    onTap: () => _shareOnPlatform(l10n, 'WhatsApp'),
                  ),
                  _buildSocialIcon(
                    FontAwesomeIcons.facebook,
                    l10n.facebook,
                    onTap: () => _shareOnPlatform(l10n, 'Facebook'),
                  ),
                  _buildSocialIcon(
                    FontAwesomeIcons.xTwitter,
                    l10n.twitter,
                    onTap: () => _shareOnPlatform(l10n, 'Twitter'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadImage(context, l10n),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.downloadImage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareOnPlatform(AppLocalizations l10n, String platform) async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/achievement.png').create();
        await file.writeAsBytes(image);

        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              '${l10n.imMakingADifference} ${l10n.joinUs} - Senior Care Connector',
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Future<void> _downloadImage(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.downloadImage),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
    }
  }

  Widget _buildSocialIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
