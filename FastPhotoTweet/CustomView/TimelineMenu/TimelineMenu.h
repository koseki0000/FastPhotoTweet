//
//  TimelineMenu.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import <UIKit/UIKit.h>
#import "TimelineViewController.h"
#import "NSNotificationCenter+EasyPost.h"
#import "TWTweet.h"

typedef enum {
    TimeLineMenuIdentifierMain,
    TimeLineMenuIdentifierCopy,
    TimeLineMenuIdentifierUser,
}TimeLineMenuIdentifier;

typedef enum {
    MainMenuReply,
    MainMenuFav,
    MainMenuRT,
    MainMenuFavRT,
    MainMenuSeleceID,
    MainMenuHashTagNG,
    MainMenuClientNG,
    MainMenuInReplyTo,
    MainMenuCopy,
    MainMenuDelete,
    MainMenuEdit,
    MainMenuUserMenu
}MainMenu;

@interface TimelineMenu : UIView <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

- (id)initWithTweet:(TWTweet *)tweet forMenu:(TimeLineMenuIdentifier)menuIdentifier controller:(TimelineViewController *)controller;

@property (assign, nonatomic) TimelineViewController *controller;
@property __block NSUInteger count;
@property NSUInteger menuNo;
@property NSUInteger userMenuActionNo;
@property (retain, nonatomic) NSArray *tweetInURLs;
@property (retain, nonatomic) NSMutableArray *menuList;
@property (retain, nonatomic) NSMutableArray *nextMenuList;
@property (retain, nonatomic) TWTweet *tweet;
@property (retain, nonatomic) NSTimer *timer;
@property (copy, nonatomic) NSString *selectUser;

@property (retain, nonatomic) UIToolbar *topBar;
@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@property (retain, nonatomic) UIBarButtonItem *backButton;
@property (retain, nonatomic) UIBarButtonItem *space;
@property (retain, nonatomic) UITableView *menuTable;

- (void)pushCancelButton;
- (void)pushBackButton;

- (void)openUserMenu:(NSString *)screenName menuIndex:(NSInteger)menuIndex;

- (void)startRemoveAllTimer;

- (void)removeAllItems;
- (void)addNewListItems;

@end
