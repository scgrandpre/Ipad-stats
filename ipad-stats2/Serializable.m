#import "Serializable.h"
#import "CommonUtil.h"

@interface SerializableManager ()
@property NSMutableArray *savingQueue;
@property NSMutableArray *doneSavingQueue;
@property NSDateFormatter *dateFormatter;
@end

@implementation SerializableManager
@synthesize savingQueue = _savingQueue;
@synthesize doneSavingQueue = _doneSavingQueue;
@synthesize dateFormatter = _dateFormatter;

+ (SerializableManager *)manager {
  static dispatch_once_t onceToken;
  static SerializableManager *serializableManager;
  dispatch_once(&onceToken,
                ^{ serializableManager = [[SerializableManager alloc] init]; });
  return serializableManager;
}

- (id)init {
  self = [super init];
  if (self) {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:SERIALIZED_DATE_FORMAT];

    self.savingQueue = [[NSMutableArray alloc] init];
    self.doneSavingQueue = [[NSMutableArray alloc] init];
  }
  return self;
}

- (BOOL)currentlySaving {
  return [self.savingQueue count] > 0;
}

- (void)doneSaving:(void (^)())done {
  if ([self currentlySaving]) {
    [self.doneSavingQueue addObject:done];
  } else {
    done();
  }
}

- (void)finishSaving:(NSObject<Serializable> *)object {
  [self.savingQueue removeObject:object];
  if ([self.savingQueue count] == 0) {
    while ([self.doneSavingQueue count] > 0) {
      void (^done)() = [self.doneSavingQueue objectAtIndex:0];
      [self.doneSavingQueue removeObjectAtIndex:0];
      done();
    }
  }
}

- (NSString *)typeForClass:(Class) class {
  NSString *type = @"";
  NSScanner *scanner = [NSScanner scannerWithString:NSStringFromClass(class)];

  while (true) {
    NSString *part = @"";
    [scanner scanCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet]
                        intoString:&part];
    type = [type stringByAppendingString:[part lowercaseString]];
    [scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet]
                        intoString:&part];
    type = [type stringByAppendingString:part];
    if ([scanner isAtEnd]) {
      return type;
    }
    type = [type stringByAppendingString:@"_"];
  }
} - (void)SaveSerializable
      : (NSObject<Serializable> *)object withCallback
        : (void (^)(NSObject<Serializable> *object))callback {
  [self.savingQueue addObject:object];
  NSString *type = [self typeForClass:[object class]];

  NSURL *url;
  if (object.id != Nil) {
    url = BackendURL([NSString stringWithFormat:@"%@/%@", type, object.id]);
  } else {
    object.id = generateRandomString(32);
    url = BackendURL([NSString stringWithFormat:@"%@s", type]);
  }

  NSDictionary *dict = [object asDict];

  [object uploadsCompleted:^{
      WriteData(url, dict,
                ^(NSURLResponse *response, NSData *result, NSError *error) {
          if (error != nil) {
            NSLog(@"%@", error);
            return;
          }
          NSError *JSONReadingError;
          NSDictionary *dict =
              [NSJSONSerialization JSONObjectWithData:result
                                              options:0
                                                error:&JSONReadingError];
          if (dict != nil) {
            object.id = [dict objectForKey:@"id"];
          }
          callback(object);
          [self finishSaving:object];
      });
  }];
}

- (void)GetSerializable:(Class<Serializable>) class
                 withId:(NSString *)id
               callback:(void (^)(NSObject<Serializable> *object))callback {
  NSString *type = [self typeForClass:class];

  GetJSON(BackendURL([NSString stringWithFormat:@"%@/%@", type, id]),
          ^(NSDictionary *dict, NSError *error) {
      if (dict == Nil) {
        callback(Nil);
      } else {
        callback([class fromDict:dict]);
      }
  });
} - (void)GetRangeSerializable : (Class<Serializable>) class withStart
                                 : (int)start end
                                   : (int)end callback
                                     : (void (^)(NSArray *object))callback {
  NSString *type = [self typeForClass:class];

  GetJSON(BackendURL(
              [NSString stringWithFormat:@"%@s/range/%d:%d", type, start, end]),
          ^(NSArray *arrayOfDicts, NSError *error) {
      if (arrayOfDicts == Nil) {
        callback(Nil);
      } else {
        callback(map(arrayOfDicts, ^(NSDictionary *objectDict) {
            return [class fromDict:objectDict];
        }));
      }
  });
} - (void)GetAllSerializable : (Class<Serializable>) class callback
                               : (void (^)(NSArray *object))callback {
  [self GetRangeSerializable:class withStart:0 end:-1 callback:callback];
} - (void)DeleteSerializable
      : (NSObject<Serializable> *)object callback
        : (void (^)(NSURLResponse *response, NSData *result,
                    NSError *error))callback {
  NSString *type = [self typeForClass:[object class]];

  NSURL *url =
      BackendURL([NSString stringWithFormat:@"%@/%@", type, object.id]);
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"DELETE"];

  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:callback];
}

- (NSDictionary *)SerializeUIColor:(UIColor *)color {
  const CGFloat *colors = CGColorGetComponents([color CGColor]);
  int componentCount = CGColorGetNumberOfComponents(color.CGColor);
  if (componentCount == 4) {
    return @{
      @"red" : [NSNumber numberWithFloat:colors[0]],
      @"green" : [NSNumber numberWithFloat:colors[1]],
      @"blue" : [NSNumber numberWithFloat:colors[2]],
      @"alpha" : [NSNumber numberWithFloat:colors[3]]
    };
  } else if (componentCount == 2) {
    return @{
      @"red" : [NSNumber numberWithFloat:colors[0]],
      @"green" : [NSNumber numberWithFloat:colors[0]],
      @"blue" : [NSNumber numberWithFloat:colors[0]],
      @"alpha" : [NSNumber numberWithFloat:colors[1]]
    };
  } else {
    @throw @"You're fucked";
  }
}

- (UIColor *)DeserializeUIColor:(NSDictionary *)colorDict {
  return [[UIColor alloc]
      initWithRed:[[colorDict objectForKey:@"red"] floatValue]
            green:[[colorDict objectForKey:@"green"] floatValue]
             blue:[[colorDict objectForKey:@"blue"] floatValue]
            alpha:[[colorDict objectForKey:@"alpha"] floatValue]];
}

- (NSString *)SerializeNSDate:(NSDate *)date {
  return [self.dateFormatter stringFromDate:date];
}

- (NSDate *)DeserializeNSDate:(NSString *)date {
  return [self.dateFormatter dateFromString:date];
}

@end