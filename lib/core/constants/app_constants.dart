class AppConstants {
  // Shared Preferences Keys
  static const String keyToken = 'token';
  static const String keyRefreshToken = 'refreshToken';
  static const String keyUser = 'user';
  static const String keyRememberMe = 'rememberMe';
  static const String keyLastSyncTime = 'lastSyncTime';
  static const String keyActiveServerId = 'activeServerId';
  
  // App States
  static const int statePending = 0;
  static const int stateLoaded = 1;
  static const int stateError = 2;
  
  // Call Statuses
  static const String callStatusNew = 'new';
  static const String callStatusAccepted = 'accepted';
  static const String callStatusRejected = 'rejected';
  static const String callStatusInProgress = 'in_progress';
  static const String callStatusArrived = 'arrived';
  static const String callStatusCompleted = 'completed';
  static const String callStatusCancelled = 'cancelled';
  
  // Call Card Statuses
  static const String cardStatusDraft = 'draft';
  static const String cardStatusInReview = 'in_review';
  static const String cardStatusAccepted = 'accepted';
  static const String cardStatusRejected = 'rejected';
  static const String cardStatusArchived = 'archived';
  
  // Sync Statuses
  static const String syncStatusPending = 'pending';
  static const String syncStatusSynced = 'synced';
  static const String syncStatusFailed = 'failed';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int syncInterval = 300000; // 5 minutes
  
  // Location tracking
  static const int locationUpdateInterval = 30000; // 30 seconds
  static const double locationMinDistance = 10.0; // 10 meters
} 
