//
//  SSH Icon (Connection Info Helper)
//
//  Uses the API in umptx.h to read connection info from the
//  log file at /var/run/utmpx.
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

@interface SSHIconConnectionInfo : NSObject
@property (nonatomic, strong, readonly) NSArray *connections;
@property (nonatomic, assign, readonly) BOOL isConnected;
+ (instancetype)sharedInstance;
@end
