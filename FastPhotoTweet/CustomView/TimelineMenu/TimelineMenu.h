//
//  TimelineMenu.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import <UIKit/UIKit.h>
#import "TWEntities.h"
#import "NSNotificationCenter+EasyPost.h"

typedef enum {
    TimeLineMenuIdentifierMain,
    TimeLineMenuIdentifierCopy,
    TimeLineMenuIdentifierUser,
}TimeLineMenuIdentifier;

@interface TimelineMenu : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithTweet:(NSDictionary *)tweet forMenu:(TimeLineMenuIdentifier)menuIdentifier;

@property __block NSUInteger count;
@property NSUInteger menuNo;
@property NSUInteger userMenuActionNo;
@property (retain, nonatomic) NSMutableArray *menuList;
@property (retain, nonatomic) NSMutableArray *nextMenuList;
@property (retain, nonatomic) NSDictionary *tweet;
@property (retain, nonatomic) NSTimer *timer;
@property (copy, nonatomic) NSString *selectUser;

@property (retain, nonatomic) UIToolbar *topBar;
@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@property (retain, nonatomic) UIBarButtonItem *backButton;
@property (retain, nonatomic) UIBarButtonItem *space;
@property (retain, nonatomic) UITableView *menuTable;

- (UIColor *)getTextColor:(CellTextColor)color;
- (void)pushCancelButton;
- (void)pushBackButton;

- (void)startRemoveAllTimer;

- (void)removeAllItems;
- (void)addNewListItems;

@end
