// 보안 관련 공통 enum 정의

enum SecurityLevel { low, normal, high, critical }

enum SecurityEventType { 
  login, 
  logout, 
  dataAccess, 
  suspicious,
  biometricAuth,
  passwordChange,
  privacyUpdate
}

enum SecurityThreatLevel { none, low, medium, high, critical }

enum IntegrityStatus { verified, unverified, compromised, checking }
