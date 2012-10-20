//
//  GrayView.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//

#import <UIKit/UIView.h>
#import <UIKit/UIActivityIndicatorView.h>
#import <QuartzCore/QuartzCore.h>

@interface ActivityGrayView : UIView {
    
    UIView *_grayView;
    UIActivityIndicatorView *_activityIndicator;
    
    NSInteger _startCount;
}

@property (retain, nonatomic) NSString *taskName;

+ (ActivityGrayView *)grayView;
+ (ActivityGrayView *)grayViewWithTaskName:(NSString *)taskName;

- (void)setDefault;

- (void)addTaskName:(NSString *)taskName;
- (void)start;
- (void)end;
- (void)forceEnd;

@end
