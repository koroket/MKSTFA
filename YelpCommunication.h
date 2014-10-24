//
//  YelpCommunication.h
//  TFE
//
//  Created by Luke Solomon on 10/24/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YelpCommunication : NSObject

+ (instancetype)sharedManager;

- (void)getYelp;


@end
