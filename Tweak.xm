//
//  Tweak.xm
//  HiddenCallLog7
//
//  Created by Timm Kandziora on 24.07.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

#import <substrate.h>

@interface PHRecentsViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
- (void)_clearButtonTapped:(id)tapped;
- (void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index;
- (float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath;
- (void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
- (void)_filterWasToggled:(id)toggled;
- (void)_reloadTableViewAndNavigationBar;
@end

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.hiddencalllog7.plist"

static BOOL hidden = YES;
static BOOL saveState = NO;

%hook PHRecentsViewController

- (void)_clearButtonTapped:(id)tapped
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear All Recents" otherButtonTitles:@"Toggle Hidden", nil];
    [sheet showInView:[UIWindow keyWindow]];
    [sheet release];
}

- (void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index
{
    if (index == 0) {
		%orig;
    } else if (index == 1) {
        hidden = !hidden;

        if (saveState) {
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settings setObject:[NSNumber numberWithBool:hidden] forKey:@"isHidden"];
            [settings writeToFile:settingsPath atomically:YES];
            [settings release];
        }

		[self _reloadTableViewAndNavigationBar];
    }
}

- (float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath
{
    if (hidden) {
        return 0.0;
    } else {
        return %orig;
    }
}

%new - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (hidden) {
        return UITableViewCellAccessoryNone;
    } else {
        return UITableViewCellAccessoryDetailButton;
    }
}

- (void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath
{
    if (hidden) {
        return;
    } else {
        %orig;
    }
}

- (void)_filterWasToggled:(id)toggled
{
    if (hidden) {
        return;
    } else {
        %orig;
    }
}

%end

static void ReloadSettings()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"saveState"]) {
            system("killall -9 MobilePhone");

            saveState = [[settings objectForKey:@"saveState"] boolValue];

            if (saveState) {
                if ([settings objectForKey:@"isHidden"]) {
                    hidden = [[settings objectForKey:@"isHidden"] boolValue];
                } else {
                    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"isHidden"];
                    [settings writeToFile:settingsPath atomically:YES];
                }
            }
        }
    }

    [settings release];
}

static void ReloadSettingsOnStartup()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"saveState"]) {
            saveState = [[settings objectForKey:@"saveState"] boolValue];

            if (saveState) {
                if ([settings objectForKey:@"isHidden"]) {
                    hidden = [[settings objectForKey:@"isHidden"] boolValue];
                } else {
                    [settings setObject:[NSNumber numberWithBool:YES] forKey:@"isHidden"];
                    [settings writeToFile:settingsPath atomically:YES];
                }
            }
        }
    }

    [settings release];
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.hiddencalllog7/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettingsOnStartup();
	}
}
