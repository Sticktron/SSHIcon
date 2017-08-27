//
//  SSH Icon (Connection Info Helper)
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

@interface SSHIconConnectionInfo : NSObject
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong, readonly) NSArray *connections;
+ (instancetype)sharedInstance;
- (void)scan;
@end
