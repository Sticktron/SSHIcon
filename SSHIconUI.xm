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
#import <version.h>


static NSString *iconStyle;


static void loadSettings() {
	HBLogDebug(@"loadSettings()");
	
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	
	// apply user settings or defaults
	iconStyle = settings[@"IconStyle"] ? settings[@"IconStyle"] : @"SSH";
	
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
@property (nonatomic, retain) UIColor *glyphColor;
- (void)showPopup;
- (void)handleGesture:(UITapGestureRecognizer *)recognizer;
@end


%subclass SSHIconItemView : UIStatusBarCustomItemView
%property (nonatomic, retain) UIColor *glyphColor;

- (instancetype)initWithItem:(id)item data:(id)data actions:(int)actions style:(UIStatusBarForegroundStyleAttributes *)style {
	%log;
	if ((self = %orig)) {
		self.userInteractionEnabled = YES;
		
		// add sideways swipe recognizer
		// UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
		// 	initWithTarget:self
		// 	action:@selector(handleGesture:)];
		// swipe.delegate = (id <UIGestureRecognizerDelegate>)self;
		// swipe.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
		// [self addGestureRecognizer:swipe];
		
		// add long press recongizer
		// UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]
		// 	initWithTarget:self
		// 	action:@selector(handleGesture:)];
		// press.delegate = (id <UIGestureRecognizerDelegate>)self;
		// [self addGestureRecognizer:press];
		
		// add tap recognizer
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
			initWithTarget:self
			action:@selector(handleGesture:)];
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
	
	// look for colored icon image first
	NSString *path = [NSString stringWithFormat:@"%@/%@/Icon_Color_%d.png", kIconStylesPath, iconStyle, size];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	
	if (!image) {
		// look for glyph icon image
		NSString *path = [NSString stringWithFormat:@"%@/%@/Icon_%d.png", kIconStylesPath, iconStyle, size];
		image = [[UIImage alloc] initWithContentsOfFile:path];
		
		// tint glyph to match statusbar style
		UIColor *color = [[self foregroundStyle] tintColor];
		image = [image _flatImageWithColor:color];
	}
	
	_UILegibilityImageSet *imageSet = [_UILegibilityImageSet imageFromImage:image withShadowImage:nil];
	
	return imageSet;
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
	NSString *title = [NSString stringWithFormat:@"SSH Connection(s): %d", num];
	
	BOOL isAtLeast8 = IS_IOS_OR_NEWER(iOS_8_0);
	
	// Build a list of connections
	NSString *message = @"\n";
	for (NSDictionary *dict in connections) {
		
		message = [message stringByAppendingString:@"IP: "];
		if (isAtLeast8) message = [message stringByAppendingString:@"\t\t"];
		message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[@"host"]]];
		
		if (dict[@"login"]) {
			message = [message stringByAppendingString:@"User: "];
			if (isAtLeast8) message = [message stringByAppendingString:@"\t"];
			message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[@"login"]]];
		}
		
		if (dict[@"pid"])  {
			message = [message stringByAppendingString:@"PID: "];
			if (isAtLeast8) message = [message stringByAppendingString:@"\t"];
			message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[@"pid"]]];
		}
		
		// if (dict[@"line"]) message = [message stringByAppendingString:[NSString stringWithFormat:@"Line: %@\n", dict[@"line"]]];
		
		if (dict[@"type"]) {
			message = [message stringByAppendingString:@"Type: "];
			if (isAtLeast8) message = [message stringByAppendingString:@"\t"];
			message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[@"type"]]];
		}
		
		if (dict[@"timeval"]) {
			message = [message stringByAppendingString:@"Time: "];
			if (isAtLeast8) message = [message stringByAppendingString:@"\t"];
			message = [message stringByAppendingString:[NSString stringWithFormat:@"%@", dict[@"timeval"]]];
		}
		
		message = [message stringByAppendingString:@"\n"];
	}
	
	// Show the alert
	if (isAtLeast8) { //  use UIAlertController
		UIAlertController *alert = [%c(UIAlertController) alertControllerWithTitle:title
			message:nil
			preferredStyle:UIAlertControllerStyleAlert];
		
		[alert addAction:[%c(UIAlertAction)
			actionWithTitle:@"Done"
			style:UIAlertActionStyleCancel
		    handler:^(UIAlertAction *action) {
			}]];
			
		// Format message text
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setAlignment:NSTextAlignmentLeft];
		
		NSAttributedString *formattedMessage = [[NSAttributedString alloc]
			initWithString:message
			attributes: @{
				NSParagraphStyleAttributeName: paragraphStyle,
				NSFontAttributeName : [UIFont systemFontOfSize:12],
			}];
		
		[alert setValue:formattedMessage forKey:@"attributedMessage"];
				
		[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
		
	} else { // use UIAlertView for iOS <= 7
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self
											  cancelButtonTitle:@"Done"
											  otherButtonTitles:nil];
		[alert show];
	}
}

%new - (void)handleGesture:(UITapGestureRecognizer *)recognizer {
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
