import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import 'group_detail_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupController = TextEditingController();
  final _memberController = TextEditingController();

  final List<String> _members = [];
  bool _saving = false;

  void _addMember() {
    final name = _memberController.text.trim();

    if (name.isEmpty) return;

    if (_members.any(
          (member) => member.toLowerCase() == name.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already added')),
      );
      return;
    }

    setState(() {
      _members.add(name);
      _memberController.clear();
    });
  }

  Future<void> _saveGroup() async {
    final name = _groupController.text.trim();

    if (name.isEmpty || _members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a group name and add a member'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final id = await context.read<GroupProvider>().createGroup(
        name,
        _members,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(groupId: id),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _groupController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Group name',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _groupController,
            maxLength: 60,
            decoration: const InputDecoration(
              hintText: 'e.g. CS Friends',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.groups_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add friends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Friend name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addMember(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addMember,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._members.asMap().entries.map((entry) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(entry.value[0].toUpperCase()),
                ),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _members.removeAt(entry.key);
                    });
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _saveGroup,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }
}