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
    
    //セル背景描画
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t location = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,
        0.92, 0.92, 0.92, 1.0 };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents( colorSpace, components,
                                                   locations, location );
    
    CGPoint startPoint = CGPointMake( self.frame.size.width / 2, 0.0 );
    CGPoint endPoint = CGPointMake( self.frame.size.width / 2, self.frame.size.height );
    CGContextDrawLinearGradient( context, gradient, startPoint, endPoint, 0 );
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    //NSLog(@"%@: initWithStyle", NSStringFromClass([self class]));
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        
        _infoLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(54, 2,  264, 14)] autorelease];
        _mainLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(54, 19, 264, 31)] autorelease];
        _iconView = [[[TitleButton alloc] initWithFrame:CGRectMake(2, 4, 48, 48)] autorelease];
        
        _infoLabel.font = [UIFont boldSystemFontOfSize:11];
        
        _infoLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.backgroundColor = [UIColor clearColor];
        
        _infoLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
        _mainLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
        [_infoLabel setUnderlineLinks:NO];
        [_mainLabel setUnderlineLinks:YES];
        
        [self addSubview:_infoLabel];
        [self addSubview:_mainLabel];
        [self addSubview:_iconView];
    }
    
    return self;
}

- (void)dealloc {
    
    //NSLog(@"%@: dealloc", NSStringFromClass([self class]));
    
    [self setIconView:nil];
    [self setInfoLabel:nil];
    [self setMainLabel:nil];
    
    [super dealloc];
}

@end
