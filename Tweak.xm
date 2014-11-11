//
//  Tweak.xm
//  HiddenCallLog7
//
//  Created by Timm Kandziora on 11.11.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

@interface PHRecentsViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
// Legacy
- (void)_filterWasToggled:(id)toggled;
- (void)_clearButtonTapped:(id)tapped;
- (void)actionSheet:(id)actionSheet clickedButtonAtIndex:(int)index;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)_reloadTableViewAndNavigationBar;
// iOS7
- (float)tableView:(id)tableView heightForRowAtIndexPath:(id)indexPath;
- (void)tableView:(id)tableView didSelectRowAtIndexPath:(id)indexPath;
// iOS8
- (long long)tableView:(id)tableView numberOfRowsInSection:(long long)section;
@end

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.hiddencalllog7.plist"

static BOOL hidden = YES;
static BOOL saveState = NO;

%group iOS7
%hook PHRecentsViewController

- (float)tableView:(id)tableView heightForRowAtIndexPath:(id)indexPath
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

- (void)tableView:(id)tableView didSelectRowAtIndexPath:(id)indexPath
{
    if (hidden) {
        return;
    } else {
        %orig;
    }
}

%end
%end

%group iOS8
%hook PHRecentsViewController

- (long long)tableView:(id)tableView numberOfRowsInSection:(long long)section
{
    if (!hidden) {
        return %orig;
    } else {
        return 0;
    }
}

%end
%end

%group Legacy
%hook PHRecentsViewController

- (void)_filterWasToggled:(id)toggled
{
    if (!hidden) {
        %orig;
    }
}

- (void)_clearButtonTapped:(id)tapped
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear All Recents" otherButtonTitles:@"Toggle Hidden", nil];
    [sheet showInView:[UIWindow keyWindow]];
    [sheet release];
}

- (void)actionSheet:(id)actionSheet clickedButtonAtIndex:(int)index
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

        [self setEditing:NO animated:YES];

        [self _reloadTableViewAndNavigationBar];
    }
}

%end
%end

static void ReloadSettings()
{
    // 'system' is deprecated: first deprecated in iOS 8.0 - Use posix_spawn APIs instead.
    // Because 'system' is easier to use I'll use it as long as it works
    system("killall -9 MobilePhone");
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
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)ReloadSettings,
                                        CFSTR("com.shinvou.hiddencalllog7/reloadSettings"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettingsOnStartup();

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            %init(iOS8);
        } else {
            %init(iOS7);
        }

        %init(Legacy);
	}
}
