import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/society_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _societies => _db.collection('societies');

  // ════════════════════════════════════════════════════════════
  // DUPLICATE CHECKS
  // ════════════════════════════════════════════════════════════

  /// Check if a mobile number already exists in the system
  Future<bool> isMobileDuplicated(String mobile) async {
    try {
      final query = await _users.where('mobile', isEqualTo: mobile).limit(1).get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw 'Database error: Unable to verify mobile number.';
    }
  }

  /// Check if an email already exists in the system
  Future<bool> isEmailDuplicated(String email) async {
    try {
      final query = await _users.where('email', isEqualTo: email).limit(1).get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw 'Database error: Unable to verify email.';
    }
  }

  /// Check if a flat number already exists within a specific society and block
  Future<bool> isFlatDuplicated(String societyId, String flatNo, String? block) async {
    try {
      var query = _users
          .where('society_id', isEqualTo: societyId)
          .where('flat_no', isEqualTo: flatNo);
          
      if (block != null && block.isNotEmpty) {
        query = query.where('block', isEqualTo: block);
      }
      
      final result = await query.limit(1).get();
      return result.docs.isNotEmpty;
    } catch (e) {
      throw 'Database error: Unable to verify flat details.';
    }
  }

  // ════════════════════════════════════════════════════════════
  // USER CRUD
  // ════════════════════════════════════════════════════════════

  /// Add a new user to the Firestore database
  Future<void> addUser(UserModel user) async {
    try {
      // 1. Mobile uniqueness (Rule: One mobile = one user)
      if (user.mobile.isNotEmpty && await isMobileDuplicated(user.mobile)) {
        throw 'Mobile number already registered. One mobile = one user.';
      }

      // 2. Email uniqueness (if provided)
      if (user.email.isNotEmpty && await isEmailDuplicated(user.email)) {
        throw 'Email already registered.';
      }

      // 3. Flat uniqueness for residents (Rule: 1 Flat = 1 Resident)
      if (user.role == 'resident' && user.flatNo != null && user.flatNo!.isNotEmpty) {
        if (await isFlatDuplicated(user.societyId, user.flatNo!, user.block)) {
          String blockStr = (user.block != null && user.block!.isNotEmpty) 
              ? ' (Block ${user.block})' 
              : '';
          throw 'Flat ${user.flatNo}$blockStr is already assigned. 1 Flat = 1 Resident.';
        }
      }

      // 4. Add user document
      if (user.id != null && user.id!.isNotEmpty) {
        await _users.doc(user.id).set({
          ...user.toMap(),
          'uid': user.id,
        });
      } else {
        await _users.add(user.toMap());
      }
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to add user: Network or server error.';
    }
  }

  /// Get all users for a specific society
  Future<List<UserModel>> getUsersBySociety(String societyId) async {
    try {
      final query = await _users
          .where('society_id', isEqualTo: societyId)
          .get();
          
      var list = query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
          
      // Sort locally to prevent Firestore composite index error
      list.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      return list;
    } catch (e) {
      throw 'Failed to load users: $e';
    }
  }

  /// Get all users for a society filtered by role
  Future<List<UserModel>> getUsersBySocietyAndRole(String societyId, String role) async {
    try {
      final query = await _users
          .where('society_id', isEqualTo: societyId)
          .where('role', isEqualTo: role)
          .get();
      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to load users: $e';
    }
  }

  /// Get all users across all societies (Super Admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final query = await _users.orderBy('created_at', descending: true).get();
      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to load all users: $e';
    }
  }

  /// Get all users filtered by role (Super Admin)
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final query = await _users.where('role', isEqualTo: role).get();
      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to load users by role: $e';
    }
  }

  /// Delete a user by document ID
  Future<void> deleteUser(String userId) async {
    try {
      await _users.doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  /// Toggle user active/inactive status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _users.doc(userId).update({'is_active': isActive});
    } catch (e) {
      throw 'Failed to update user status: $e';
    }
  }

  /// Update a user's details
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _users.doc(userId).update(data);
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  /// Get user data by mobile number
  Future<UserModel?> getUserByMobile(String mobile) async {
    try {
      final query = await _users.where('mobile', isEqualTo: mobile).limit(1).get();
      if (query.docs.isEmpty) return null;
      
      return UserModel.fromMap(
        query.docs.first.data() as Map<String, dynamic>,
        query.docs.first.id,
      );
    } catch (e) {
      throw 'Failed to fetch user by mobile. Check your internet connection.';
    }
  }

  /// Get user data by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _users.where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isEmpty) return null;

      return UserModel.fromMap(
        query.docs.first.data() as Map<String, dynamic>,
        query.docs.first.id,
      );
    } catch (e) {
      throw 'Failed to fetch user by email. Check your internet connection.';
    }
  }

  /// Count users by role in a society
  Future<int> countUsersByRole(String societyId, String role) async {
    try {
      final query = await _users
          .where('society_id', isEqualTo: societyId)
          .where('role', isEqualTo: role)
          .count()
          .get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ════════════════════════════════════════════════════════════
  // SOCIETY CRUD
  // ════════════════════════════════════════════════════════════

  /// Create a new society
  Future<String> createSociety(String name, String address, {String? totalFlats}) async {
    try {
      DocumentReference ref = await _societies.add({
        'name': name,
        'address': address,
        'total_flats': totalFlats,
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw 'Failed to create society: Check your connection.';
    }
  }

  /// Get all societies
  Future<List<SocietyModel>> getAllSocieties() async {
    try {
      final query = await _societies.orderBy('created_at', descending: true).get();
      return query.docs
          .map((doc) => SocietyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to load societies: $e';
    }
  }

  /// Get a single society by ID
  Future<SocietyModel?> getSocietyById(String societyId) async {
    try {
      final doc = await _societies.doc(societyId).get();
      if (!doc.exists) return null;
      return SocietyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to load society: $e';
    }
  }

  /// Delete a society
  Future<void> deleteSociety(String societyId) async {
    try {
      await _societies.doc(societyId).delete();
    } catch (e) {
      throw 'Failed to delete society: $e';
    }
  }

  /// Update society status
  Future<void> updateSocietyStatus(String societyId, String status) async {
    try {
      await _societies.doc(societyId).update({'status': status});
    } catch (e) {
      throw 'Failed to update society status: $e';
    }
  }

  /// Stream societies for real-time updates
  Stream<List<SocietyModel>> streamSocieties() {
    return _societies.orderBy('created_at', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => SocietyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  /// Stream users for a specific society
  Stream<List<UserModel>> streamUsersBySociety(String societyId) {
    return _users
        .where('society_id', isEqualTo: societyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
