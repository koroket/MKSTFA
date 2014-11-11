//
// ChoosePersonViewController.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChoosePersonViewController.h"
#import "NetworkCommunication.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <CoreLocation/CoreLocation.h>

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChoosePersonViewController () <CLLocationManagerDelegate>
{
    bool gettingMoreCards;
}

@property (nonatomic, strong)NSMutableArray *cards;

@end


@implementation ChoosePersonViewController
{
    //Location Management
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
}

#pragma mark - Object Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cards = [NSMutableArray array];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor= [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182/255.0 alpha:1];
    
    //LocationManager stuff
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (currentLocation == nil)
    {
        [manager requestWhenInUseAuthorization];
        [manager startUpdatingLocation];
    }
    else
    {
        [manager stopUpdatingLocation];
    }
    
    
    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMoreYelp];
    
}


#pragma mark - UIViewController Overrides

-(void)setUp
{
    self.frontCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    self.frontCardView.frame = self.viewContainer.frame;
    [self.viewContainer addSubview:self.frontCardView];
    
    // Display the second ChoosePersonView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    [self.viewContainer insertSubview:self.backCardView belowSubview:self.frontCardView];
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
    [self constructNopeButton];
    [self constructLikedButton];
    
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {

}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    
    if (direction == MDCSwipeDirectionLeft) {

    } else {

    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        self.backCardView.frame = self.viewContainer.frame;
        [self.viewContainer insertSubview:self.backCardView belowSubview:self.frontCardView];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                            self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
    if(self.cards.count<10&&!gettingMoreCards)
    {
        NSLog(@"low on cards, getting more");
        gettingMoreCards = true;
        [self getMoreYelp];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(MDCSwipeToChooseView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    _frontCardView.frame = self.viewContainer.frame;

}


- (MDCSwipeToChooseView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.cards count] == 0) {
        return nil;
    }

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = [self backCardViewFrame];
    };

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
//    ChoosePersonView *personView = [[ChoosePersonView alloc] initWithFrame:frame
//                                                                    person:self.people[0]
//                                                                   options:options];
    MDCSwipeToChooseView *personView = [[MDCSwipeToChooseView alloc] initWithFrame:frame
                                                                   options:options];
   
//    personView.frame = self.viewContainer.frame;
//    [personView setOptions:options];
    NSMutableDictionary *temp = self.cards[0];
    personView.information.text = temp[@"Name"];
    if(temp[@"ImageURL"]!=nil)
    {
        
        NSString* newString = temp[@"ImageURL"];
        
        NSString* new2String = [newString stringByReplacingOccurrencesOfString:@"/ms.jpg" withString:@"/o.jpg"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:new2String]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                personView.imageView.image  = tempImage;
            });
        });
        
        
        
    }
    if(temp[@"rating"]!=nil)
    {
        NSNumber *k = temp[@"rating"];
        personView.rating.text  = [NSString stringWithFormat:@"%.1f Rating",[k doubleValue]];
        
    }
    if(temp[@"distance"]!=nil)
    {
        
        NSNumber *k = temp[@"distance"];
        double meters = [k doubleValue];
        double miles = meters/1600.0;
        
        personView.distance.text  = [NSString stringWithFormat:@"%.1f mi",miles];
        
    }
    if(temp[@"Category"]!=nil)
    {
        NSArray *cats = temp[@"Category"];
        NSString* catsString = @"";
        for(int i = 0; i < cats.count;i++)
        {
            catsString = [NSString stringWithFormat:@"%@ %@",catsString,cats[i]];
        }
        
        personView.categories.text  = catsString;
        
        
    }
    if(temp[@"price"]!=nil)
    {
        NSString *k = [self priceFix:temp[@"price"]];
        personView.Price.text  = [NSString stringWithFormat:@"%@",k];
        
    }
    if(temp[@"hours"]!=nil)
    {
        NSString *k = temp[@"hours"];
        personView.hours.text  = [NSString stringWithFormat:@"%@",k];
        
    }
    [self.cards removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    return self.viewContainer.frame;
}

- (CGRect)backCardViewFrame {
    return self.viewContainer.frame;
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"nope"];
    button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:button];
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

-(void)getMoreYelp
{
    NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%@/%@/%d",
                          @"37.777644",
                          @"-122.399053",
                          @"restaurants",
                          self.offset
                          ];
    NSURL *url = [NSURL URLWithString:fixedURL];
    // Request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    // Request type
    [request setHTTPMethod:@"GET"];
    // Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    // Data Task Block
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request
                  completionHandler:^(NSData *data,
                                      NSURLResponse *response,
                                      NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         if (responseStatusCode == 200 && data)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                NSArray*fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:nil];
                                NSLog(@"got more cards");
                                [self.cards addObjectsFromArray:fetchedData];
                                if(self.cards.count==20)
                                {
                                    [self setUp];
                                }
                                self.offset +=20;
                                gettingMoreCards = false;

                            }); // Main Queue dispatch block
             
             // do something with this data
             // if you want to update UI, do it on main queue
         }
         else
         {
             NSLog(@"error");
             // error handlingN
         }
     }]; // Data Task Block
    [dataTask resume];
}

-(NSString*)priceFix:(NSString*) str
{
    NSString* tempStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return tempStr;
}

#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Location: %@", newLocation);
    currentLocation = newLocation;
    if (currentLocation != nil)
    {
        //self.textFieldLocation.text = [NSString stringWithFormat:@" ";
    }
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
         }
         else
         {
             NSLog(@"%@",error.debugDescription);
         }
         
     }];
    
    // Singleton
#pragma message "Why are you storing GeoLocations as strings? It would be nicer to store them with their actual type and let the NetworkCommunication class translate them into strings before talking to the server"
    [NetworkCommunication sharedManager].stringYelpLocation = [NSString stringWithFormat:(@"%f,%f"),
                                                               currentLocation.coordinate.latitude,
                                                               currentLocation.coordinate.longitude];
    
    [NetworkCommunication sharedManager].stringCurrentLatitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.latitude];
    
    [NetworkCommunication sharedManager].stringCurrentLongitude = [NSString stringWithFormat:(@"%f"), currentLocation.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    
}

@end
