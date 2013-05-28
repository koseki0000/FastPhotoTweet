//
//  TimelineAttributedCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//
//

#import <QuartzCore/QuartzCore.h>
#import "TimelineAttributedCell.h"
#import "NSAttributedString+Attributes.h"
#import "NSDictionary+DataExtraction.h"
#import "NSString+Calculator.h"
#import "Share.h"

static NSInteger const kAttributedLabelTag = 100;

@interface TimelineAttributedCell ()

- (void)reloadViews:(NSString *)screenName;

@end

@implementation TimelineAttributedCell

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
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        
        [self setProperties:width];
    }
    
    return self;
}

- (void)setProperties:(CGFloat)width {
    
    self.infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(54.0f, 2.0f,  width, 14.0f)] autorelease];
    self.mainLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(54.0f, 19.0f, width, 31.0f)] autorelease];
    self.iconView = [[[IconButton alloc] initWithFrame:CGRectMake(2.0f, 4.0f, 48.0f, 48.0f)] autorelease];
    [self.iconView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.infoLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
    
    [self.infoLabel setBackgroundColor:[UIColor clearColor]];
    [self.mainLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.mainLabel setAutomaticallyAddLinksForType:NSTextCheckingTypeLink];
    [self.mainLabel setUnderlineLinks:YES];
    [self.mainLabel setExtendBottomToFit:YES];
    
    [self.iconView.titleLabel removeFromSuperview];
    [self.iconView.inputAccessoryView removeFromSuperview];
    [self.iconView.inputView removeFromSuperview];
    [self.infoLabel.inputAccessoryView removeFromSuperview];
    [self.infoLabel.inputView removeFromSuperview];
    
    [self.mainLabel.inputAccessoryView removeFromSuperview];
    [self.mainLabel.inputView removeFromSuperview];
    
    [self.accessoryView removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self.detailTextLabel removeFromSuperview];
    [self.textLabel removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self.editingAccessoryView removeFromSuperview];
    [self.inputAccessoryView removeFromSuperview];
    [self.inputView removeFromSuperview];
    [self.multipleSelectionBackgroundView removeFromSuperview];
    [self.selectedBackgroundView removeFromSuperview];
    
    if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"IconCornerRounding"] == 1 ) {
        
        //角を丸める
        [self.iconView.layer setCornerRadius:6.0f];
    }
    
    [self.iconView.layer setMasksToBounds:YES];
    
    [self addSubview:self.infoLabel];
    [self addSubview:self.mainLabel];
    [self addSubview:self.iconView];
}

- (void)setTweetData:(TWTweet *)tweet cellWidth:(CGFloat)cellWidth {
    
    NSString *text = tweet.text;
    NSString *screenName = tweet.screenName;
    [self.iconView setTargetTweet:tweet];
    NSString *infoLabelText = tweet.infoText;
    CGFloat contentsHeight = tweet.cellHeight;
    
    //ふぁぼられイベント用
    if ( tweet.favoriteEventeType == FavoriteEventTypeReceive ) {
        
        NSString *temp = [NSString stringWithString:infoLabelText];
        infoLabelText = [NSString stringWithFormat:@"【%@がお気に入りに追加】",
                         tweet.favUser];
        
        text = [NSString stringWithFormat:@"%@\n%@", temp, text];
        contentsHeight = [text heightForContents:[UIFont systemFontOfSize:12.0f]
                                         toWidht:cellWidth
                                       minHeight:31.0f
                                   lineBreakMode:NSLineBreakByCharWrapping];
        temp = nil;
    }
    
    NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
    [mainText setFont:[UIFont systemFontOfSize:12.0f]];
    [mainText setTextColor:[TWTweet getTextColor:tweet.textColor]
                     range:NSMakeRange(0.0f,
                                       text.length)];
    [mainText setTextAlignment:kCTLeftTextAlignment
                 lineBreakMode:kCTLineBreakByCharWrapping
                 maxLineHeight:14.0f
                 minLineHeight:14.0f
                maxLineSpacing:1.0f
                minLineSpacing:1.0f
                         range:NSMakeRange(0.0f,
                                           mainText.length)];
    
//    dispatch_queue_t queue;
//    if ( dispatch_get_current_queue() == dispatch_get_main_queue() ) {
//        
//        queue = dispatch_get_current_queue();
//        
//    } else {
//        
//        queue = dispatch_get_main_queue();
//    }
//    
//    dispatch_sync(queue, ^{
    
        //セルへの反映開始
        [self.infoLabel setText:infoLabelText];
        [self.infoLabel setTextColor:[TWTweet getTextColor:tweet.textColor]];
        [self.mainLabel setAttributedText:mainText];
        [self.mainLabel setFrame:CGRectMake(54.0f,
                                            19.0f,
                                            cellWidth,
                                            contentsHeight)];
        [self reloadViews:screenName];
//    });
}

- (void)reloadViews:(NSString *)screenName {
    
    [self resetImage:screenName];
    [self setNeedsDisplay];
    [self.iconView setNeedsDisplay];
    [self.infoLabel setNeedsDisplay];
    [self.mainLabel setNeedsDisplay];
}

- (void)resetImage:(NSString *)screenName {
    
    if ( [[Share images] objectForKey:screenName] != nil ) {
        
        [self.iconView setImage:[[Share images] imageForKey:screenName]
                       forState:UIControlStateNormal];
        
    } else {
        
        [self.iconView setImage:nil
                       forState:UIControlStateNormal];
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