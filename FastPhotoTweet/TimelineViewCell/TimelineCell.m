//
//  TimelineCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TimelineCell.h"

@implementation TimelineCell
@synthesize infoLabel;
@synthesize textLabel;
@synthesize iconView;

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //セル背景描画
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t location = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,  // Start color
                              0.92, 0.92, 0.92, 1.0 }; // End color
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents( colorSpace, components,
                                                    locations, location );
    
    CGPoint startPoint = CGPointMake( self.frame.size.width / 2, 0.0 );
    CGPoint endPoint = CGPointMake( self.frame.size.width / 2, self.frame.size.height );
    CGContextDrawLinearGradient( context, gradient, startPoint, endPoint, 0 );
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    //アイコン描画
//    CGImageRef image = CGImageRetain(appDelegate.testImage.CGImage);
//    
//    size_t width = CGImageGetWidth(image);
//    size_t height = CGImageGetHeight(image);
//    
//    CGRect imageRect = CGRectMake(2, 4, width, height);
//    
//    CGAffineTransform affine = CGAffineTransformIdentity;
//    affine.d = -1.0f;
//    affine.ty = height + 8;
//    CGContextConcatCTM(context, affine);
//	CGContextDrawImage(context, imageRect, image);
}

- (void)dealloc {

    [infoLabel release];
	[textLabel release];
    [iconView release];
    [super dealloc];
}

@end