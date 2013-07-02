//
//  TimelineAttributedRTCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/18.
//
//

#import <QuartzCore/QuartzCore.h>
#import "TimelineAttributedRTCell.h"
#import "NSAttributedString+Attributes.h"
#import "NSDictionary+DataExtraction.h"
#import "Share.h"

#define MIN_HEIGHT 31.0f
#define ICON_SIZE 48.0f
#define MARGIN 4.0f
#define HALF_MARGIN 2.0f

@implementation TimelineAttributedRTCell

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t location = 2;
    CGFloat locations[2] =  {0.0f, 1.0f};
    CGFloat components[8] = {1.0f,  1.0f,  1.0f, 1.0f, 0.92f, 0.92f, 0.92f, 1.0f};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =   CGGradientCreateWithColorComponents(colorSpace, components, locations, location);
    
    CGPoint startPoint = CGPointMake(self.frame.size.width / 2.0f, 0.0f);
    CGPoint endPoint =   CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forWidth:(CGFloat)width {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        
        [self setProperties:width];
    }
    
    return self;
}

- (void)setProperties:(CGFloat)width {
    
    self.infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(54.0f,
                                                                2.0f,
                                                                width,
                                                                14.0f)] autorelease];
    self.mainLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(54.0f,
                                                                          19.0f,
                                                                          width,
                                                                          31.0f)] autorelease];
    self.iconView = [[[IconButton alloc] initWithFrame:CGRectMake(2.0f,
                                                                  4.0f,
                                                                  48.0f,
                                                                  54.0f)] autorelease];
    
    _infoLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    
    _infoLabel.textColor = [UIColor colorWithRed:0.0f green:0.4f blue:0.0f alpha:1.0f];
    _mainLabel.textColor = [UIColor colorWithRed:0.0f green:0.4f blue:0.0f alpha:1.0f];
    
    _infoLabel.backgroundColor = [UIColor clearColor];
    _mainLabel.backgroundColor = [UIColor clearColor];
    
    _mainLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
    [_mainLabel setUnderlineLinks:YES];
    
    self.userIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 34.0f, 34.0f)] autorelease];
    [self.userIconView setContentMode:UIViewContentModeScaleAspectFill];
    [self.iconView addSubview:self.userIconView];
    
    self.rtUserIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 25.0f, 28.0f, 28.0f)] autorelease];
    [self.rtUserIconView setContentMode:UIViewContentModeScaleAspectFill];
    [self.iconView addSubview:self.rtUserIconView];
    
    self.arrowView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 34.0f, 20.0f, 19.0f)] autorelease];
    [self.arrowView setContentMode:UIViewContentModeScaleAspectFit];
    [self.arrowView setImage:[UIImage imageNamed:@"retweet_arrow"]];
    [self.arrowView setBackgroundColor:[UIColor grayColor]];
    [self.iconView addSubview:self.arrowView];
    
    if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"IconCornerRounding"] == 1 ) {
        
        //角を丸める
        [self.userIconView.layer setCornerRadius:4.0f];
        [self.rtUserIconView.layer setCornerRadius:4.0f];
        [self.arrowView.layer setCornerRadius:3.0f];
    }
    
    [self.userIconView.layer setMasksToBounds:YES];
    [self.rtUserIconView.layer setMasksToBounds:YES];
    [self.arrowView.layer setMasksToBounds:YES];
    
    [self addSubview:_infoLabel];
    [self addSubview:_mainLabel];
    [self addSubview:_iconView];
}

- (void)setTweetData:(TWTweet *)tweet cellWidth:(CGFloat)cellWidth {
    
    //Tweetの本文
    NSString *text = tweet.text;
    NSString *screenName = tweet.screenName;
    NSString *userName = tweet.rtUserName;
    [self.iconView setTargetTweet:tweet];
    NSString *infoLabelText = tweet.infoText;
    CGFloat contentsHeight = tweet.cellHeight;
    
    NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
    [mainText setFont:[UIFont systemFontOfSize:12.0f]];
    [mainText setTextColor:GREEN_COLOR range:NSMakeRange(0.0f,
                                                         text.length)];
    [mainText setTextAlignment:kCTLeftTextAlignment
                 lineBreakMode:kCTLineBreakByCharWrapping
                 maxLineHeight:14.0f
                 minLineHeight:14.0f
                maxLineSpacing:1.0f
                minLineSpacing:1.0f
                         range:NSMakeRange(0.0f,
                                           mainText.length)];
    
    //セルへの反映開始
    [self.infoLabel setText:infoLabelText];
    [self.mainLabel setAttributedText:mainText];
    [self.mainLabel setFrame:CGRectMake(54.0f,
                                        19.0f,
                                        cellWidth,
                                        contentsHeight)];
    
    if ( [[Share images] objectForKey:screenName] != nil &&
         self.iconView.layer.sublayers.count != 0 ) {
        
        [self.userIconView setImage:[[Share images] imageForKey:screenName]];
        
    } else {
        
        [self.userIconView setImage:nil];
    }
    
    if ( [[Share images] objectForKey:userName] != nil &&
         self.iconView.layer.sublayers.count != 0 ) {
        
        [self.rtUserIconView setImage:[[Share images] imageForKey:userName]];
        
    } else {
        
        [self.rtUserIconView setImage:nil];
    }
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    
    _iconView.layer.sublayers = nil;
    [_iconView release];
    _iconView = nil;
    [_infoLabel release];
    _infoLabel = nil;
    [_mainLabel release];
    _mainLabel = nil;
    [super dealloc];
}

@end