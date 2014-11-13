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
#import "Card.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChoosePersonViewController () <CLLocationManagerDelegate>
{
    bool gettingMoreCards;
}
@property (weak, nonatomic) IBOutlet UIView *cardView;

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
    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    [super viewDidLoad];
    self.cards = [NSMutableArray array];
    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationController.navigationBar.barTintColor= [UIColor colorWithRed:155/255.0 green:89/255.0 blue:182/255.0 alpha:1];
    
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
    [self getMoreYelp];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}


#pragma mark - UIViewController Overrides

-(void)setUp
{
    self.frontCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    self.frontCardView.frame = self.viewContainer.frame;
    [self.cardView addSubview:self.frontCardView];
    
    // Display the second ChoosePersonView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    [self.cardView insertSubview:self.backCardView belowSubview:self.frontCardView];
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
    [self constructNopeButton];
    [self constructLikedButton];
    
}


#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view
{

}

// This is called then a user swipes the view fully left or right.
- (void)view:(MDCSwipeToChooseView *)view wasChosenWithDirection:(MDCSwipeDirection)direction
{
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    
    if (direction == MDCSwipeDirectionLeft)
    {
        NSLog(@"No");
    } else {
        NSLog(@"Yes");
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
        
        
        Card *newCard = [[Card alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        
        
        [newCard setValue:view.information.text forKey:@"name"];
        [newCard setValue:view.Price.text forKey:@"price"];
        [newCard setValue:view.distance.text forKey:@"distance"];
        [newCard setValue:view.rating.text forKey:@"rating"];
        [newCard setValue:view.hours.text forKey:@"hours"];
        [newCard setValue:view.categories.text forKey:@"categories"];
        
        NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
        [newCard setValue:imageData forKey:@"image"];

        
        
//        NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
//        
//        [newCard setValue:imageData forKey:@"image"];
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        else
        {
            NSLog(@"Saved");
            
        }

    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]]))
    {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        self.backCardView.frame = self.viewContainer.frame;
        [self.cardView insertSubview:self.backCardView belowSubview:self.frontCardView];
        
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

- (void)setFrontCardView:(MDCSwipeToChooseView *)frontCardView
{
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    _frontCardView.frame = self.viewContainer.frame;

}


- (MDCSwipeToChooseView *)popPersonViewWithFrame:(CGRect)frame
{
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
    MDCSwipeToChooseView *personView = [[MDCSwipeToChooseView alloc] initWithFrame:self.cardView.frame
                                                                   options:options];
   
//    personView.frame = self.viewContainer.frame;
//    [personView setOptions:options];
    NSMutableDictionary *temp = self.cards[0];
    personView.information.text = temp[@"Name"];
    [self requestScrape:temp[@"url"] forView:personView];
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

- (CGRect)frontCardViewFrame
{
    return self.viewContainer.frame;
}

- (CGRect)backCardViewFrame
{
    return self.viewContainer.frame;
}

// Create and add the "nope" button.
- (void)constructNopeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"nope"];
    button.frame = CGRectMake(CGRectGetMinX(self.cardView.frame),
                              CGRectGetMaxY(self.cardView.frame) + ChoosePersonButtonVerticalPadding,
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
    [self.cardView addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    button.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.cardView.frame) + ChoosePersonButtonVerticalPadding,
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
    [self.cardView addSubview:button];
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

-(void)getMoreYelp
{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Yelp Search Term"]==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Restaurants" forKey:@"Yelp Search Term"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/yelp/%@/%@/%@/%d",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"User Location Latitude"],
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"User Location Longitude"],
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"Yelp Search Term"],
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

    //Save current location to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.latitude) forKey:@"User Location Latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.longitude) forKey:@"User Location Longitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [manager stopUpdatingLocation];
}
-(void)requestScrape:(NSString*)myurl forView:(MDCSwipeToChooseView *) myview
{
    NSString *fixedURL = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/scrape"];
    NSURL *url = [NSURL URLWithString:fixedURL];
    
    //Session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    //Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    //Dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:myurl forKey:@"url"];
    
    //Error Handling
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    if (!error)
    {
        //Upload
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                              {
                                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                  NSInteger responseStatusCode = [httpResponse statusCode];
                                                  if (responseStatusCode == 200 && data)
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^(void)
                                                                     {
                                                                         NSLog(@"Scrape Success");
                                                                         NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                options:0
                                                                                                                                  error:nil];
                                                                         NSLog(@"%@",fetchedData);
                                                                         myview.hours.text = fetchedData[@"hour"];
                                                                         myview.Price.text = [self priceFixer:fetchedData[@"price"]];
                                                                     });//Dispatch main queue block
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"Scrape failed");
                                                  }
                                              }];//upload task Block
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else
    {
        NSLog(@"Cannot connect to server");
    }

}
-(NSString*)priceFixer:(NSString*) mystr
{
    NSString* newString = [mystr stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return newString;
}
@end
