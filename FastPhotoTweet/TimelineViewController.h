//
//  TimelineViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TimelineViewController : BaseViewController

- (void)requestUserTimeline:(NSString *)screenName;
- (void)requestSearch:(NSString *)searchWord;

- (void)openTwilog:(NSString *)userName;
- (void)openTwilogSearch:(NSString *)userName searchWord:(NSString *)searchWord;
- (void)openFavStar:(NSString *)userName;
- (void)openTwitPic:(NSString *)userName;

@end