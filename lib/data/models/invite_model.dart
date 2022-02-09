import 'dart:math';

// Define a reusable function
String generateRandomString(int length) {
  final _random = Random();
  const _availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
          (index) => _availableChars[_random.nextInt(_availableChars.length)])
      .join();

  return randomString;
}

class InviteModel {
  String id;
  String userEmail;
  bool isAdmin;
  String? verificationCode;
  String? brandId;
  DateTime? createdAt;

  void generateCode({List<String> comparisonCodes = const []}) {
    String randString = generateRandomString(6);
    while (comparisonCodes.contains(randString)) {
      // generate a new code
      randString = generateRandomString(6);
    }
    verificationCode = randString;
  }

  InviteModel(
      {required this.id,
      required this.userEmail,
      required this.isAdmin,
      required this.brandId,
      this.verificationCode,
      this.createdAt});
}

class MemberInviteModel extends InviteModel {
  String? memberTier;
  String? customerId;

  MemberInviteModel(
      {required id,
      required userEmail,
      required isAdmin,
      required brandId,
      verificationCode,
      createdAt,
      required this.memberTier,
      this.customerId})
      : super(
            id: id,
            userEmail: userEmail,
            isAdmin: isAdmin,
            brandId: brandId,
            verificationCode: verificationCode,
            createdAt: createdAt);

  static MemberInviteModel fromJson(Map<String, dynamic> json) {
    return MemberInviteModel(
        id: json['id'],
        userEmail: json['userEmail'],
        isAdmin: json['isAdmin'],
        brandId: json['forBrand']['id'],
        verificationCode: json['verificationCode'],
        createdAt: json.containsKey('createdAt')
            ? DateTime.tryParse(json["createdAt"]) ?? DateTime(2020)
            : DateTime(2020),
        memberTier: json['memberTier']);
  }
}

class EmployeeInviteModel extends InviteModel {
  final String? jobTitle;
  final List<String>? roles;
  final bool? founder;
  final bool? owner;

  EmployeeInviteModel(
      {required id,
      required userEmail,
      required isAdmin,
      required brandId,
      verificationCode,
      createdAt,
      required this.jobTitle,
      required this.roles,
      required this.founder,
      required this.owner})
      : super(
            id: id,
            userEmail: userEmail,
            isAdmin: isAdmin,
            brandId: brandId,
            verificationCode: verificationCode,
            createdAt: createdAt);

  static EmployeeInviteModel fromJson(Map<String, dynamic> json) {
    return EmployeeInviteModel(
        id: json['id'],
        userEmail: json['userEmail'],
        isAdmin: json['isAdmin'],
        brandId: json['forBrand']['id'],
        jobTitle: json['jobTitle'],
        verificationCode: json['verificationCode'],
        roles: json['roles'],
        founder: json['founder'],
        createdAt: json.containsKey('createdAt')
            ? DateTime.tryParse(json["createdAt"]) ?? DateTime(2020)
            : DateTime(2020),
        owner: json['owner']);
  }
}
