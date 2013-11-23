//
//  CommonUtil.m
//  Thread2
//
//  Created by Jim Grandpre on 1/23/13.
//  Copyright (c) 2013 Lore. All rights reserved.
//

#import "CommonUtil.h"

id reduce(NSArray* collection, id acc, id (^block)(id el, id acc)) {
    for (id item in collection) {
        acc = block(item, acc);
    }
    return acc;
}

NSMutableArray* map(NSArray* collection, id (^block)(id)) {
    NSMutableArray* acc = [[NSMutableArray alloc] initWithCapacity:[collection count]];
    for (id item in collection) {
        id x = block(item);
        if (x == nil) {
            [acc addObject:[NSNull null]];
        }
        else {
            [acc addObject:x];
        }
    }
    return acc;
}


NSMutableArray* filter(NSArray* collection, BOOL (^block)(id)) {
    NSMutableArray* acc = [[NSMutableArray alloc] init];
    return reduce(collection, acc, ^(id item, NSMutableArray* acc) {
        if (block(item)) {
            [acc addObject:item];
        }
        return acc;
    });
}



CGPoint CGPointOffset(CGPoint base, CGPoint offset) {
    CGPoint point;
    point.x = base.x + offset.x;
    point.y = base.y + offset.y;
    return point;
}

CGPoint CGRectMidpoint(CGRect rect) {
    CGPoint point;
    point.x = CGRectGetMidX(rect);
    point.y = CGRectGetMidY(rect);
    return point;
}

CGRect CGRectNormalizeRect(CGRect rectToNormalize, CGRect withRect) {
    return CGRectMake(rectToNormalize.origin.x/withRect.size.width,
                      rectToNormalize.origin.y/withRect.size.height,
                      rectToNormalize.size.width/withRect.size.width,
                      rectToNormalize.size.height/withRect.size.height);
}

CGRect CGRectConvertToRealDimensions(CGRect rectToConvert, CGRect withRect) {
    return CGRectMake(rectToConvert.origin.x * withRect.size.width,
                      rectToConvert.origin.y * withRect.size.height,
                      rectToConvert.size.width * withRect.size.width,
                      rectToConvert.size.height * withRect.size.height);
}

UIColor *UIColorFromHex(NSString *hex) {
    NSString *redHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(0, 2)]];
    NSString *greenHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(2, 2)]];
    NSString *blueHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(4, 2)]];
    
    CGFloat redFloat = 0.0f;
    NSScanner *rScanner = [NSScanner scannerWithString:redHex];
    [rScanner scanHexFloat:&redFloat];
    
    CGFloat greenFloat = 0.0f;
    NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
    [gScanner scanHexFloat:&greenFloat];
    
    CGFloat blueFloat = 0.0f;
    NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
    [bScanner scanHexFloat:&blueFloat];
    
    return [UIColor colorWithRed:redFloat/255.0f green:greenFloat/255.0f
                            blue:blueFloat/255.0f alpha:1.0f];
}

BOOL colorSimilarToColor(UIColor *left, UIColor *right) {
	float tolerance = 0.05; // 5%
    
	CGColorRef leftColor = [left CGColor];
	CGColorRef rightColor = [right CGColor];
    
	if (CGColorGetColorSpace(leftColor) != CGColorGetColorSpace(rightColor)) {
		return FALSE;
	}
    
	int componentCount = CGColorGetNumberOfComponents(leftColor);
    
	const float *leftComponents = CGColorGetComponents(leftColor);
	const float *rightComponents = CGColorGetComponents(rightColor);
    
	for (int i = 0; i < componentCount; i++) {
		float difference = leftComponents[i] / rightComponents[i];
        
		if (fabs(difference - 1) > tolerance) {
			return FALSE;
		}
	}
    
	return TRUE;
}

CGRect CGRectFromRectWithWidth(CGRect fromRect, CGFloat width) {
    CGRect returnRect = fromRect;
    returnRect.size.width = width;
    return returnRect;
}

CGRect CGRectFromRectWithHeight(CGRect fromRect, CGFloat height) {
    CGRect returnRect = fromRect;
    returnRect.size.height = height;
    return returnRect;
}

CGRect CGRectFromRectWithSize(CGRect fromRect, CGSize size) {
    CGRect returnRect = fromRect;
    returnRect.size = size;
    return returnRect;
}

// From http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string
NSString * hexString(NSData* data) {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

NSString* encodeToPercentEscapeString(NSString *string) {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                  (CFStringRef) string,
                                                                                  NULL,
                                                                                  (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8));
}

void WriteData(NSURL* url, NSDictionary* data, void (^callback)(NSURLResponse *, NSData*, NSError*)) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
    NSError *error;
    NSString *JSON = [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject: data options:0 error:&error] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", JSON);
    NSString *queryString = [NSString stringWithFormat:@"json=%@", encodeToPercentEscapeString(JSON)];
    NSData *body = [queryString dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: body];
    
    [NSURLConnection sendAsynchronousRequest: request  queue:[NSOperationQueue mainQueue] completionHandler: callback];
}

void GetData(NSURL* url, void (^callback)(NSURLResponse *, NSData*, NSError*)) {
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
    [NSURLConnection sendAsynchronousRequest: request  queue:[NSOperationQueue mainQueue] completionHandler: callback];
}

void GetJSON(NSURL* url, void (^callback)(id, NSError*)) {
    GetData(url,^(NSURLResponse* response, NSData* result, NSError* error) {
        if(error) {
            callback(nil, error);
        } else {
            NSError *JSONReadingError;
            id dict = [NSJSONSerialization JSONObjectWithData:result options:0 error:&JSONReadingError];
            callback(dict, JSONReadingError);
        }
    });
}

NSURL* BackendURL(NSString* endpoint) {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://ipad-stats.herokuapp.com/%@", endpoint]];
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
NSString *generateRandomString(int len) {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

NSString *pluralize(NSUInteger n, NSString *string) {
    if (n == 1) return string;
    else return [NSString stringWithFormat:@"%@s", string];
}
