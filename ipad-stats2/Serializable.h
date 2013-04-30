//
//  Serializable.h
//  ipad-stats
//
//  Created by Jim Grandpre on 1/28/13.
//  Copyright (c) 2013 Lore. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Serializable <NSObject>
@property NSString* id;
+ (NSObject<Serializable>*) fromDict: (NSDictionary*) dict;
- (NSDictionary*) asDict;
- (void) uploadsCompleted: (void (^)()) completion;
@end


@interface SerializableManager : NSObject
+ (SerializableManager*) manager;

- (BOOL) currentlySaving;
- (void) doneSaving: (void (^)()) done;
- (void) SaveSerializable: (NSObject<Serializable>*) object withCallback: (void (^)(NSObject<Serializable>* object)) callback;
- (void) GetSerializable: (Class<Serializable>) class withId: (NSString*) id  callback: (void (^)(NSObject<Serializable>* object)) callback;
- (void) GetRangeSerializable:(Class<Serializable>) class withStart:(int) start end:(int) end callback: (void (^)(NSArray* object)) callback;
- (void) GetAllSerializable:(Class<Serializable>) class callback: (void(^)(NSArray* object)) callback;
- (void) DeleteSerializable:(NSObject<Serializable>*) object callback: (void (^)(NSURLResponse* response, NSData* result, NSError* error)) callback;
- (NSDictionary*) SerializeUIColor: (UIColor*) color;
- (UIColor*) DeserializeUIColor:(NSDictionary*) colorDict;
- (NSString*) SerializeNSDate: (NSDate*) date;
- (NSDate*) DeserializeNSDate:(NSString*) date;
@end