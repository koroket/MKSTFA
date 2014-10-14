//
//  NetworkCommunication.h
//  TFE
//
//  Created by Luke Solomon on 10/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkCommunication : NSObject

@property NSString *HerokuURL;
@property NSData *myData;

- (void)serverRequests:(NSString *)urlID
                  type:(NSString *)requestID
        whatDictionary:(NSDictionary*)dictionaryID
             withBlock:(void (^)())blockName;

@end
