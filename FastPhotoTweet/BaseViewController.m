//
//  BaseViewController.m
//  AmznCal 2
//
//  Created by @peace3884 on 2013/03/17.
//  Copyright (c) 2013年 @peace3884. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)showModalViewController:(UIViewController *)modalViewController {
    
    if ( [self respondsToSelector:@selector(presentViewController:animated:completion:)] ) {
        
        [self presentViewController:modalViewController
                           animated:YES
                         completion:nil];
        
    } else {
        
        [self presentModalViewController:modalViewController
                                animated:YES];
    }
}

- (void)dismissModalViewController:(UIViewController *)modalViewController {
    
    if ( [modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)] ) {
        
        [modalViewController dismissViewControllerAnimated:YES
                                                completion:nil];
        
    } else {
        
        [modalViewController dismissModalViewControllerAnimated:YES];
    }
}

- (BOOL)iconExist:(NSString *)searchName {
    
    BOOL isDir = NO;
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:FILE_PATH
                                              isDirectory:&isDir] && !isDir ) isDir = YES;
    
    return isDir;
}

- (void)addTackNotification:(NSString *)text {
    
    NSNotification *notification = [NSNotification notificationWithName:@"AddStatusBarTask"
                                                                 object:self
                                                               userInfo:@{@"Task" : text}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
