import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

class GroupProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<GroupModel> groups = [];
  bool isLoading = false;

  Future<void> loadGroups() async {
    isLoading = true;
    notifyListeners();

    try {
      groups = await _db.getGroups();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createGroup(
      String name,
      List<String> members,
      ) async {
    final id = await _db.createGroup(name, members);
    await loadGroups();
    return id;
  }

  Future<List<MemberModel>> getMembers(int groupId) {
    return _db.getMembers(groupId);
  }

  Future<GroupModel?> getGroup(int groupId) {
    return _db.getGroup(groupId);
  }

  Future<void> addMember(int groupId, String name) async {
    await _db.addMember(groupId, name);
    notifyListeners();
  }

  Future<void> deleteMember(int memberId) async {
    await _db.deleteMember(memberId);
    notifyListeners();
  }

  Future<void> renameGroup(int groupId, String name) async {
    await _db.renameGroup(groupId, name);
    await loadGroups();
  }

  Future<void> deleteGroup(int groupId) async {
    await _db.deleteGroup(groupId);
    await loadGroups();
  }
}