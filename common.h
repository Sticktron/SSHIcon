//
//  SSH Icon
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#define ONE_LINER(x)		[[x description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
#define PRETTY_BOOL(x)		(x) ? @"Yes" : @"No"
#define LOG_LINE()			HBLogDebug(@"----------------------------------------")
#define LOG_SPACE()			HBLogDebug(@" ")

#define kPrefsAppID 					CFSTR("com.sticktron.sshicon")
#define kPrefsChangedNotification       CFSTR("com.sticktron.sshicon.settingschanged")
