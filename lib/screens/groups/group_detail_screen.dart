import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/group_model.dart';
import '../../models/member_model.dart';
import '../../providers/group_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() =>
      _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  GroupModel? group;
  List<MemberModel> members = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<GroupProvider>();

    final loadedGroup = await provider.getGroup(widget.groupId);
    final loadedMembers = await provider.getMembers(widget.groupId);

    if (!mounted) return;

    setState(() {
      group = loadedGroup;
      members = loadedMembers;
      loading = false;
    });
  }

  Future<String?> _askName(
      String title, {
        String initial = '',
      }) async {
    final controller = TextEditingController(text: initial);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                controller.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _addMember() async {
    final name = await _askName('Add Friend');

    if (name == null || name.isEmpty) return;

    if (members.any(
          (m) => m.name.toLowerCase() == name.toLowerCase(),
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already exists')),
      );
      return;
    }

    await context.read<GroupProvider>().addMember(
      widget.groupId,
      name,
    );

    await _load();
  }

  Future<void> _renameGroup() async {
    final name = await _askName(
      'Rename Group',
      initial: group?.name ?? '',
    );

    if (name == null || name.isEmpty) return;

    await context.read<GroupProvider>().renameGroup(
      widget.groupId,
      name,
    );

    await _load();
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
          'This will permanently remove the group and its members.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<GroupProvider>().deleteGroup(widget.groupId);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _removeMember(MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Friend?'),
        content: Text('Remove ${member.name} from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<GroupProvider>().deleteMember(member.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Group Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') _renameGroup();
              if (value == 'delete') _deleteGroup();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'rename',
                child: Text('Rename Group'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Group'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : group == null
          ? const Center(child: Text('Group not found'))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.groups, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    group!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${members.length} members'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Members (${members.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...members.map((member) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    member.name[0].toUpperCase(),
                  ),
                ),
                title: Text(member.name),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                  onPressed: () => _removeMember(member),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addMember,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Friend'),
          ),
        ],
      ),
    );
  }
}