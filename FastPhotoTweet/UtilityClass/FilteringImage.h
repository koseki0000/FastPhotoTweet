//
//  FilteringImage.h
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface FilteringImage : NSObject

#pragma mark - IntensityImage
+ (UIImage *)createIntensityImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter;
+ (UIImage *)bloomImage:(UIImage *)image parameter:(CGFloat)parameter;
+ (UIImage *)monochromeImage:(UIImage *)image parameter:(CGFloat)parameter;
+ (UIImage *)gloomImage:(UIImage *)image parameter:(CGFloat)parameter;
+ (UIImage *)sepiaImage:(UIImage *)image parameter:(CGFloat)parameter;
+ (UIImage *)unSharpMaskImage:(UIImage *)image parameter:(CGFloat)parameter;
+ (UIImage *)vignetteImage:(UIImage *)image parameter:(CGFloat)parameter;

#pragma mark - AmountImage
+ (UIImage *)createAmountImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter;
+ (UIImage *)vibranceImage:(UIImage *)image parameter:(CGFloat)parameter;

#pragma mark - LevelsImage
+ (UIImage *)createLevelsImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter;
+ (UIImage *)posterizeImage:(UIImage *)image parameter:(CGFloat)parameter;

#pragma mark - EV
+ (UIImage *)createEVImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter;
+ (UIImage *)exposureAdjustImage:(UIImage *)image parameter:(CGFloat)parameter;

#pragma mark - Distortion
+ (UIImage *)circleSplashDistortionImage:(UIImage *)image vector:(CGPoint)vector radius:(CGFloat)radius;

#pragma mark - SharpenLuminance
+ (UIImage *)sharpenLuminanceImage:(UIImage *)image parameter:(CGFloat)parameter;

+ (UIImage *)orientationImage:(UIImage *)image;
+ (BOOL)canUseFilter:(NSString *)checkFilterName;
+ (void)showFilterErrorAlert;

#pragma mark - CornerRadius
- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

#pragma mark - Debug
+ (void)outPutFilterName;

@end
