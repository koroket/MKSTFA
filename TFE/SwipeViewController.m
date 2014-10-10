//
//  SwipeViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SwipeViewController.h"
#import "DraggableBackground.h"

@interface SwipeViewController ()

@end

@implementation SwipeViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self getRequests];
}

- (void)getRequests {
	[[NSUserDefaults standardUserDefaults] setObject:self.groupID forKey:@"pract"];
	[[NSUserDefaults standardUserDefaults] setInteger:self.numOfPeople forKey:@"numOfPeople"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@", self.groupID];
	// 1
	NSURL *url = [NSURL URLWithString:fixedUrl];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];

	[request setHTTPMethod:@"GET"];

	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

	NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

	NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
	    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	    NSInteger responseStatusCode = [httpResponse statusCode];

	    if (responseStatusCode == 200 && data) {
	        dispatch_async(dispatch_get_main_queue(), ^(void) {
	            NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

	            [[NSUserDefaults standardUserDefaults] setObject:fetchedData forKey:@"AllObjects"];
	            [[NSUserDefaults standardUserDefaults] synchronize];
	            DraggableBackground *draggableBackground = [[DraggableBackground alloc]initWithFrame:self.view.frame];

	            [self.view addSubview:draggableBackground];
			});

	        // do something with this data
	        // if you want to update UI, do it on main queue
		}
	    else {
	        // error handling
		}
	}];
	[dataTask resume];
}

@end
