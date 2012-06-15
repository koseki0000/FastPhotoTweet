//
//  FullSizeImage.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/13.
//

#import "FullSizeImage.h"

@implementation FullSizeImage

+ (NSString *)urlString:(NSString *)urlString {
    
    //NSLog(@"originalUrl: %@", urlString);
    
    if ( [urlString hasPrefix:@"http://twitvid.com/"] || [urlString hasPrefix:@"http://www.twitvid.com/"] ) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"www." 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        [mString replaceOccurrencesOfString:@"http://twitvid.com/" 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];

        NSString *imageID1 = [mString substringWithRange:NSMakeRange(0,1)];
        NSString *imageID2 = [mString substringWithRange:NSMakeRange(1,1)];
        NSString *imageID3 = [mString substringWithRange:NSMakeRange(2,1)];
        urlString = [NSString stringWithFormat:@"http://llphotos.twitvid.com/twitvidphotos/%@/%@/%@/%@.jpg", imageID1, imageID2, imageID3, mString];
    
    }else if ( [urlString hasPrefix:@"http://lockerz.com/"] ) {
        
        urlString = [NSString stringWithFormat:@"http://api.plixi.com/api/tpapi.svc/imagefromurl?size=big&url=%@", urlString];
    
    }else if ([urlString hasPrefix:@"http://p.twipple.jp/"]) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"www." 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        [mString replaceOccurrencesOfString:@"http://p.twipple.jp/" 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        NSString *imageID1 = [mString substringWithRange:NSMakeRange(0,1)];
        NSString *imageID2 = [mString substringWithRange:NSMakeRange(1,1)];
        NSString *imageID3 = [mString substringWithRange:NSMakeRange(2,1)];
        NSString *imageID4 = [mString substringWithRange:NSMakeRange(3,1)];
        NSString *imageID5 = [mString substringWithRange:NSMakeRange(4,1)];
        urlString = [NSString stringWithFormat:@"http://p.twipple.jp/data/%@/%@/%@/%@/%@.jpg", imageID1, imageID2, imageID3, imageID4, imageID5];
    
    }else if ( [urlString hasPrefix:@"http://yfrog.com/"] ) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"http://yfrog.com/" 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        NSString *yfrogReqUrl = [NSString stringWithFormat:@"http://yfrog.com/api/xmlInfo?path=%@", mString];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:yfrogReqUrl]];
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:&error];
        
        NSString *xmlString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<image_link>.*</image_link>"
                                                                                options:0
                                                                                  error:&error];
        
        NSTextCheckingResult *match = [regexp firstMatchInString:xmlString 
                                                         options:0 
                                                           range:NSMakeRange(0, xmlString.length)];

        if ( match.numberOfRanges != 0 ) {
            
            mString = [NSMutableString stringWithString:[xmlString substringWithRange:[match rangeAtIndex:0]]];
            [mString replaceOccurrencesOfString:@"<image_link>" 
                                     withString:@"" 
                                        options:0 
                                          range:NSMakeRange(0, [mString length] )];
            
            [mString replaceOccurrencesOfString:@"</image_link>" 
                                     withString:@"" 
                                        options:0 
                                          range:NSMakeRange(0, [mString length] )];
            
            urlString = mString;
        }
        
    }else if ( [urlString hasPrefix:@"http://ow.ly/i/"] ) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"http://ow.ly/i/" 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        urlString = [NSString stringWithFormat:@"http://static.ow.ly/photos/normal/%@.jpg", mString];
        
    }else if ( [urlString hasPrefix:@"http://twitpic.com/"] && ![urlString hasPrefix:@"http://twitpic.com/photos/"] && 
              ![urlString hasPrefix:@"http://twitpic.com/show"] && ![urlString hasPrefix:@"http://twitpic.com/account"] && 
              ![urlString hasPrefix:@"http://twitpic.com/session"] && ![urlString hasPrefix:@"http://twitpic.com/events"] &&
              ![urlString hasPrefix:@"http://twitpic.com/faces"] && ![urlString hasPrefix:@"http://twitpic.com/upload"] && 
              ![urlString hasSuffix:@".do"] ) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"http://twitpic.com/" 
                                 withString:@"" 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        urlString = [NSString stringWithFormat:@"http://twitpic.com/show/full/%@", mString];
        
    }else if ( [urlString hasPrefix:@"http://instagr.am/p/"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:[NSString stringWithFormat:@"http://instagr.am/api/v1/oembed/?url=%@", urlString]];
        
        NSDictionary *results = [sourceCode JSONValue];
		urlString = [results objectForKey:@"url"];
        
    }else if ( [RegularExpression boolRegExp:urlString regExpPattern:@"https?://(mobile\\.)?twitter\\.com/[_a-zA-Z0-9]{1,15}/status/[0-9]+/photo/1"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
    
        urlString = [NSString stringWithFormat:@"%@:large", [RegularExpression strRegExp:sourceCode 
                                                                           regExpPattern:@"https?://p\\.twimg\\.com/[-_\\.a-zA-Z0-9]+"]];
    
    }else if ( [RegularExpression boolRegExp:urlString regExpPattern:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
        urlString = [RegularExpression strRegExp:sourceCode 
                                   regExpPattern:@"https?://s[0-9]\\.amazonaws\\.com/com\\.clixtr\\.picbounce/photos/[-a-zA-Z0-9]+/[a-z]600x600\\.(jpe?g|png)"];
    }
    
    //NSLog(@"fullUrl: %@", urlString);
    
    return urlString;
}

+ (NSString *)getSourceCode:(NSString *)urlString {
    
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:nil 
                                                         error:&error];
    
    int encodingList[] = {
        
        NSUTF8StringEncoding,			// UTF-8
        NSShiftJISStringEncoding,		// Shift_JIS
        NSJapaneseEUCStringEncoding,	// EUC-JP
        NSISO2022JPStringEncoding,		// JIS
        NSUnicodeStringEncoding,		// Unicode
        NSASCIIStringEncoding			// ASCII
    };
    
    NSString *dataStr = nil;
    int max = sizeof( encodingList ) / sizeof( encodingList[0] );
    
    for ( int i = 0; i < max; i++ ) {
        
        dataStr = [[[NSString alloc] initWithData:response encoding:encodingList[i]] autorelease];
        
        if ( dataStr != nil ) {
            
            break;
        }
    }
    
    if ( error ) {
        
        [ShowAlert error:error.localizedDescription];
    }
    
    return dataStr;
}

@end
