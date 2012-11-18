//
//  TimelineAttributedRTCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/18.
//
//

#import "TimelineAttributedRTCell.h"

static NSInteger const kAttributedLabelTag = 100;

@implementation TimelineAttributedRTCell

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t location = 2;
    CGFloat locations[2] =  {0.0, 1.0};
    CGFloat components[8] = {1.0,  1.0,  1.0, 1.0, 0.92, 0.92, 0.92, 1.0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =   CGGradientCreateWithColorComponents(colorSpace, components, locations, location);
    
    CGPoint startPoint = CGPointMake(self.frame.size.width / 2, 0.0);
    CGPoint endPoint =   CGPointMake(self.frame.size.width / 2, self.frame.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        
        [self setProperties];
    }
    
    return self;
}

- (void)setProperties {
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 2,  264, 14)];
    _mainLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(54, 19, 264, 31)];
    _iconView = [[TitleButton alloc] initWithFrame:CGRectMake(2, 4, 48, 54)];
    
    _infoLabel.font = [UIFont boldSystemFontOfSize:11];
    
    _infoLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    _mainLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    
    _infoLabel.backgroundColor = [UIColor clearColor];
    _mainLabel.backgroundColor = [UIColor clearColor];
    
    _mainLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
    [_mainLabel setUnderlineLinks:YES];
    
    [self.iconView.imageView removeFromSuperview];
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
    
    CALayer *userIconLayer = [[CALayer alloc] init];
    userIconLayer.name = @"UserIcon";
    userIconLayer.frame = CGRectMake(0, 0, 34, 34);
    
    CALayer *rtUserIconLayer = [[CALayer alloc] init];
    rtUserIconLayer.name = @"RTUserIcon";
    rtUserIconLayer.frame = CGRectMake(20, 25, 28, 28);
    
    CALayer *arrowLayer = [[CALayer alloc] init];
    arrowLayer.name = @"Arrow";
    arrowLayer.frame = CGRectMake(0, 34, 20, 19);
    arrowLayer.backgroundColor = [UIColor grayColor].CGColor;
    arrowLayer.contents = (id)[UIImage imageNamed:@"retweet_arrow"].CGImage;
    
    if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"IconCornerRounding"] == 1 ) {
        
        //角を丸める
        [userIconLayer setMasksToBounds:YES];
        [userIconLayer setCornerRadius:5.0f];
        [rtUserIconLayer setMasksToBounds:YES];
        [rtUserIconLayer setCornerRadius:4.0f];
    }
    
    [arrowLayer setMasksToBounds:YES];
    [arrowLayer setCornerRadius:3.0f];
    
    [self.iconView.layer addSublayer:userIconLayer];
    [self.iconView.layer addSublayer:rtUserIconLayer];
    [self.iconView.layer addSublayer:arrowLayer];
    
    [self addSubview:_infoLabel];
    [self addSubview:_mainLabel];
    [self addSubview:_iconView];
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    
    [self.iconView.layer setSublayers:nil];
    [self setIconView:nil];
    [self setInfoLabel:nil];
    [self setMainLabel:nil];
}

@end