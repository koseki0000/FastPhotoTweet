//
//  TimelineMenu.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import <UIKit/UIKit.h>
#import "NSNotificationCenter+EasyPost.h"

@interface TimelineMenu : UIView <UITableViewDataSource, UITableViewDelegate>

- (id)initWithTweet:(NSDictionary *)tweet;

@property (retain, nonatomic) NSArray *menuList;
@property (retain, nonatomic) NSDictionary *tweet;

@property (retain, nonatomic) UIToolbar *topBar;
@property (retain, nonatomic) UITableView *menuTable;

- (void)pushCancelButton;

@end
