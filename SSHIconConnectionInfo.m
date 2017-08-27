//
//  SSH Icon (Connection Info Helper)
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "SSHIconConnectionInfo.h"
#import <utmpx.h>


@interface SSHIconConnectionInfo ()
@property (nonatomic, strong) NSArray *connections;
@end


@implementation SSHIconConnectionInfo

+ (instancetype)sharedInstance {
	HBLogDebug(@"+[SSHIconConnectionInfo sharedInstance]");
	static dispatch_once_t p = 0;
    __strong static SSHIconConnectionInfo *sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (instancetype)init {
	HBLogDebug(@"[SSHIconConnectionInfo init]");
    if (self = [super init]) {
		//
    }
    return self;
}

- (void)dealloc {}

- (void)scan {
	HBLogDebug(@"[SSHIconConnectionInfo scan]");
	
	self.connected = NO;
	self.connections = nil;
	
	NSMutableArray *connections = [NSMutableArray array];
	struct utmpx *up;
	
	setutxent();
	up = getutxent();
	while (up != NULL) {
		HBLogDebug(@"==============================");
		HBLogDebug(@"read a line from utmpx file...");
		HBLogDebug(@"------------------------------");
		HBLogDebug(@"login name: %s", up->ut_user);
		HBLogDebug(@"id: %s", up->ut_id);
		HBLogDebug(@"tty name: %s", up->ut_line);
		HBLogDebug(@"pid: %d", (int)(up->ut_pid));
		HBLogDebug(@"host name: %s", up->ut_host);
		HBLogDebug(@"==============================");
		
		if (up->ut_host[0]) {
			HBLogDebug(@"found a connected host!");
			self.connected = YES;
			
			// store connection info
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			dict[@"host"] = [NSString stringWithFormat:@"%s", up->ut_host];
			dict[@"pid"] = [NSString stringWithFormat:@"%d", (int)up->ut_pid];
			dict[@"login"] = [NSString stringWithFormat:@"%s", up->ut_user];
			dict[@"line"] = [NSString stringWithFormat:@"%s", up->ut_line];
			dict[@"id"] = [NSString stringWithFormat:@"%s", up->ut_id];
			[connections addObject:dict];
		}
		up = getutxent();
	}
	endutxent();
	HBLogDebug(@"self.connected = %@", self.connected?@"Yes":@"No");
	HBLogDebug(@"number of connections: %d", (int)connections.count);
	
	if (self.connected) {
		self.connections = [connections copy];
	}
}

@end
