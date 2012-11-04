//
//  TimelineAttributedCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//
//

#import "TimelineAttributedCell.h"

static NSInteger const kAttributedLabelTag = 100;

@implementation TimelineAttributedCell

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t location = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0,  1.0,  1.0,  1.0,
        0.92, 0.92, 0.92, 1.0 };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient =   CGGradientCreateWithColorComponents( colorSpace, components,
                                                     locations, location );
    
    CGPoint startPoint = CGPointMake( self.frame.size.width / 2, 0.0 );
    CGPoint endPoint =   CGPointMake( self.frame.size.width / 2, self.frame.size.height );
    CGContextDrawLinearGradient( context, gradient, startPoint, endPoint, 0 );
    
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
    _iconView = [[TitleButton alloc] initWithFrame:CGRectMake(2, 4, 48, 48)];
    
    _infoLabel.font = [UIFont boldSystemFontOfSize:11];
    
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
    
    CALayer *iconLayer = [[CALayer alloc] init];
    iconLayer.name = @"Icon";
    iconLayer.frame = CGRectMake(0, 0, 48, 48);
    
    if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"IconCornerRounding"] == 1 ) {
        
        //角を丸める
        [iconLayer setMasksToBounds:YES];
        [iconLayer setCornerRadius:6.0f];
    }
    
    [self.iconView.layer addSublayer:iconLayer];
    
    [self addSubview:_infoLabel];
    [self addSubview:_mainLabel];
    [self addSubview:_iconView];
}

- (void)dealloc {
    
    //NSLog(@"%@: dealloc", NSStringFromClass([self class]));
    
    [self.iconView removeFromSuperview];
    [self.infoLabel removeFromSuperview];
    [self.mainLabel removeFromSuperview];
    [self setIconView:nil];
    [self setInfoLabel:nil];
    [self setMainLabel:nil];
}

@end
