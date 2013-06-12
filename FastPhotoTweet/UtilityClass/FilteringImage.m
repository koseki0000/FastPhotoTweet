//
//  FilteringImage.m
//

#import "FilteringImage.h"

@implementation FilteringImage

#pragma mark - IntensityImage

+ (UIImage *)createIntensityImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter {
    
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:filterName];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputIntensity"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (UIImage *)bloomImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIBloom"] ) return image;
    if ( parameter < 0.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return nil;
    }
    
    return [FilteringImage createIntensityImage:[FilteringImage orientationImage:image]
                                     filterName:@"CIBloom"
                                      parameter:parameter];
}

+ (UIImage *)monochromeImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIColorMonochrome"] ) return image;
    if ( parameter < 0.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return nil;
    }
    
    image = [FilteringImage orientationImage:image];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputIntensity"];
    [ciFilter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0] forKey:@"inputColor"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (UIImage *)gloomImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIGloom"] ) return image;
    if ( parameter < 0.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return nil;
    }
    
    return [FilteringImage createIntensityImage:[FilteringImage orientationImage:image]
                                     filterName:@"CIGloom"
                                      parameter:parameter];
}

+ (UIImage *)sepiaImage:(UIImage *)image parameter:(CGFloat)parameter {

    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CISepiaTone"] ) return image;
    if ( parameter < 0.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return nil;
    }
    
    return [FilteringImage createIntensityImage:[FilteringImage orientationImage:image]
                                     filterName:@"CISepiaTone"
                                      parameter:parameter];
}

+ (UIImage *)unSharpMaskImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIUnsharpMask"] ) return image;
    if ( parameter < 0.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return nil;
    }
    
    return [FilteringImage createIntensityImage:[FilteringImage orientationImage:image]
                                     filterName:@"CIUnsharpMask"
                                      parameter:parameter];
}

+ (UIImage *)vignetteImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIVignette"] ) return image;
    if ( parameter < -1.0 || parameter > 1.0 ) {
    
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    return [FilteringImage createIntensityImage:[FilteringImage orientationImage:image]
                                     filterName:@"CIVignette"
                                      parameter:parameter];
}

#pragma mark - AmountImage

+ (UIImage *)createAmountImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter {
    
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:filterName];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputAmount"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (UIImage *)vibranceImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIVibrance"] ) return image;
    if ( parameter < -1.0 || parameter > 1.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    return [FilteringImage createAmountImage:[FilteringImage orientationImage:image]
                                  filterName:@"CIVibrance"
                                   parameter:parameter];
}

#pragma mark - LevelsImage
+ (UIImage *)createLevelsImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter {
    
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:filterName];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputLevels"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (UIImage *)posterizeImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIColorPosterize"] ) return image;
    if ( parameter < 2.0 || parameter > 30.0 ) {
     
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    return [FilteringImage createLevelsImage:[FilteringImage orientationImage:image]
                                  filterName:@"CIColorPosterize"
                                   parameter:parameter];
}

#pragma mark - EV
+ (UIImage *)createEVImage:(UIImage *)originalImage filterName:(NSString *)filterName parameter:(CGFloat)parameter {
    
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:filterName];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputEV"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (UIImage *)exposureAdjustImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CIExposureAdjust"] ) return image;
    if ( parameter < -10.0 || parameter > 10.0 ) {
     
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    return [FilteringImage createEVImage:[FilteringImage orientationImage:image]
                              filterName:@"CIExposureAdjust"
                               parameter:parameter];
}

#pragma mark - Distortion
+ (UIImage *)circleSplashDistortionImage:(UIImage *)image vector:(CGPoint)vector radius:(CGFloat)radius {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CICircleSplashDistortion"] ) return image;
    if ( radius < 0.0 || radius > 1000.0 ) {
        
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    image = [FilteringImage orientationImage:image];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CICircleSplashDistortion"];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:[CIVector vectorWithCGPoint:vector] forKey:@"inputCenter"];
    [ciFilter setValue:@(radius) forKey:@"inputRadius"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);

    return filteredImage;
}

#pragma mark - SharpenLuminance
+ (UIImage *)sharpenLuminanceImage:(UIImage *)image parameter:(CGFloat)parameter {
    
    if ( image == nil ) return nil;
    if ( ![FilteringImage canUseFilter:@"CISharpenLuminance"] ) return image;
    if ( parameter < 0.0 || parameter > 2.0 ) {
     
        [FilteringImage showFilterErrorAlert];
        return image;
    }
    
    image = [FilteringImage orientationImage:image];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(parameter) forKey:@"inputSharpness"];
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:ciFilter.outputImage
                                         fromRect:ciFilter.outputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage
                                                 scale:1.0f
                                           orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return filteredImage;
}

+ (void)showFilterErrorAlert {
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"フィルターのパラメータが不正です。"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
}

+ (UIImage *)orientationImage:(UIImage *)image {
    
    return image;
    
	CGImageRef imageRef = image.CGImage;
	CGFloat width = CGImageGetWidth(imageRef);
	CGFloat height = CGImageGetHeight(imageRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
    
	switch( orient ) {
			
		case UIImageOrientationUp:
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown:
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
            break;
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imageRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

+ (BOOL)canUseFilter:(NSString *)checkFilterName {
    
    BOOL canUse = NO;
    NSArray *filters = [CIFilter filterNamesInCategories:@[kCICategoryBuiltIn]];
    
    for ( NSString *filterName in filters ) {
        
        if ( [filterName isEqualToString:checkFilterName] ) {
         
            canUse = YES;
            break;
        }
    }
    
    if ( !canUse ) {
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"このiOSでは使えないフィルターです。"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        [alert show];
    }
    
    return canUse;
}

#pragma mark - CornerRadius

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    image = [UIImage imageWithCGImage:masked];
    
    CFRelease(mask);
    CFRelease(masked);
    
    return image;
}

#pragma mark - Debug

+ (void)outPutFilterName {
    
    NSArray *filters = [CIFilter filterNamesInCategories:@[kCICategoryBuiltIn]];
    NSLog(@"kCICategoryBuiltIn: %@", filters);
    
    for ( NSString *filterName in filters ) {
        
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSDictionary *attributes = [filter attributes];
        NSLog(@"Filter <%@> :\n %@",filterName, attributes);
    }
}

@end
