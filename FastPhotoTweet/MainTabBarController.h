//
//  MainTabBarController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/22.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController {
    
    BOOL hiddenTabBar;
    BOOL orientation;
}

- (void)setBarHidden:(BOOL)hidden;
- (void)endHidden;

- (void)enableOrientation;
- (void)disableOrientation;

@end
