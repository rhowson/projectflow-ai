import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/role_edit_dialog.dart';
import '../../../core/models/team_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/project_role_model.dart';
import '../../../core/models/project_model.dart';
import '../providers/team_provider.dart';
import '../providers/project_role_provider.dart';
import '../../user_management/providers/user_provider.dart';
import '../../project_creation/providers/project_provider.dart';

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
                _buildProjectRolesTab(),
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
            _buildTabItem('Roles', Icons.admin_panel_settings, 2),
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
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
                  onTap: () => _showMemberOptions(member),
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
            onTapOutside: (event) {
              // Hide keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
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
            onTapOutside: (event) {
              // Hide keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
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
            onTapOutside: (event) {
              // Hide keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
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

  Widget _buildProjectRolesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Create and AI Generate buttons
          Row(
            children: [
              Text(
                'Project Roles',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: CustomNeumorphicTheme.darkText,
                ),
              ),
              const Spacer(),
              NeumorphicButton(
                onPressed: () => _showCreateRoleDialog(),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                borderRadius: BorderRadius.circular(12.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: CustomNeumorphicTheme.primaryPurple,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              NeumorphicButton(
                onPressed: _generateProjectRoles,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                borderRadius: BorderRadius.circular(12.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: CustomNeumorphicTheme.primaryPurple,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'AI Generate',
                      style: TextStyle(
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'AI can generate project-specific roles based on your active project',
            style: TextStyle(
              fontSize: 13.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
          ),
          SizedBox(height: 20.h),

          // AI Generation Results
          Consumer(
            builder: (context, ref, child) {
              final aiRolesState = ref.watch(aIRoleGenerationNotifierProvider);
              
              return aiRolesState.when(
                data: (suggestions) {
                  if (suggestions == null) {
                    return _buildEmptyRolesState();
                  }
                  return _buildAISuggestions(suggestions);
                },
                loading: () => _buildGeneratingRolesState(),
                error: (error, stack) => _buildErrorState(error),
              );
            },
          ),

          SizedBox(height: 20.h),

          // Existing Project Roles (if any)
          Consumer(
            builder: (context, ref, child) {
              // Get active project first
              final projectsAsync = ref.watch(projectNotifierProvider);
              
              return projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  final activeProject = projects.first; // Use first project as active
                  final rolesAsync = ref.watch(projectRoleNotifierProvider(activeProject.id));
                  
                  return rolesAsync.when(
                    data: (roles) {
                      if (roles.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildExistingRoles(roles, activeProject.id);
                    },
                    loading: () => const SizedBox.shrink(), // Fixed redundant loading indicator
                    error: (error, stack) => Text('Error loading roles: $error'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRolesState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 64.sp,
            color: CustomNeumorphicTheme.lightText,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Project Roles Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Generate AI-powered roles for your active project',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingRolesState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            'AI is analyzing your project...',
            style: TextStyle(
              fontSize: 16.sp,
              color: CustomNeumorphicTheme.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Generating tailored roles based on project requirements',
            style: TextStyle(
              fontSize: 13.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: CustomNeumorphicTheme.errorRed,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to Generate Roles',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CustomNeumorphicTheme.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 13.sp,
              color: CustomNeumorphicTheme.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          NeumorphicButton(
            onPressed: _generateProjectRoles,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            borderRadius: BorderRadius.circular(12.r),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: CustomNeumorphicTheme.primaryPurple,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions(List<AIRoleSuggestion> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'AI Generated Roles',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            const Spacer(),
            NeumorphicButton(
              onPressed: () => _createRolesFromSuggestions(suggestions),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              borderRadius: BorderRadius.circular(8.r),
              child: Text(
                'Create All Roles',
                style: TextStyle(
                  color: CustomNeumorphicTheme.primaryPurple,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...suggestions.map((suggestion) => _buildRoleSuggestionCard(suggestion)),
      ],
    );
  }

  Widget _buildRoleSuggestionCard(AIRoleSuggestion suggestion) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Color(int.parse(suggestion.suggestedColor.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    suggestion.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                Text(
                  'Priority ${suggestion.priority}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: CustomNeumorphicTheme.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              suggestion.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Skills: ${suggestion.requiredSkills.join(", ")}',
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (suggestion.timeCommitment != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Time: ${suggestion.timeCommitment!.toStringAsFixed(0)} hrs/week',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              suggestion.reasoning,
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.lightText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingRoles(List<ProjectRole> roles, String projectId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Project Roles',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        SizedBox(height: 12.h),
        ...roles.map((role) => _buildExistingRoleCard(role, projectId)),
      ],
    );
  }

  Widget _buildExistingRoleCard(ProjectRole role, String projectId) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: NeumorphicCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Color(int.parse(role.color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    role.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                ),
                if (role.isAIGenerated)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CustomNeumorphicTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditRoleDialog(role, projectId),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14.sp,
                          color: CustomNeumorphicTheme.primaryPurple,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => _assignUserToRole(role),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 14.sp,
                          color: CustomNeumorphicTheme.successGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => _showRoleOptions(role, projectId),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: 14.sp,
                          color: CustomNeumorphicTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              role.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: CustomNeumorphicTheme.lightText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Skills: ${role.requiredSkills.join(", ")}',
              style: TextStyle(
                fontSize: 12.sp,
                color: CustomNeumorphicTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateProjectRoles() async {
    try {
      await ref.read(aIRoleGenerationNotifierProvider.notifier).generateRolesForActiveProject();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate roles: $error'),
            backgroundColor: CustomNeumorphicTheme.errorRed,
          ),
        );
      }
    }
  }

  void _createRolesFromSuggestions(List<AIRoleSuggestion> suggestions) async {
    try {
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = await projectsAsync.when(
        data: (data) async => data,
        loading: () => throw Exception('Projects are still loading'),
        error: (error, stack) => throw error,
      );
      
      if (projects.isEmpty) {
        throw Exception('No active project found');
      }
      
      final activeProject = projects.first;
      await ref.read(projectRoleNotifierProvider(activeProject.id).notifier)
          .createRolesFromSuggestions(suggestions);
      
      // Clear the suggestions after creating roles
      ref.read(aIRoleGenerationNotifierProvider.notifier).clearSuggestions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${suggestions.length} roles created successfully!'),
            backgroundColor: CustomNeumorphicTheme.primaryPurple,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create roles: $error'),
            backgroundColor: CustomNeumorphicTheme.errorRed,
          ),
        );
      }
    }
  }

  void _assignUserToRole(ProjectRole role) {
    // TODO: Implement user assignment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User assignment for ${role.name} - Coming soon!')),
    );
  }

  void _showCreateRoleDialog() async {
    try {
      // Get active project first
      final projectsAsync = ref.read(projectNotifierProvider);
      final projects = projectsAsync.when(
        data: (data) => data,
        loading: () => <Project>[],
        error: (error, stack) => <Project>[],
      );
      
      if (projects.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active project found')),
          );
        }
        return;
      }
      
      final activeProject = projects.first;
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => RoleEditDialog(
            projectId: activeProject.id,
            isCreating: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEditRoleDialog(ProjectRole role, String projectId) {
    showDialog(
      context: context,
      builder: (context) => RoleEditDialog(
        role: role,
        projectId: projectId,
        isCreating: false,
      ),
    );
  }

  void _showRoleOptions(ProjectRole role, String projectId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NeumorphicContainer(
        margin: EdgeInsets.all(16.w),
        borderRadius: BorderRadius.circular(20.r),
        color: CustomNeumorphicTheme.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.lightText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Options',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: CustomNeumorphicTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    role.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: CustomNeumorphicTheme.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: CustomNeumorphicTheme.primaryPurple,
                child: Icon(Icons.edit, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Edit Role',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Modify role details and permissions',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditRoleDialog(role, projectId);
              },
            ),
            
            ListTile(
              leading: NeumorphicContainer(
                padding: EdgeInsets.all(8.w),
                borderRadius: BorderRadius.circular(10.r),
                color: CustomNeumorphicTheme.successGreen,
                child: Icon(Icons.person_add, color: Colors.white, size: 20.sp),
              ),
              title: Text(
                'Assign Users',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Assign team members to this role',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomNeumorphicTheme.lightText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _assignUserToRole(role);
              },
            ),
            
            if (!role.isAIGenerated) // Only allow deletion of custom roles
              ListTile(
                leading: NeumorphicContainer(
                  padding: EdgeInsets.all(8.w),
                  borderRadius: BorderRadius.circular(10.r),
                  color: CustomNeumorphicTheme.errorRed,
                  child: Icon(Icons.delete_outline, color: Colors.white, size: 20.sp),
                ),
                title: Text(
                  'Delete Role',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomNeumorphicTheme.errorRed,
                  ),
                ),
                subtitle: Text(
                  'Permanently delete this role',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomNeumorphicTheme.lightText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteRoleConfirmation(role, projectId);
                },
              ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteRoleConfirmation(ProjectRole role, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomNeumorphicTheme.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Role',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: CustomNeumorphicTheme.errorRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${role.name}"?',
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomNeumorphicTheme.darkText,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: CustomNeumorphicTheme.errorRed.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action cannot be undone. This will permanently:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: CustomNeumorphicTheme.errorRed,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '• Remove the role\n• Unassign all users from this role\n• Delete all role-specific permissions',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CustomNeumorphicTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: CustomNeumorphicTheme.darkText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRole(role, projectId);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: CustomNeumorphicTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRole(ProjectRole role, String projectId) async {
    try {
      await ref.read(projectRoleNotifierProvider(projectId).notifier)
          .deleteRole(role.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role "${role.name}" deleted successfully'),
            backgroundColor: CustomNeumorphicTheme.primaryPurple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting role: $e'),
            backgroundColor: CustomNeumorphicTheme.errorRed,
          ),
        );
      }
    }
  }
}