//
//  SSH Icon Settings
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <spawn.h>
#import <version.h>


static NSString *const kPrefsPlistPath = @"/var/mobile/Library/Preferences/com.sticktron.sshicon.plist";
static NSString *const kIconStylesPath = @"/Library/SSHIcon/";
static int const kIconPreviewSection = 3;
static float const kIconPreviewCellHeight = 30;


@interface SSHIconSettingsController : PSListController
@property (nonatomic, strong) UIView *iconPreviewView;
@property (nonatomic, strong) NSArray *iconStyles;
- (void)updateStyleList;
- (NSArray *)iconStyleNames;
@end


@implementation SSHIconSettingsController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

/* Load icon style names from /Library/SSHIcon/ */
- (void)updateStyleList {
	self.iconStyles = nil;
	
	NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kIconStylesPath error:nil];
	HBLogDebug(@"folders = %@", folders);
	
	if (folders.count > 0) {
		NSMutableArray *styles = [NSMutableArray array];
		
		for (int i = 0; i < folders.count; i++) {
			NSString *folder = folders[i];
			if (folder) {
				[styles addObject:folder];
			}
		}
		NSArray *sortedStyles = [styles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		self.iconStyles = sortedStyles;
	}
}

/* Data source for icon style specifier */
- (NSArray *)iconStyleNames {
	if (!self.iconStyles) {
		[self updateStyleList];
	}
	return self.iconStyles;
}

/* Manually keep the plist up to date because the tweak runs in sandboxed apps */
- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	if (!settings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return settings[specifier.properties[@"key"]];
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kPrefsPlistPath]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:kPrefsPlistPath atomically:NO]; //sandbox issue if atomic!
	
	NSString *notificationValue = specifier.properties[@"PostNotification"];
	if (notificationValue) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationValue, NULL, NULL, YES);
	}
}

/* Restart SpringBoard after alerting user */
- (void)respring {
	if (!IS_IOS_OR_NEWER(iOS_8_0)) {
		[self respring7];
		return;
	}
	
	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"Respring"
		message:@"Restart SpringBoard now?"
		preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *defaultAction = [UIAlertAction
		actionWithTitle:@"OK"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction *action) {
			[self respringNow];
		}];
	
	UIAlertAction *cancelAction = [UIAlertAction
		actionWithTitle:@"Cancel"
		style:UIAlertActionStyleCancel
		handler:nil];
	
	[alert addAction:defaultAction];
	[alert addAction:cancelAction];
	
	[self presentViewController:alert animated:YES completion:nil];
	
}
- (void)respringNow {
	NSLog(@"SSHIcon: User requested a respring.");
	pid_t pid;
	const char* args[] = { "killall", "-HUP", "SpringBoard", NULL };
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}
/* iOS < 8 */
- (void)respring7 {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring"
													message:@"Restart SpringBoard now?"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	
	[alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex {
	if (buttonIndex == 1) { // YES
		[self respringNow];
	}
}

/* Show preview of icon styles */
- (id)tableView:(id)tableView viewForHeaderInSection:(NSInteger)section {
	HBLogDebug(@"viewForHeaderInSection:%ld", (long)section);
	
	if (section != kIconPreviewSection) {
		return [super tableView:tableView viewForHeaderInSection:section];
	}
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kIconPreviewCellHeight)];
	HBLogDebug(@"headerView = %@", headerView);
	headerView.backgroundColor = UIColor.whiteColor;
	headerView.opaque = YES;
	headerView.autoresizesSubviews = YES;
	
	[self updateStyleList];
	HBLogDebug(@"styles = %@", self.iconStyles);
	
	float w = floor(headerView.bounds.size.width / (float)(self.iconStyles.count));
	CGRect frame = CGRectMake(0, 0, w, headerView.bounds.size.height);
	
	for (int i = 0; i < self.iconStyles.count; i++) {
		NSString *style = self.iconStyles[i];
		HBLogDebug(@"loading preview image for icon: %@", style);
		
		NSString *path = [NSString stringWithFormat:@"%@/%@/%@.png", kIconStylesPath, style, @"Icon_Color_20"];
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		if (!image) {
			NSString *path = [NSString stringWithFormat:@"%@/%@/%@.png", kIconStylesPath, style, @"Icon_20"];
			image = [[UIImage alloc] initWithContentsOfFile:path];
		}
		
		HBLogDebug(@" = %@", image);
		
		frame.origin.x = floor(w * (float)i);
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
		imageView.image = image;
		imageView.contentMode = UIViewContentModeCenter;
		
		// tint bg if selected
		NSString *currentStyle = [self readPreferenceValue:[self specifierForID:@"IconStyle"]];
		if ([style isEqualToString:currentStyle]) {
			imageView.layer.borderWidth = 1;
			imageView.layer.borderColor = [self.view.tintColor CGColor];
		}
		
		[headerView addSubview:imageView];
	}
	
	return headerView;
}
- (CGFloat)tableView:(id)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == kIconPreviewSection) {
		return kIconPreviewCellHeight;
	} else {
		return [super tableView:tableView heightForHeaderInSection:section];
	}
}

- (void)openGitHubIssues {
	NSURL *url = [NSURL URLWithString:@"http://github.com/sticktron/SSHIcon/issues"];
	[[UIApplication sharedApplication] openURL:url];
}

@end
