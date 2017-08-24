//
//  SSH Icon
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#define ONE_LINER(x)		[[x description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
#define PRETTY_BOOL(x)		(x) ? @"Yes" : @"No"
#define LOG_LINE()			HBLogDebug(@"----------------------------------------")
#define LOG_SPACE()			HBLogDebug(@" ")

#define kPrefsChangedNotification       CFSTR("com.sticktron.sshicon.settingschanged")

static NSString *const kPrefsPlistPath = @"/var/mobile/Library/Preferences/com.sticktron.sshicon.plist";
static NSString *const kIconStylesPath = @"/Library/SSHIcon";

@interface UIImage (SSHIcon)
- (id)_flatImageWithColor:(id)arg1;
@end
