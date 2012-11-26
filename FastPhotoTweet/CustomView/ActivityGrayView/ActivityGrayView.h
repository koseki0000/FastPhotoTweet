//
//  GrayView.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//

#import <UIKit/UIView.h>
#import <UIKit/UIActivityIndicatorView.h>
#import <QuartzCore/QuartzCore.h>

@interface ActivityGrayView : UIView

@property (retain, nonatomic) UIView *grayView;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSString *taskName;
@property NSInteger startCount;

+ (ActivityGrayView *)grayView;
+ (ActivityGrayView *)grayViewWithTaskName:(NSString *)taskName;

- (void)setDefault;

- (void)addTaskName:(NSString *)taskName;
- (void)start;
- (void)end;
- (void)forceEnd;

@end
