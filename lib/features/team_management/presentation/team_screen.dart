import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/models/team_model.dart';
import '../../../core/models/user_model.dart';
import '../providers/team_provider.dart';
import '../../user_management/providers/user_provider.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Team Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          NeumorphicButton(
            onPressed: () => context.push('/profile'),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.person,
              color: CustomNeumorphicTheme.primaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          NeumorphicButton(
            onPressed: () => _showTeamActions(context),
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.add,
              color: CustomNeumorphicTheme.primaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamMembersTab(),
                _buildCommunicationTab(),
                _buildProjectTeamsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: NeumorphicFlatContainer(
        padding: EdgeInsets.all(4.w),
        borderRadius: BorderRadius.circular(16.r),
        color: CustomNeumorphicTheme.baseColor,
        child: Row(
          children: [
            _buildTabItem('Members', Icons.group, 0),
            _buildTabItem('Chat', Icons.chat_bubble_outline, 1),
            _buildTabItem('Projects', Icons.work_outline, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, IconData icon, int index) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? CustomNeumorphicTheme.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : CustomNeumorphicTheme.lightText,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : CustomNeumorphicTheme.lightText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembersTab() {
    final currentUser = ref.watch(currentUserProvider);
    
    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please sign in to view teams'));
        }
        
        final userTeams = ref.watch(userTeamsProvider(user.id));
        
        return userTeams.when(
          data: (teams) {
            if (teams.isEmpty) {
              return _buildEmptyTeamState();
            }
            
            // Get all unique team members from all user's teams
            final allMembers = <String, TeamMember>{};
            for (final team in teams) {
              for (final member in team.members) {
                if (!allMembers.containsKey(member.userId)) {
                  allMembers[member.userId] = member;
                }
              }
            }
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Team Members',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${allMembers.length} members',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  ...allMembers.values.map((member) => _buildMemberCardFromData(member)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading teams: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 64.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Teams Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create a team or join one to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
          SizedBox(height: 24.h),
          NeumorphicButton(
            onPressed: _createTeam,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            borderRadius: BorderRadius.circular(12),
            child: Text(
              'Create Team',
              style: TextStyle(
                color: CustomNeumorphicTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCardFromData(TeamMember member) {
    final userAsync = ref.watch(userByIdProvider(member.userId));
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: NeumorphicCard(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    NeumorphicContainer(
                      width: 50.w,
                      height: 50.w,
                      borderRadius: BorderRadius.circular(25),
                      color: CustomNeumorphicTheme.primaryPurple,
                      child: Center(
                        child: Text(
                          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: member.status == TeamMemberStatus.active 
                              ? AppColors.statusCompleted 
                              : CustomNeumorphicTheme.lightText,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                
                // Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        member.customTitle ?? member.role.displayName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: CustomNeumorphicTheme.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _startChatWithUser(user),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: CustomNeumorphicTheme.primaryPurple,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _showMemberOptionsForUser(user, member),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: CustomNeumorphicTheme.lightText,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: NeumorphicCard(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              NeumorphicContainer(
                width: 50.w,
                height: 50.w,
                borderRadius: BorderRadius.circular(25),
                color: CustomNeumorphicTheme.lightText,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 12.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildMemberCard(Map<String, String> member) {
    Color statusColor;
    switch (member['status']) {
      case 'online':
        statusColor = AppColors.statusCompleted;
        break;
      case 'busy':
        statusColor = AppColors.statusInProgress;
        break;
      case 'away':
        statusColor = AppColors.statusTodo;
        break;
      default:
        statusColor = CustomNeumorphicTheme.lightText;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Avatar with status indicator
            Stack(
              children: [
                NeumorphicContainer(
                  width: 50.w,
                  height: 50.w,
                  borderRadius: BorderRadius.circular(25),
                  color: CustomNeumorphicTheme.primaryPurple,
                  child: Center(
                    child: Text(
                      member['avatar']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            
            // Member info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    member['role']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CustomNeumorphicTheme.primaryPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    member['email']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _startChat(member['name']!),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: CustomNeumorphicTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: CustomNeumorphicTheme.primaryPurple,
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showMemberOptions(member),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: CustomNeumorphicTheme.lightText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: CustomNeumorphicTheme.lightText,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationTab() {
    // Mock chat/communication data
    final conversations = [
      {'name': 'Project Alpha Team', 'lastMessage': 'Meeting at 3 PM today', 'time': '2 min ago', 'unread': 3, 'type': 'group'},
      {'name': 'Alice Johnson', 'lastMessage': 'Can you review the latest designs?', 'time': '15 min ago', 'unread': 1, 'type': 'direct'},
      {'name': 'Design Team', 'lastMessage': 'New mockups uploaded', 'time': '1 hour ago', 'unread': 0, 'type': 'group'},
      {'name': 'Bob Smith', 'lastMessage': 'Code review completed', 'time': '2 hours ago', 'unread': 0, 'type': 'direct'},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Conversations',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              const Spacer(),
              NeumorphicButton(
                onPressed: () => _startNewConversation(),
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(12),
                child: Icon(
                  Icons.add_comment,
                  color: CustomNeumorphicTheme.primaryPurple,
                  size: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          ...conversations.map((chat) => _buildChatCard(chat)),
        ],
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        onTap: () => _openChat(chat['name']),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Chat avatar
            NeumorphicContainer(
              width: 45.w,
              height: 45.w,
              borderRadius: BorderRadius.circular(22.5),
              color: chat['type'] == 'group' 
                  ? CustomNeumorphicTheme.secondaryPurple 
                  : CustomNeumorphicTheme.primaryPurple,
              child: Icon(
                chat['type'] == 'group' ? Icons.group : Icons.person,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomNeumorphicTheme.darkText,
                          ),
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    chat['lastMessage'],
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (chat['unread'] > 0)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat['unread']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTeamsTab() {
    final currentUser = ref.watch(currentUserProvider);
    
    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please sign in to view teams'));
        }
        
        final userTeams = ref.watch(userTeamsProvider(user.id));
        
        return userTeams.when(
          data: (teams) {
            if (teams.isEmpty) {
              return _buildEmptyTeamState();
            }
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Your Teams',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: CustomNeumorphicTheme.darkText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${teams.length} teams',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  ...teams.map((team) => _buildTeamCard(team)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading teams: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    Color statusColor;
    switch (team.status) {
      case TeamStatus.active:
        statusColor = AppColors.statusInProgress;
        break;
      case TeamStatus.archived:
        statusColor = AppColors.statusTodo;
        break;
      default:
        statusColor = CustomNeumorphicTheme.lightText;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        onTap: () => _viewTeamDetails(team),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    team.status.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              team.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 16.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${team.activeMemberCount} members',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                const Spacer(),
                Text(
                  'Created ${_formatDate(team.createdAt)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTeamCard(Map<String, dynamic> project) {
    Color statusColor;
    switch (project['status']) {
      case 'Active':
        statusColor = AppColors.statusInProgress;
        break;
      case 'Planning':
        statusColor = AppColors.statusTodo;
        break;
      case 'Completed':
        statusColor = AppColors.statusCompleted;
        break;
      default:
        statusColor = CustomNeumorphicTheme.lightText;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        onTap: () => _viewProjectTeam(project['name']),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project['name'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project['status'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 16.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${project['members']} members',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(project['progress'] * 100).round()}% complete',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            NeumorphicProgressBar(
              progress: project['progress'],
              height: 4.h,
              progressColor: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Team Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_add, color: CustomNeumorphicTheme.primaryPurple),
              title: const Text('Invite Team Member'),
              onTap: () {
                Navigator.pop(context);
                _inviteTeamMember();
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add, color: CustomNeumorphicTheme.primaryPurple),
              title: const Text('Create Team'),
              onTap: () {
                Navigator.pop(context);
                _createTeam();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: CustomNeumorphicTheme.lightText),
              title: const Text('Team Settings'),
              onTap: () {
                Navigator.pop(context);
                _openTeamSettings();
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _startChat(String memberName) {
    // TODO: Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting chat with $memberName')),
    );
  }

  void _startChatWithUser(AppUser user) {
    // TODO: Implement chat functionality with user object
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting chat with ${user.firstName} ${user.lastName}')),
    );
  }

  void _showMemberOptions(Map<String, String> member) {
    // TODO: Implement member options (edit, remove, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Options for ${member['name']}')),
    );
  }

  void _showMemberOptionsForUser(AppUser user, TeamMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CustomNeumorphicTheme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              child: Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat, color: CustomNeumorphicTheme.primaryPurple),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                _startChatWithUser(user);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: CustomNeumorphicTheme.primaryPurple),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/${user.id}');
              },
            ),
            if (member.role != TeamRole.owner)
              ListTile(
                leading: Icon(Icons.admin_panel_settings, color: CustomNeumorphicTheme.lightText),
                title: const Text('Change Role'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangeRoleDialog(user, member);
                },
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _startNewConversation() {
    // TODO: Implement new conversation creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting new conversation')),
    );
  }

  void _openChat(String chatName) {
    // TODO: Implement chat opening
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat: $chatName')),
    );
  }

  void _viewProjectTeam(String projectName) {
    // TODO: Implement project team view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing team for: $projectName')),
    );
  }

  void _inviteTeamMember() {
    showDialog(
      context: context,
      builder: (context) => _buildInviteDialog(),
    );
  }

  void _createTeam() {
    showDialog(
      context: context,
      builder: (context) => _buildCreateTeamDialog(),
    );
  }

  void _openTeamSettings() {
    // TODO: Implement team settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team settings functionality')),
    );
  }

  void _viewTeamDetails(Team team) {
    // TODO: Navigate to team details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${team.name}')),
    );
  }

  void _showChangeRoleDialog(AppUser user, TeamMember member) {
    // TODO: Implement role change dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change role for ${user.firstName} ${user.lastName}')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  Widget _buildInviteDialog() {
    final emailController = TextEditingController();
    
    return AlertDialog(
      backgroundColor: CustomNeumorphicTheme.cardColor,
      title: Text(
        'Invite Team Member',
        style: TextStyle(
          color: CustomNeumorphicTheme.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter team member email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<TeamRole>(
            decoration: InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: TeamRole.values
                .where((role) => role != TeamRole.owner)
                .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              // TODO: Handle role selection
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement invitation logic
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation sent!')),
            );
          },
          child: const Text('Send Invite'),
        ),
      ],
    );
  }

  Widget _buildCreateTeamDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    return AlertDialog(
      backgroundColor: CustomNeumorphicTheme.cardColor,
      title: Text(
        'Create New Team',
        style: TextStyle(
          color: CustomNeumorphicTheme.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Team Name',
              hintText: 'Enter team name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your team...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
              final currentUser = ref.read(currentUserProvider).value;
              if (currentUser != null) {
                try {
                  await ref.read(teamManagementProvider.notifier).createTeam(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    ownerId: currentUser.id,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team created successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating team: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Create Team'),
        ),
      ],
    );
  }
}