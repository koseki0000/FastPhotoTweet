//
//  TimelineMenu.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import <QuartzCore/QuartzCore.h>
#import "Share.h"
#import "TimelineAttributedRTCell.h"
#import "TimelineAttributedCell.h"
#import "TitleButton.h"
#import "TimelineMenu.h"
#import "TimelineMenuCell.h"
#import "NSDictionary+DataExtraction.h"
#import "NSString+Calculator.h"
#import "NSString+RegularExpression.h"
#import "NSArrayAdditions.h"
#import "TWEntities.h"
#import "TWFriends.h"

#define DELAY_TIME(x) dispatch_time(DISPATCH_TIME_NOW, x * NSEC_PER_SEC), dispatch_get_main_queue(),

#define CELL_IDENTIFIER @"TimelineAttributedCell"
#define RT_CELL_IDENTIFIER @"TimelineAttributedRTCell"

#define SCREEN_HEIGHT (int)[UIScreen mainScreen].applicationFrame.size.height
#define TAB_BAR_HEIGHT 48
#define TOOL_BAR_HEIGHT 44

#define BLACK_COLOR [UIColor blackColor]
#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0]
#define BLUE_COLOR  [UIColor blueColor]
#define RED_COLOR   [UIColor redColor]
#define GOLD_COLOR  [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0]

#define MAIN_MENU @[@"Reply", @"Favorite／UnFavorite", @"ReTweet", @"Fav+RT", @"IDとFav,RTを選択", @"ハッシュタグをNG", @"クライアントをNG", @"InReplyTo", @"Tweetをコピー", @"Tweetを削除", @"Tweetを編集", @"ユーザーメニュー"]
#define COPY_MENU @[@"STOT形式", @"本文", @"TweetへのURL", @"Tweet内のURL"]
#define USER_MENU @[@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", @"フォロー関連"]
#define FORROW_MENU @[@"スパム報告", @"ブロック", @"ブロック解除", @"フォロー", @"フォロー解除"]

@implementation TimelineMenu

- (id)initWithTweet:(NSDictionary *)tweet {
    
    self = [super initWithFrame:CGRectMake(0,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT,
                                           266,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT)];
    self.backgroundColor = [UIColor whiteColor];
    
    self.menuList = [NSMutableArray arrayWithArray:MAIN_MENU];
    self.tweet = [[NSDictionary alloc] initWithDictionary:tweet];
    [_menuList insertObject:[NSDictionary dictionaryWithDictionary:_tweet]
                    atIndex:0];
    
    self.topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              266,
                                                              44)];
    [self addSubview:_topBar];
    
    _topBar.tintColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0];
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル"
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(pushCancelButton)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"戻る"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(pushBackButton)];
    
    self.space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                               target:nil
                                                               action:nil];
    [_topBar setItems:@[_space, _cancelButton]];
    
    self.menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   44,
                                                                   266,
                                                                   SCREEN_HEIGHT - TOOL_BAR_HEIGHT - TAB_BAR_HEIGHT)
                                                  style:UITableViewStylePlain];
    _menuTable.delegate = self;
    _menuTable.dataSource = self;
    [self addSubview:_menuTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCancelButton)
                                                 name:@"OpenTimelineImage"
                                               object:nil];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.row == 0 ) {
        
        if ( [[_tweet objectForKey:@"retweeted_status"] boolForKey:@"id"] ) {
            
            //公式RT
            TimelineAttributedRTCell *cell = (TimelineAttributedRTCell *)[tableView dequeueReusableCellWithIdentifier:RT_CELL_IDENTIFIER];
            
            @autoreleasepool {
                
                if ( cell == nil ) {
                    
                    cell = [[TimelineAttributedRTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:RT_CELL_IDENTIFIER
                                                                  forWidth:210];
                }
                
                //Tweetの本文
                NSString *text = [_tweet objectForKey:@"text"];
                
                //ID
                NSString *screenName = [[[_tweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
                cell.iconView.buttonTitle = [NSString stringWithString:screenName];
                
                //ID - 日付 [クライアント名]
                NSString *infoLabelText = [_tweet objectForKey:@"info_text"];
                
                if ( [[Share images] objectForKey:screenName] != nil &&
                    cell.iconView.layer.sublayers.count != 0 ) {
                    
                    [[cell.iconView.layer.sublayers objectAtIndex:0] setContents:(id)[[Share images] imageForKey:screenName].CGImage];
                    
                }else {
                    
                    [[cell.iconView.layer.sublayers objectAtIndex:0] setContents:nil];
                }
                
                NSString *userName = [_tweet objectForKey:@"rt_user"];
                if ( [[Share images] objectForKey:userName] != nil &&
                    cell.iconView.layer.sublayers.count != 0 ) {
                    
                    [[cell.iconView.layer.sublayers objectAtIndex:1] setContents:(id)[[Share images] imageForKey:userName].CGImage];
                    
                }else {
                    
                    [[cell.iconView.layer.sublayers objectAtIndex:1] setContents:nil];
                }
                
                //Favoriteの色を変えて星をつける
                if ( [_tweet boolForKey:@"favorited"] ) {
                    
                    infoLabelText = [NSMutableString stringWithFormat:@"★%@", infoLabelText];
                }
                
                CGFloat contentsHeight = [text heightForContents:[UIFont systemFontOfSize:12]
                                                         toWidht:210
                                                       minHeight:31
                                                   lineBreakMode:NSLineBreakByCharWrapping];
                
                //セルへの反映開始
                cell.infoLabel.text = [NSString stringWithString:infoLabelText];
                
                NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
                [mainText setFont:[UIFont systemFontOfSize:12]];
                [mainText setTextColor:GREEN_COLOR range:NSMakeRange(0, text.length)];
                [mainText setTextAlignment:kCTLeftTextAlignment
                             lineBreakMode:kCTLineBreakByCharWrapping
                             maxLineHeight:14.0
                             minLineHeight:14.0
                            maxLineSpacing:1.0
                            minLineSpacing:1.0
                                     range:NSMakeRange(0, mainText.length)];
                cell.mainLabel.attributedText = mainText;
                
                //セルの高さを設定
                cell.mainLabel.frame = CGRectMake(54, 19, 210, contentsHeight);
            }
            
            return cell;
            
        }else {
            
            TimelineAttributedCell *cell = (TimelineAttributedCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
            
            @autoreleasepool {
                
                if ( cell == nil ) {
                    
                    cell = [[TimelineAttributedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CELL_IDENTIFIER
                                                                forWidth:210];
                }
                
                //Tweetの本文
                NSString *text = [_tweet objectForKey:@"text"];
                
                //ID
                NSString *screenName = [[_tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                cell.iconView.buttonTitle = [NSString stringWithString:screenName];
                
                //ID - 日付 [クライアント名]
                NSString *infoLabelText = [_tweet objectForKey:@"info_text"];
                
                if ( [[Share images] objectForKey:screenName] != nil &&
                    cell.iconView.layer.sublayers.count != 0 &&
                    [[cell.iconView.layer.sublayers.lastObject name] isEqualToString:@"Icon"] ) {
                    
                    [cell.iconView.layer.sublayers.lastObject setContents:(id)[[Share images] imageForKey:screenName].CGImage];
                    
                }else {
                    
                    [cell.iconView.layer.sublayers.lastObject setContents:nil];
                }
                
                CGFloat contentsHeight = [text heightForContents:[UIFont systemFontOfSize:12]
                                                         toWidht:210
                                                       minHeight:31
                                                   lineBreakMode:NSLineBreakByCharWrapping];
                
                //ふぁぼられイベント用
                if ( [_tweet objectForKey:@"FavEvent"] != nil ) {
                    
                    NSString *temp = [NSString stringWithString:infoLabelText];
                    infoLabelText = [NSString stringWithFormat:@"【%@がお気に入りに追加】",
                                     [_tweet objectForKey:@"addUser"]];
                    
                    text = [NSString stringWithFormat:@"%@\n%@", temp, text];
                    contentsHeight = [text heightForContents:[UIFont systemFontOfSize:12.0]
                                                     toWidht:210
                                                   minHeight:31
                                               lineBreakMode:NSLineBreakByCharWrapping];
                }
                
                //セルへの反映開始
                cell.infoLabel.text = [NSString stringWithString:infoLabelText];
                cell.infoLabel.textColor = [self getTextColor:[_tweet integerForKey:@"text_color"]];
                
                NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
                [mainText setFont:[UIFont systemFontOfSize:12]];
                [mainText setTextColor:[self getTextColor:[_tweet integerForKey:@"text_color"]] range:NSMakeRange(0, text.length)];
                [mainText setTextAlignment:kCTLeftTextAlignment
                             lineBreakMode:kCTLineBreakByCharWrapping
                             maxLineHeight:14.0
                             minLineHeight:14.0
                            maxLineSpacing:1.0
                            minLineSpacing:1.0
                                     range:NSMakeRange(0, mainText.length)];
                cell.mainLabel.attributedText = mainText;
                
                //セルの高さを設定
                cell.mainLabel.frame = CGRectMake(54, 19, 210, contentsHeight);
            }
            
            return cell;
        }
        
    }else {
        
        TimelineMenuCell *cell = (TimelineMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"TimelineMenuCell"];
        
        if ( cell == nil ) {
            
            cell = [[TimelineMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"TimelineMenuCell"];
        }
        
        cell.textLabel.text = [_menuList objectAtIndex:indexPath.row];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.row == 0 ) {
        
        if ( [_tweet objectForKey:@"FavEvent"] != nil ) {
            
            return [[NSString stringWithFormat:@"【%@がお気に入りに追加】\n%@",
                     [_tweet objectForKey:@"addUser"],
                     [_tweet objectForKey:@"text"]]
                    heightForContents:[UIFont systemFontOfSize:12]
                    toWidht:210
                    minHeight:31
                    lineBreakMode:NSLineBreakByCharWrapping] + 25;
        }
        
        return [[_tweet objectForKey:@"text"] heightForContents:[UIFont systemFontOfSize:12]
                                                        toWidht:210
                                                      minHeight:31
                                                  lineBreakMode:NSLineBreakByCharWrapping] + 25;
        
    }else {
        
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath[%d]: %d", _menuNo, indexPath.row);
    
    if ( indexPath.row != 0 ) {
        
        if ( _menuNo == 0 ) {
            
            if ( indexPath.row == 10 ) {
                
                self.nextMenuList = [NSMutableArray arrayWithArray:COPY_MENU];
                [_nextMenuList insertObject:[NSDictionary dictionaryWithDictionary:_tweet]
                                    atIndex:0];
                _count = 0;
                [_topBar setItems:@[_backButton, _space, _cancelButton]
                         animated:YES];
                
                [self startRemoveAllTimer];
                
            }else if ( indexPath.row == 13 ) {
                
                self.nextMenuList = [NSMutableArray arrayWithArray:USER_MENU];
                [_nextMenuList insertObject:[NSDictionary dictionaryWithDictionary:_tweet]
                                    atIndex:0];
                
                _count = 0;
                [_topBar setItems:@[_backButton, _space, _cancelButton]
                         animated:YES];
                [self startRemoveAllTimer];
                
            }else {
                
                [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuAction"
                                                       withUserInfo:@{@"Action":@(indexPath.row - 1),
                 @"Type":@"Main"}];
            }
            
        }else if ( _menuNo == 1 ) {
            
            [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuAction"
                                                   withUserInfo:@{@"Action":@(indexPath.row - 1),
             @"Type":@"Copy"}];
            
        }else if ( _menuNo == 2 ) {
            
            if ( indexPath.row != 8 ) {
                
                _userMenuActionNo = indexPath.row - 1;
                
                //ユーザー選択
                NSString *text = [_tweet objectForKey:@"text"];
                
                if ( [[_tweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                    
                    text = [TWEntities openTcoWithReTweet:_tweet];
                }
                
                NSString *screenName = [NSString stringWithFormat:@"@%@", [[_tweet objectForKey:@"user"] objectForKey:@"screen_name"]];
                NSMutableArray *users = [text twitterIds];
                [users insertObject:[NSString stringWithString:screenName]
                            atIndex:0];
                screenName = nil;
                
                _nextMenuList = [NSMutableArray arrayWithArray:users.deleteDuplicate];
                users = nil;
                text = nil;
                
                if ( _nextMenuList.count == 1 ) {
                    
                    _selectUser = [NSString stringWithString:[_nextMenuList objectAtIndex:0]];
                    
                    if ( [_selectUser hasPrefix:@"@"] ) _selectUser = [_selectUser substringFromIndex:1];
                    
                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuAction"
                                                           withUserInfo:@{@"Action":@(_userMenuActionNo),
                     @"Type":@"User",
                     @"TargetUser":_selectUser}];
                    
                }else {
                    
                    [_nextMenuList insertObject:_tweet atIndex:0];
                    _count = 0;
                    _menuNo = 3;
                    _menuTable.userInteractionEnabled = NO;
                    [_topBar setItems:@[_backButton, _space, _cancelButton] animated:YES];
                    [self startRemoveAllTimer];
                }
                
            }else {
                
                self.selectUser = @"";
                self.nextMenuList = [NSMutableArray arrayWithArray:FORROW_MENU];
                [_nextMenuList insertObject:_tweet atIndex:0];
                _count = 0;
                _menuNo = 4;
                _menuTable.userInteractionEnabled = NO;
                [_topBar setItems:@[_backButton, _space, _cancelButton] animated:YES];
                [self startRemoveAllTimer];
            }
            
        }else if ( _menuNo == 3 ) {
            
            [_menuList removeObjectAtIndex:0];
            
            if ( [[_menuList objectAtIndex:indexPath.row - 1] isKindOfClass:[NSDictionary class]] ) {
                
                if ( [[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                    
                    _selectUser = [[[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
                    
                }else {
                    
                    _selectUser = [[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"user"] objectForKey:@"screen_name"];
                }
                
            }else {
                
                _selectUser = [NSString stringWithString:[_menuList objectAtIndex:indexPath.row - 1]];
            }
            
            if ( [_selectUser hasPrefix:@"@"] ) _selectUser = [_selectUser substringFromIndex:1];
            
            NSLog(@"selectUser[%d]: %@, index: %d", _userMenuActionNo, _selectUser, indexPath.row - 1);
            [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuAction"
                                                   withUserInfo:@{@"Action":@(_userMenuActionNo),
             @"Type":@"User",
             @"TargetUser":_selectUser}];
            
        }else if ( _menuNo == 4 ) {
            
            [_menuList removeObjectAtIndex:0];
            
            if ( [[_menuList objectAtIndex:indexPath.row - 1] isKindOfClass:[NSDictionary class]] ) {
                
                if ( [[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                    
                    _selectUser = [[[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
                    
                }else {
                    
                    _selectUser = [[[_menuList objectAtIndex:indexPath.row - 1] objectForKey:@"user"] objectForKey:@"screen_name"];
                }
                
            }else {
                
                _selectUser = [NSString stringWithString:[_menuList objectAtIndex:indexPath.row - 1]];
            }
            
            if ( [_selectUser hasPrefix:@"@"] ) _selectUser = [_selectUser substringFromIndex:1];
            
            if ( indexPath.row == 0 ) {
                
                //スパム報告
                [TWFriends reportSpam:_selectUser];
                
            }else if ( indexPath.row == 1 ) {
                
                //ブロック
                [TWFriends block:_selectUser];
                
            }else if ( indexPath.row == 2 ) {
                
                //ブロック解除
                [TWFriends unblock:_selectUser];
                
            }else if ( indexPath.row == 3 ) {
                
                //フォロー
                [TWFriends follow:_selectUser];
                
            }else if ( indexPath.row == 4 ) {
                
                //フォロー解除
                [TWFriends unfollow:_selectUser];
            }
            
            self.selectUser = nil;
            [self pushCancelButton];
        }
        
        if ( _menuNo == 0 ) {
            //メインメニュー
            if ( indexPath.row == 10 ) {
                //コピーメニュー
                _menuNo = 1;
            }else if ( indexPath.row == 13 ) {
                //ユーザーメニュー
                _menuNo = 2;
            }else {
                //それ以外
                _menuNo = 0;
            }
        }
    }
}

- (UIColor *)getTextColor:(CellTextColor)color {
    
    if ( color == CellTextColorBlack ) return BLACK_COLOR;
    if ( color == CellTextColorRed )   return RED_COLOR;
    if ( color == CellTextColorBlue )  return BLUE_COLOR;
    if ( color == CellTextColorGreen ) return GREEN_COLOR;
    if ( color == CellTextColorGold )  return GOLD_COLOR;
    
    return BLACK_COLOR;
}

- (void)pushCancelButton {
    
    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuCanceled"];
}

- (void)pushBackButton {
    
    _menuNo = 0;
    _count = 0;
    _userMenuActionNo = 0;
    _selectUser = nil;
    _menuTable.userInteractionEnabled = NO;
    
    self.nextMenuList = [NSMutableArray arrayWithArray:MAIN_MENU];
    [_nextMenuList insertObject:[NSDictionary dictionaryWithDictionary:_tweet]
                        atIndex:0];
    [_topBar setItems:@[_space, _cancelButton]
             animated:YES];
    
    [self startRemoveAllTimer];
}

- (void)startRemoveAllTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.04
                                              target:self
                                            selector:@selector(removeAllItems)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];
}

- (void)removeAllItems {
    
    [_timer invalidate];
    
    if ( _menuList.count != 0 ) {
        
        __weak TimelineMenu *wself = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wself.menuList removeObjectAtIndex:0];
            [wself.menuTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                   withRowAnimation:UITableViewRowAnimationLeft];
            [wself startRemoveAllTimer];
        });
        
    }else {
        
        [self addNewListItems];
    }
}

- (void)addNewListItems {
    
    if ( _count < _nextMenuList.count ) {
        
        __weak TimelineMenu *wself = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wself.menuList addObject:[wself.nextMenuList objectAtIndex:wself.count]];
            [wself.menuTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:wself.count inSection:0]]
                                   withRowAnimation:UITableViewRowAnimationRight];
            wself.count++;
            
            dispatch_after(DELAY_TIME(0.04) ^{
                
                if ( wself.count < wself.nextMenuList.count ) {
                    
                    [wself addNewListItems];
                    
                }else {
                    
                    wself.menuTable.userInteractionEnabled = YES;
                }
            });
        });
    }
}

- (void)dealloc {
    
    //    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.menuTable.delegate = nil;
    self.menuTable.dataSource = nil;
    [_topBar removeFromSuperview];
    [_menuTable removeFromSuperview];
}

@end
