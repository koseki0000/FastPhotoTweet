//
//  TimelineMenu.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import "TimelineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Share.h"
#import "TimelineAttributedRTCell.h"
#import "TimelineAttributedCell.h"
#import "IconButton.h"
#import "TimelineMenu.h"
#import "TimelineMenuCell.h"
#import "NSDictionary+DataExtraction.h"
#import "NSString+Calculator.h"
#import "NSString+RegularExpression.h"
#import "NSArrayAdditions.h"
#import "TWFriends.h"
#import "TWEvent.h"
#import "TWTweets.h"
#import "InputAlertView.h"
#import "NSAttributedString+Attributes.h"

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define P_BOARD [UIPasteboard generalPasteboard]

#define DELAY_TIME(x) dispatch_time(DISPATCH_TIME_NOW, x * NSEC_PER_SEC), dispatch_get_main_queue(),

#define CELL_IDENTIFIER @"TimelineAttributedCell"
#define RT_CELL_IDENTIFIER @"TimelineAttributedRTCell"

#define MAIN_MENU @[@"Reply", @"Favorite／UnFavorite", @"ReTweet", @"Fav+RT", @"IDとFav,RTを選択", @"ハッシュタグをNG", @"クライアントをNG", @"InReplyTo", @"Tweetをコピー", @"Tweetを削除", @"Tweetを編集", @"ユーザーメニュー"]
#define COPY_MENU @[@"STOT形式", @"本文", @"TweetへのURL", @"Tweet内のURL"]
#define USER_MENU @[@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", @"フォロー関連"]
#define FORROW_MENU @[@"スパム報告", @"ブロック", @"ブロック解除", @"フォロー", @"フォロー解除"]

#define MENU_CLOSE_TIME 0.4

@implementation TimelineMenu

- (id)initWithTweet:(TWTweet *)tweet forMenu:(TimeLineMenuIdentifier)menuIdentifier  controller:(TimelineViewController *)controller {
    
    self = [super initWithFrame:CGRectMake(0,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT,
                                           266,
                                           SCREEN_HEIGHT - TAB_BAR_HEIGHT)];
    self.backgroundColor = [UIColor whiteColor];
    
    [self setController:controller];
    
    if ( menuIdentifier == TimeLineMenuIdentifierMain ) {
        
        self.menuList = [NSMutableArray arrayWithArray:MAIN_MENU];
        
    }else if ( menuIdentifier == TimeLineMenuIdentifierCopy ) {
        
        self.menuList = [NSMutableArray arrayWithArray:COPY_MENU];
        
    }else if ( menuIdentifier == TimeLineMenuIdentifierUser ) {
        
        self.menuList = [NSMutableArray arrayWithArray:USER_MENU];
    }
    
    self.tweet = tweet;
    [_menuList insertObject:_tweet
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
        
        if ( _tweet.isReTweet ) {
            
            //公式RT
            TimelineAttributedRTCell *cell = (TimelineAttributedRTCell *)[tableView dequeueReusableCellWithIdentifier:RT_CELL_IDENTIFIER];
            
            @autoreleasepool {
                
                if ( cell == nil ) {
                    
                    cell = [[TimelineAttributedRTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:RT_CELL_IDENTIFIER
                                                                  forWidth:210.0f];
                }
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [cell setTweetData:self.tweet
                             cellWidth:210.0f];
                });
            }
            
            return cell;
            
        }else {
            
            TimelineAttributedCell *cell = (TimelineAttributedCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
            
            @autoreleasepool {
                
                if ( cell == nil ) {
                    
                    cell = [[TimelineAttributedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CELL_IDENTIFIER
                                                                forWidth:210.0f];
                }
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [cell setTweetData:self.tweet
                             cellWidth:210.0f];
                });
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
        
        if ( [cell.textLabel.text isEqualToString:@"Tweetを削除"]) {
            
            if (  _tweet.isReTweet &&
                 [_tweet.rtUserName isEqualToString:[TWAccounts currentAccountName]] ) {
                
                cell.textLabel.text = @"ReTweetを取り消す";
            }
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.row == 0 ) {
        
        return [_tweet.text heightForContents:[UIFont systemFontOfSize:12.0f]
                                      toWidht:210.0f
                                    minHeight:31.0f
                                lineBreakMode:NSLineBreakByCharWrapping] + 25.0f;
        
    }else {
        
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath[%d]: %d", _menuNo, indexPath.row);
    
    if ( indexPath.row != 0 ) {
        
        if ( _menuNo == 0 ) {
            
            if ( indexPath.row == 9 ) {
                
                self.nextMenuList = [NSMutableArray arrayWithArray:COPY_MENU];
                [_nextMenuList insertObject:_tweet
                                    atIndex:0];
                _count = 0;
                [_topBar setItems:@[_backButton, _space, _cancelButton]
                         animated:YES];
                
                [self startRemoveAllTimer];
                
            }else if ( indexPath.row == 12 ) {
                
                self.nextMenuList = [NSMutableArray arrayWithArray:USER_MENU];
                [_nextMenuList insertObject:_tweet
                                    atIndex:0];
                
                _count = 0;
                [_topBar setItems:@[_backButton, _space, _cancelButton]
                         animated:YES];
                [self startRemoveAllTimer];
                
            }else {
                
                NSInteger index = indexPath.row - 1;
                
                if ( index == MainMenuReply ) {
                    
                    //Reply
                    DISPATCH_AFTER(MENU_CLOSE_TIME) ^{
                        ASYNC_MAIN_QUEUE ^{
                            
                            NSString *screenName = self.tweet.screenName;
                            NSString *inReplyToId = self.tweet.tweetID;
                            
                            if ( screenName == nil ||
                                 inReplyToId == nil ) return;
                            
                            [[TWTweets manager] setText:screenName];
                            [[TWTweets manager] setInReplyToID:inReplyToId];
                            [[TWTweets manager] setTabChangeFunction:@"Reply"];
                            APP_DELEGATE.tabBarController.selectedIndex = 0;
                        });
                    });
                
                }else if ( index == MainMenuFav ) {
                    
                    //Fav UnFav
                    NSString *tweetId = _tweet.tweetID;
                    BOOL favorited = _tweet.isFavorited;
                    
                    if ( favorited ) {
                        
                        [TWEvent unFavorite:tweetId
                               accountIndex:[D integerForKey:@"UseAccount"]];
                        
                    }else {
                        
                        [TWEvent favorite:tweetId
                             accountIndex:[D integerForKey:@"UseAccount"]];
                    }
                    
                }else if ( index == MainMenuRT ) {
                    
                    //RT
                    NSString *tweetId = _tweet.tweetID;
                    [TWEvent reTweet:tweetId
                        accountIndex:[D integerForKey:@"UseAccount"]];
                    
                }else if ( index == MainMenuFavRT ) {
                    
                    //Fav RT
                    NSString *tweetId = _tweet.tweetID;
                    [TWEvent favoriteReTweet:tweetId
                                accountIndex:[D integerForKey:@"UseAccount"]];
                    
                }else if ( index == MainMenuSeleceID ) {
                    
                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuSelectID"];
                    
                }else if ( index == MainMenuHashTagNG ) {
                
                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuHashTagNG"];
                    
                }else if ( index == MainMenuClientNG ) {
                
                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuClientNG"];
                    
                }else if ( index == MainMenuInReplyTo ) {

                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuInReplyTo"];
                    
                }else if ( index == MainMenuDelete ) {

                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDelete"];
                    
                }else if ( index == MainMenuEdit ) {

                    DISPATCH_AFTER(MENU_CLOSE_TIME) ^{
                        ASYNC_MAIN_QUEUE ^{
                            
                            NSString *text = self.tweet.text;
                            NSString *inReplyToId = self.tweet.tweetID;
                            
                            if ( text == nil ||
                                 inReplyToId == nil ) return;
                            
                            [[TWTweets manager] setText:text];
                            [[TWTweets manager] setInReplyToID:inReplyToId];
                            [[TWTweets manager] setTabChangeFunction:@"Edit"];
                            APP_DELEGATE.tabBarController.selectedIndex = 0;
                            
                            [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDelete"];
                        });
                    });
                }
                
                [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
            }
            
        }else if ( _menuNo == 1 ) {
            
            NSString *tweetId = _tweet.tweetID;
            NSString *screenName = _tweet.screenName;
            
            NSString *text = nil;
            
            if ( _tweet.isReTweet ) {
            
                text = _tweet.originalText;
                
            }else {
            
                text = _tweet.text;
            }
            
            NSString *copyText = nil;
            
            if ( indexPath.row == 1 ) {
                
                copyText = [[NSString alloc] initWithFormat:@"%@: %@ [https://twitter.com/%@/status/%@]",
                            screenName,
                            text,
                            screenName,
                            tweetId];
                
            }else if ( indexPath.row == 2 ) {
                
                copyText = [NSMutableString stringWithString:text];
                
            }else if ( indexPath.row == 3 ) {
                
                copyText = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@",
                            screenName,
                            tweetId];
                
            }else if ( indexPath.row == 4 ) {
                
                self.nextMenuList = [NSMutableArray arrayWithArray:[text URLs]];
                
                if ( [_nextMenuList count] != 0 ) {
                 
                    [_nextMenuList insertObject:_tweet atIndex:0];
                    self.count = 0;
                    self.menuNo = 5;
                    self.menuTable.userInteractionEnabled = NO;
                    [self startRemoveAllTimer];
                    
                }else {
                    
                    [ShowAlert error:@"URLがありません。"];
                }
            }
            
            if ( indexPath.row != 4 ) {
                
                [P_BOARD setString:copyText];
                [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
            }
            
            tweetId = nil;
            screenName = nil;
            text = nil;
            copyText = nil;
            
        }else if ( _menuNo == 2 ) {
            
            if ( indexPath.row != 8 ) {
                
                /////////////
                _userMenuActionNo = indexPath.row ;
                
                //ユーザー選択
                NSString *text = _tweet.text;
                
                NSString *screenName = [NSString stringWithFormat:@"@%@", _tweet.screenName];
                NSMutableArray *users = [text twitterIDs];
                [users insertObject:[NSString stringWithString:screenName]
                            atIndex:0];
                screenName = nil;
                
                _nextMenuList = [NSMutableArray arrayWithArray:users.deleteDuplicate];
                users = nil;
                text = nil;
                
                if ( _nextMenuList.count == 1 ) {
                    
                    _selectUser = [NSString stringWithString:[_nextMenuList objectAtIndex:0]];
                    
                    if ( [_selectUser hasPrefix:@"@"] ) {
                     
                        _selectUser = [_selectUser substringFromIndex:1];
                    }
                    
                    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
                    
                    DISPATCH_AFTER(MENU_CLOSE_TIME) ^{
                        
                        [self openUserMenu:self.selectUser
                                 menuIndex:indexPath.row];
                    });
                    
                }else {
                    
                    [_nextMenuList insertObject:_tweet atIndex:0];
                    _count = 0;
                    _menuNo = 3;
                    _menuTable.userInteractionEnabled = NO;
                    [_topBar setItems:@[_backButton, _space, _cancelButton] animated:YES];
                    [self startRemoveAllTimer];
                }
                /////////////
                
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
            
            if ( [[_menuList objectAtIndex:indexPath.row] isKindOfClass:[TWTweet class]] ) {
                
                TWTweet *currentTweet = [_menuList objectAtIndex:indexPath.row];
                
                self.selectUser = currentTweet.screenName;
                
            }else {
                
                self.selectUser = [_menuList objectAtIndex:indexPath.row];
            }
            
            if ( [_selectUser hasPrefix:@"@"] ) {
            
                _selectUser = [_selectUser substringFromIndex:1];
            }

            [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
            
            DISPATCH_AFTER(MENU_CLOSE_TIME) ^{
                
                [self openUserMenu:self.selectUser
                         menuIndex:self.userMenuActionNo];
            });
            
        }else if ( _menuNo == 4 ) {
            
            if ( [_menuList[0] isKindOfClass:[TWTweet class]] ) {
                
                TWTweet *currentTweet = [_menuList objectAtIndex:0];
                
                self.selectUser = currentTweet.screenName;
                
            }else {
                
                self.selectUser = [NSString stringWithString:[_menuList objectAtIndex:0]];
            }
            
            [_menuList removeObjectAtIndex:0];
            
            if ( [_selectUser hasPrefix:@"@"] ) self.selectUser = [_selectUser substringFromIndex:1];
            
            if ( indexPath.row == 1 ) {
                
                //スパム報告
                [TWFriends reportSpam:_selectUser];
                
            }else if ( indexPath.row == 2 ) {
                
                //ブロック
                [TWFriends block:_selectUser];
                
            }else if ( indexPath.row == 3 ) {
                
                //ブロック解除
                [TWFriends unblock:_selectUser];
                
            }else if ( indexPath.row == 4 ) {
                
                //フォロー
                [TWFriends follow:_selectUser];
                
            }else if ( indexPath.row == 5 ) {
                
                //フォロー解除
                [TWFriends unfollow:_selectUser];
            }
            
            self.selectUser = nil;
            [self pushCancelButton];
        
        }else if ( _menuNo == 5 ) {
            
            [P_BOARD setString:_nextMenuList[indexPath.row]];
            [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
        }
        
        if ( _menuNo == 0 ) {
            //メインメニュー
            if ( indexPath.row == 9 ) {
                //コピーメニュー
                _menuNo = 1;
            }else if ( indexPath.row == 12 ) {
                //ユーザーメニュー
                _menuNo = 2;
            }else {
                //それ以外
                _menuNo = 0;
            }
        }
    }
}

- (void)pushCancelButton {
    
    [NSNotificationCenter postNotificationCenterForName:@"TimelineMenuDone"];
}

- (void)pushBackButton {
    
    _menuNo = 0;
    _count = 0;
    _userMenuActionNo = 0;
    _selectUser = nil;
    _menuTable.userInteractionEnabled = NO;
    
    self.nextMenuList = [NSMutableArray arrayWithArray:MAIN_MENU];
    [_nextMenuList insertObject:_tweet
                        atIndex:0];
    [_topBar setItems:@[_space, _cancelButton]
             animated:YES];
    
    [self startRemoveAllTimer];
}

- (void)openUserMenu:(NSString *)screenName menuIndex:(NSInteger)menuIndex {
 
    if ( menuIndex == 1 ) {
        
        [self.controller openTwilog:self.tweet.screenName];
        
    }else if ( menuIndex == 2 ) {
        
        InputAlertView *alert = [[InputAlertView alloc] initWithTitle:@"TwilogSearch"
                                                             delegate:self.controller
                                                    cancelButtonTitle:@"キャンセル"
                                                      doneButtonTitle:@"確定"
                                                    isMultiInputField:YES
                                                           doneAction:@selector(openTwilogSearch:searchWord:)];
        [alert.multiTextFieldTop setPlaceholder:@"ScreenName"];
        [alert.multiTextFieldTop setText:screenName];
        [alert.multiTextFieldBottom setPlaceholder:@"SearchWord"];
        [alert show];
        [alert.multiTextFieldBottom becomeFirstResponder];
        
    }else if ( menuIndex == 3 ) {
        
        [self.controller openFavStar:screenName];
        
    }else if ( menuIndex == 4 ) {
        
        [self.controller openTwitPic:screenName];
        
    }else if ( menuIndex == 5 ) {
        
        [self.controller requestUserTimeline:screenName];
        
    }else if ( menuIndex == 6 ) {
        
        
        
    }else if ( menuIndex == 7 ) {
        
        self.selectUser = @"";
        self.nextMenuList = [NSMutableArray arrayWithArray:FORROW_MENU];
        [_nextMenuList insertObject:_tweet atIndex:0];
        _count = 0;
        _menuNo = 4;
        _menuTable.userInteractionEnabled = NO;
        [_topBar setItems:@[_backButton, _space, _cancelButton] animated:YES];
        [self startRemoveAllTimer];
    }
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
