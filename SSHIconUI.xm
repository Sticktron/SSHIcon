//
//  SSH Icon (Client)
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "common.h"
#import "SSHIconConnectionInfo.h"
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/_UILegibilityImageSet.h>
#import <dlfcn.h>


static NSString *iconStyle;


static void loadSettings() {
	HBLogDebug(@"loadSettings()");
	
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	
	// apply user settings or defaults
	iconStyle = settings[@"IconStyle"] ? settings[@"IconStyle"] : @"Boxed";
	
	HBLogDebug(@"got settings: Enabled=1; IconStyle=%@;", iconStyle);
}

static void handleSettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	HBLogDebug(@"***** Got Notification: %@", name);
	HBLogDebug(@"observer = %@", observer);
	HBLogDebug(@"object = %@", object);
	HBLogDebug(@"userInfo = %@", userInfo);
	loadSettings();
}


@interface SSHIconItemView : UIStatusBarCustomItemView
@property (nonatomic, assign) UIColor *glyphColor;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (void)showPopup;
@end


%subclass SSHIconItemView : UIStatusBarCustomItemView
%property (nonatomic, retain) UIColor *glyphColor;

- (instancetype)initWithItem:(id)item data:(id)data actions:(int)actions style:(UIStatusBarForegroundStyleAttributes *)style {
	%log;
	if ((self = %orig)) {
		self.userInteractionEnabled = YES;
		
		// add tap recognizer
		UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc]
			initWithTarget:self
			action:@selector(handleTap:)];
		tap.delegate = (id <UIGestureRecognizerDelegate>)self;
		[self addGestureRecognizer:tap];
	}
	return self;
}

- (_UILegibilityImageSet *)contentsImage {
	%log;
	
	if (!iconStyle) {
		loadSettings();
	}
	
	int size = self.bounds.size.height == 24 ? 24 : 20;
	
	NSString *path = [NSString stringWithFormat:@"%@/%@/Icon_Color_%d", kIconStylesPath, iconStyle, size];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	if (!image) {
		NSString *path = [NSString stringWithFormat:@"%@/%@/Icon_%d", kIconStylesPath, iconStyle, size];
		image = [[UIImage alloc] initWithContentsOfFile:path];
		UIColor *color = [[self foregroundStyle] tintColor];
		image = [image _flatImageWithColor:color];
	}
	HBLogDebug (@"image = %@", image);
	
	return [_UILegibilityImageSet imageFromImage:image withShadowImage:nil];
}

- (void)updateContentsAndWidth {
	%log;
	%orig;
	[self invalidateIntrinsicContentSize];
}

%new - (void)showPopup {
	// Check for connections
	NSArray *connections = [[SSHIconConnectionInfo sharedInstance] connections];
	int num = connections.count;
	
	// I'll use a UIAlertController for this (not the prettiest, but functional.)
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"SSH Connection(s): %d", num]
		message:@"No connections."
		preferredStyle:UIAlertControllerStyleAlert];
		
	[alert addAction:[UIAlertAction
		actionWithTitle:@"Done"
		style:UIAlertActionStyleCancel
	    handler:^(UIAlertAction *action) {}]];
	
	// Build a list of connections
	if (num > 0) {
		NSString *message = @"\n";
		for (NSDictionary *dict in connections) {
			message = [message stringByAppendingString:[NSString stringWithFormat:@"IP: \t\t%@\n", dict[@"host"]]];
			if (dict[@"login"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"User: \t%@\n", dict[@"login"]]];
			if (dict[@"pid"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"PID: \t\t%@\n", dict[@"pid"]]];
			// if (dict[@"line"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"Line: \t%@\n", dict[@"line"]]];
			if (dict[@"type"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"Type: \t%@\n", dict[@"type"]]];
			if (dict[@"timeval"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"Time: \t%@", dict[@"timeval"]]];
			message = [message stringByAppendingString:@"\n"];
		}
		
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setAlignment:NSTextAlignmentLeft];
		// [paragraphStyle setLineSpacing:4];
		
		NSMutableAttributedString *formattedMessage = [[NSMutableAttributedString alloc]
			initWithString:message
			attributes: @{
				NSParagraphStyleAttributeName: paragraphStyle,
				NSFontAttributeName : [UIFont systemFontOfSize:12],
				// NSForegroundColorAttributeName : [UIColor colorWithWhite:0.2 alpha:1]
			}
		];
		
		// Set the alert body
		[alert setValue:formattedMessage forKey:@"attributedMessage"];
	}
	
	// Show the alert
	[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}

%new - (void)handleTap:(UITapGestureRecognizer *)recognizer {
	[self showPopup];
}

%end


%ctor {
	@autoreleasepool {
		HBLogDebug(@"SSHIcon client init.");
		
		// quit if libstatusbar is not installed!
		void *handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
		if (handle == NO) {
			HBLogError(@"Can't find libstatusbar :(");
			return;
		}
		
		loadSettings();
		
		%init;
		
		// listen for changes to settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
			handleSettingsChanged, kPrefsChangedNotification,
			NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}
