//
//  SSH Icon Settings
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <spawn.h>


static NSString *const kPrefsPlistPath = @"/var/mobile/Library/Preferences/com.sticktron.sshicon.plist";
static NSString *const kIconStylesPath = @"/Library/SSHIcon";
static int const kIconPreviewSection = 3;
static float const kIconPreviewCellHeight = 30;


@interface SSHIconSettingsController : PSListController
@property (nonatomic, strong) UIView *iconPreviewView;
@property (nonatomic, strong) NSArray *iconStyles;
- (void)updateStyleList;
@end


@implementation SSHIconSettingsController

- (void)viewWillAppear:(BOOL)animated {
	HBLogDebug(@"viewWillAppear()");
	[super viewWillAppear:animated];
	[self updateStyleList];
	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

/* Load icon style names from /Library/SSHIcon/ */
- (void)updateStyleList {
	NSMutableArray *styles = [NSMutableArray array];
	NSMutableArray *folders = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:kIconStylesPath error:nil] mutableCopy];
	HBLogDebug(@"folders = %@", folders);
	
	for (int i = 0; i < folders.count; i++) {
		NSString *folder = folders[i];
		HBLogDebug(@"folder = %@", folder);
		if (folder) {
			[styles addObject:folder];
		}
	}
	HBLogDebug(@"styles = %@", styles);
	
	if (styles) {
		self.iconStyles = [NSArray arrayWithArray:[styles sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	}
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

/* Show preview of icon styles */
/*
- (id)tableView:(id)tableView viewForFooterInSection:(NSInteger)section {
	HBLogDebug(@"viewForFooterInSection:%ld", (long)section);
	
	if (section != kIconPreviewSection) {
		return [super tableView:tableView viewForFooterInSection:section];
	}
	
	// if (!self.iconPreviewView) {
		HBLogDebug(@"creating iconPreviewView...");
		
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
			
			NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kIconStylesPath, style, @"Icon_Color_20"];
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			if (!image) {
				NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kIconStylesPath, style, @"Icon_20"];
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
				// imageView.backgroundColor = self.view.tintColor;
				imageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
			}
			
			[headerView addSubview:imageView];
		// }
		
		// self.iconPreviewView = headerView;
	}
	
	// return self.iconPreviewView;
	return headerView;
}
- (CGFloat)tableView:(id)tableView heightForFooterInSection:(NSInteger)section {
	if (section == kIconPreviewSection) {
		return kIconPreviewCellHeight;
	} else {
		return [super tableView:tableView heightForFooterInSection:section];
	}
}
*/
- (id)tableView:(id)tableView viewForHeaderInSection:(NSInteger)section {
	HBLogDebug(@"viewForHeaderInSection:%ld", (long)section);
	
	if (section != kIconPreviewSection) {
		return [super tableView:tableView viewForHeaderInSection:section];
	}
	
	// if (!self.iconPreviewView) {
		HBLogDebug(@"creating iconPreviewView...");
		
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
			
			NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kIconStylesPath, style, @"Icon_Color_20"];
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			if (!image) {
				NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kIconStylesPath, style, @"Icon_20"];
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
				// imageView.backgroundColor = self.view.tintColor;
				imageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
			}
			
			[headerView addSubview:imageView];
		// }
		
		// self.iconPreviewView = headerView;
	}
	
	// return self.iconPreviewView;
	return headerView;
}
- (CGFloat)tableView:(id)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == kIconPreviewSection) {
		return kIconPreviewCellHeight;
	} else {
		return [super tableView:tableView heightForHeaderInSection:section];
	}
}




- (NSArray *)iconStyleNames:(id)target {
	return self.iconStyles;
}

- (void)openGitHubIssues {
	NSURL *url = [NSURL URLWithString:@"http://github.com/sticktron/SSHIcon/issues"];
	[[UIApplication sharedApplication] openURL:url];
}

@end
