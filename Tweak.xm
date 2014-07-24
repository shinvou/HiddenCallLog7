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
@end

static BOOL hidden = YES;

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
