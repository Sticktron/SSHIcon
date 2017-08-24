//
//  SSH Icon (Client)
//
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "common.h"
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/_UILegibilityImageSet.h>


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
	
	
	
	// [UIStatusBar ]
}


@interface SSHIconItemView : UIStatusBarCustomItemView
@property (nonatomic, assign) UIColor *glyphColor;
@end


%subclass SSHIconItemView : UIStatusBarCustomItemView
%property (nonatomic, retain) UIColor *glyphColor;

- (instancetype)initWithItem:(id)item data:(id)data actions:(int)actions style:(UIStatusBarForegroundStyleAttributes *)style {
	%log;
	if ((self = %orig)) {
		self.userInteractionEnabled = YES;
		
		// add tap recognizer
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
			initWithTarget:self
			action:@selector(handleTap:)];
		tap.delegate = (id <UIGestureRecognizerDelegate>)self;
		[self addGestureRecognizer:tap];
	}
	return self;
}

%new
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
	HBLogDebug(@"Tap gesture recognized");
	
	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"Remote Connections"
		message:@"Coming soon...\n\nHost: < placeholder > \n\nUser: < placeholder > \n\nPID: < placeholder >\n\n"
		preferredStyle:UIAlertControllerStyleAlert
	];
	
	[alert addAction:[UIAlertAction
		actionWithTitle:@"Done"
		style:UIAlertActionStyleCancel
	    handler:^(UIAlertAction *action) {
			// do something
        }]
	];
	
	[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
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
