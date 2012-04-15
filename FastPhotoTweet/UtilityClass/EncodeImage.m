//
//  EncodeImage.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/15.
//

#import "EncodeImage.h"

@implementation EncodeImage

+ (NSData *)image:(UIImage *)encodeImage {
    
    NSData *encodedImage;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(Low)"] ) {
        encodedImage = UIImageJPEGRepresentation(encodeImage, 0.6);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG"] ) {
        encodedImage = UIImageJPEGRepresentation(encodeImage, 0.8);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(High)"] ) {
        encodedImage = UIImageJPEGRepresentation(encodeImage, 0.95);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"PNG"] ) {
        encodedImage = UIImagePNGRepresentation(encodeImage);
    }else {
        encodedImage = UIImageJPEGRepresentation(encodeImage, 0.8);
    }
    
    return encodedImage;
}

@end
