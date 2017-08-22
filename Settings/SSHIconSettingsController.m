//
//  SSH Icon Settings
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import <Preferences/PSListController.h>
#import <spawn.h>

@interface SSHIconSettingsSettingsController : PSListController
@end

@implementation SSHIconSettingsSettingsController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

/* Show Respring alert */
- (void)respring {
	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"Respring"
		message:@"Restart SpringBoard now?"
		preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *defaultAction = [UIAlertAction
		actionWithTitle:@"OK"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction *action) {
			// respring!
			[self respringNow];
		}];
	[alert addAction:defaultAction];
	UIAlertAction *cancelAction = [UIAlertAction
		actionWithTitle:@"Cancel"
		style:UIAlertActionStyleCancel
		handler:nil];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)respringNow {
	NSLog(@"SSHIcon: User requested a respring.");
	pid_t pid;
	const char* args[] = { "killall", "-HUP", "SpringBoard", NULL };
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}
@end
