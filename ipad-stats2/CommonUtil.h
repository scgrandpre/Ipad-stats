//
//  CommonUtil.h
//  Thread2
//
//  Created by Jim Grandpre on 1/23/13.
//  Copyright (c) 2013 Lore. All rights reserved.
//

extern id reduce(NSArray* collection, id acc, id (^block)(id el, id acc));
extern NSMutableArray* filter(NSArray* collection, BOOL (^block)(id));
extern NSMutableArray* map(NSArray* collection, id (^block)(id));
extern CGPoint CGPointOffset(CGPoint base, CGPoint offset);
extern CGPoint CGRectMidpoint(CGRect rect);
extern CGRect CGRectNormalizeRect(CGRect rectToNormalize, CGRect withRect);
extern CGRect CGRectConvertToRealDimensions(CGRect rectToConvert, CGRect withRect);
extern UIColor *UIColorFromHex(NSString *hex);
extern BOOL colorSimilarToColor(UIColor *left, UIColor *right);

extern CGRect CGRectFromRectWithWidth(CGRect fromRect, CGFloat width);
extern CGRect CGRectFromRectWithHeight(CGRect fromRect, CGFloat height);
extern CGRect CGRectFromRectWithSize(CGRect fromRect, CGSize size);
extern NSString * hexString(NSData* data);
extern NSString *pluralize(NSUInteger n, NSString *string);

void WriteData(NSURL* url, NSDictionary* data, void (^callback)(NSURLResponse *, NSData*, NSError*));
void GetData(NSURL* url, void (^callback)(NSURLResponse *, NSData*, NSError*));
void GetJSON(NSURL* url, void (^callback)(id, NSError*));

NSURL* BackendURL(NSString* endpoint);
NSString *generateRandomString(int len);

// colors
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SERIALIZED_DATE_FORMAT @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"