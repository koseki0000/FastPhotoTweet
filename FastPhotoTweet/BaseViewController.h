//
//  BaseViewController.h
//  AmznCal 2
//
//  Created by @peace3884 on 2013/03/17.
//  Copyright (c) 2013年 @peace3884. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FILE_MANAGER [NSFileManager defaultManager]
#define ICONS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Icons"]
#define LOGS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Logs"]
#define FILE_PATH [ICONS_DIRECTORY stringByAppendingPathComponent:searchName]

@interface BaseViewController : UIViewController

- (void)showModalViewController:(UIViewController *)modalViewController;
- (void)dismissModalViewController:(UIViewController *)modalViewController;

- (BOOL)iconExist:(NSString *)searchName;

- (void)addTackNotification:(NSString *)text;

@end
