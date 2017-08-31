//
//  SSH Icon (Connection Info Helper)
//
//  Uses the API in umptx.h to read connection info from the
//  log file at /var/run/utmpx.
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "SSHIconConnectionInfo.h"
#import <utmpx.h>


// Returns a name for a ut_type.
static NSString *typeToString(short type) {
	// Values for ut_type (from utmpx.h)
	// #define EMPTY			0
	// #define RUN_LVL			1
	// #define BOOT_TIME		2
	// #define OLD_TIME			3
	// #define NEW_TIME			4
	// #define INIT_PROCESS		5
	// #define LOGIN_PROCESS	6
	// #define USER_PROCESS		7
	// #define DEAD_PROCESS		8
	switch (type) {
		case 0: return @"EMPTY";
		case 1: return @"RUN_LVL";
		case 2: return @"BOOT_TIME";
		case 3: return @"OLD TIME";
		case 4: return @"NEW_TIME";
		case 5: return @"INIT_PROCESS";
		case 6: return @"LOGIN_PROCESS";
		case 7: return @"USER_PROCESS";
		case 8: return @"DEAD_PROCESS";
		default: return @"?";
	}
}


@implementation SSHIconConnectionInfo

+ (instancetype)sharedInstance {
	static dispatch_once_t p = 0;
    __strong static SSHIconConnectionInfo *sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (BOOL)isConnected {
	return (self.connections.count > 0);
}

- (NSArray *)connections {
	NSMutableArray *connections = [NSMutableArray array];
	
	struct utmpx *up;
	setutxent();
	while ((up = getutxent()) != NULL) {
		// HBLogDebug(@" ");
		// HBLogDebug(@"==============================");
		// HBLogDebug(@"read a line from utmpx...");
		// HBLogDebug(@"------------------------------");
		// HBLogDebug(@"type: %@", typeToString(up->ut_type));
		// HBLogDebug(@"timeval: %s", ctime((const time_t *) &up->ut_tv.tv_sec));
		// HBLogDebug(@"host: %s", up->ut_host);
		// HBLogDebug(@"user: %s", up->ut_user);
		// HBLogDebug(@"line: %s", up->ut_line);
		// HBLogDebug(@"pid: %d", (int)(up->ut_pid));
		// HBLogDebug(@"id: %s", up->ut_id);
		// HBLogDebug(@"------------------------------");
		
		if (up->ut_host[0]) {
			HBLogDebug(@"found a connected host!");
			
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			dict[@"host"] = [NSString stringWithFormat:@"%s", up->ut_host];
			dict[@"timeval"] = [NSString stringWithFormat:@"%s", ctime((const time_t *) &up->ut_tv.tv_sec)];
			dict[@"user"] = [NSString stringWithFormat:@"%s", up->ut_user];
			dict[@"line"] = [NSString stringWithFormat:@"%s", up->ut_line];
			dict[@"type"] = [NSString stringWithFormat:@"%@", typeToString(up->ut_type)];
			dict[@"id"] = [NSString stringWithFormat:@"%s", up->ut_id];
			if ((int)up->ut_pid > 0) {
				dict[@"pid"] = [NSString stringWithFormat:@"%d", (int)up->ut_pid];
			}
			
			[connections addObject:dict];
		}
	}
	endutxent();
	HBLogDebug(@"# of conns: %d", (int)connections.count);
	
	return connections;
}

@end
