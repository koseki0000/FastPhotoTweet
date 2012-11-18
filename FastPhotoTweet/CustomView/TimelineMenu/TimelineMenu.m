//
//  TimelineMenu.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import "TimelineMenu.h"
#import "TimelineMenuCell.h"

#define SCREEN_HEIGHT (int)[UIScreen mainScreen].applicationFrame.size.height
#define TAB_BAR_HEIGHT 48
#define TOOL_BAR_HEIGHT 44

@implementation TimelineMenu

- (id)initWithTweet:(NSDictionary *)tweet {
    
    self = [super initWithFrame:CGRectMake(0,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT,
                                           266,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT)];
    self.backgroundColor = [UIColor whiteColor];
    
    self.menuList = @[@"URLを開く", @"Reply", @"Favorite／UnFavorite", @"ReTweet",
    @"Fav+RT", @"IDとFav,RTを選択", @"ハッシュタグをNG", @"クライアントをNG", @"InReplyTo", @"Tweetをコピー",
    @"Tweetを削除", @"Tweetを編集", @"ユーザーメニュー"];
    
    self.tweet = [[NSDictionary alloc] initWithDictionary:tweet];
    tweet = nil;
    
    self.topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              266,
                                                              44)];
    [self addSubview:self.topBar];
    
    self.topBar.tintColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(pushCancelButton)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    [self.topBar setItems:@[space, cancelButton]];
    
    self.menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   44,
                                                                   266,
                                                                   SCREEN_HEIGHT - TOOL_BAR_HEIGHT - TAB_BAR_HEIGHT)
                                                  style:UITableViewStylePlain];
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    [self addSubview:self.menuTable];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimelineMenuCell *cell = (TimelineMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"TimelineMenuCell"];
    
    if ( cell == nil ) {
        
        cell = [[TimelineMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"TimelineMenuCell"];
    }
    
    cell.textLabel.text = [_menuList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuAction"
                                           withUserInfo:@{@"Action":@(indexPath.row)}];
}

- (void)pushCancelButton {
    
    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuCanceled"];
}

- (void)dealloc {
    
//    NSLog(@"%s", __func__);
    
    self.menuTable.delegate = nil;
    self.menuTable.dataSource = nil;
    [self.topBar removeFromSuperview];
    [self.menuTable removeFromSuperview];
}

@end
