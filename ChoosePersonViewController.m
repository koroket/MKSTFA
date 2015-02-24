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

#import "Card.h"
#import "AppDelegate.h"
#import "NetworkCommunication.h"
#import "ChoosePersonViewController.h"
#import "Mixpanel.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <CoreLocation/CoreLocation.h>

#define MIXPANEL_TOKEN @"415ae3248e8e431462e61e457872ca55"

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChoosePersonViewController () <CLLocationManagerDelegate> {
    bool gettingMoreCards;
    bool outOfCards;
}

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong)NSMutableArray *cards;


@end


@implementation ChoosePersonViewController {
    //Location Management
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
}

#pragma mark - Object Lifecycle
/**
 * --------------------------------------------------------------------------
 * Object Lifecycle
 * --------------------------------------------------------------------------
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSArray* temp = [context executeFetchRequest:fetchRequest error:&error];
        self.coreDataCards = temp;
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        } else {
            NSLog(@"%@", self.coreDataCards);
        }
    }
    return self;
}

-(void)setLimits {
    [NetworkCommunication sharedManager].minRating = 4.5;
    [NetworkCommunication sharedManager].maxDistance = 5.0;
}


#pragma mark - UIViewController Overrides
/**
 * --------------------------------------------------------------------------
 * UIViewController Overrides
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad {
    [self setLimits];
    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    [super viewDidLoad];
    
    //Change the color of the tab bar item
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"ShuffleIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.cards = [NSMutableArray array];
    outOfCards = true;
    //LocationManager stuff
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"User Location Latitude"] == nil) {
        if (currentLocation == nil) {
            [manager requestWhenInUseAuthorization];
            [manager startUpdatingLocation];
        } else {
            [manager stopUpdatingLocation];
        }
    } else {
        [self getMoreYelp];
    }
    
    [self constructNopeButton];
    [self constructLikedButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([NetworkCommunication sharedManager].searchTermDidChange) {
        [NetworkCommunication sharedManager].searchTermDidChange = false;
        self.offset = 0;
        self.cards = [NSMutableArray array];
        self.frontCardView = nil;
        self.backCardView = nil;
        outOfCards = true;
        [self getMoreYelp];
    }
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods
/**
 * --------------------------------------------------------------------------
 * MDCSwipeToChooseDelegate Protocol Methods
 * --------------------------------------------------------------------------
 */

-(void)setUp {
    [self loadFront];
    [self loadBack];
    [self constructNopeButton];
    [self constructLikedButton];
}

-(void)loadBack {
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    [self.cardView insertSubview:self.backCardView belowSubview:self.frontCardView];
}

-(void)loadFront {
    self.frontCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    self.frontCardView.frame = self.viewContainer.frame;
    [self.cardView addSubview:self.frontCardView];
}


- (void)viewDidCancelSwipe:(UIView *)view {
    
}

// A user swiped the view fully left or right.
- (void)view:(MDCSwipeToChooseView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    
    if(self.cards.count < 1) {
        outOfCards = true;
    }
    
    
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"User Swiped Left (no)");
        // Initialize the library with your
        // Mixpanel project token
        [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Swiped Left" properties:@{
        }];
    
    } else {
        NSLog(@"User Swiped Right (yes)");
        // Initialize the library with your
        // Mixpanel project token
        [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Swiped Right" properties:@{
        }];
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:context];
        Card *newCard = [[Card alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        
        NSLog(@"%@",view.city);
        
        [newCard setValue:view.bizid forKey:@"bizid"];
        [newCard setValue:view.information.text forKey:@"name"];
        [newCard setValue:view.Price.text forKey:@"price"];
        [newCard setValue:view.distance.text forKey:@"distance"];
        [newCard setValue:view.rating.text forKey:@"rating"];
        [newCard setValue:view.hours.text forKey:@"hours"];
        [newCard setValue:view.categories.text forKey:@"categories"];
        [newCard setValue:view.city forKey:@"city"];
        [newCard setValue:view.address forKey:@"address"];
        [newCard setValue:view.zipcode forKey:@"zipcode"];
        [newCard setValue:view.state forKey:@"state"];
        NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
        [newCard setValue:imageData forKey:@"image"];
        // NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
        // [newCard setValue:imageData forKey:@"image"];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        } else {
            NSLog(@"Saved");
        }
    }
    /*MDCSwipeToChooseView removes the view from the view hierarchy after it is swiped (this behavior can be customized via the MDCSwipeOptions class). Since the front card view is gone, we move the back card to the front, and create a new back card. */
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        self.backCardView.frame = self.viewContainer.frame;
        [self.cardView insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            self.backCardView.alpha = 1.f;
        }
        completion:nil];
    }
    if(self.cards.count < 10 &&! gettingMoreCards) {
        NSLog(@"low on cards, getting more");
        gettingMoreCards = true;
        [self getMoreYelp];
    }
    if(outOfCards&&!gettingMoreCards) {
        gettingMoreCards = true;
        [self getMoreYelp];
    }
    if(!gettingMoreCards&&(self.backCardView==nil||self.frontCardView==nil)) {
        [self getMoreYelp];
    }
}

#pragma mark - View Construction
/**
 * --------------------------------------------------------------------------
 * View Construction
 * --------------------------------------------------------------------------
 */

- (void)setFrontCardView:(MDCSwipeToChooseView *)frontCardView {
    // Keep track of the person currently being chosen.
    _frontCardView = frontCardView;
    _frontCardView.frame = self.viewContainer.frame;
}

- (MDCSwipeToChooseView *)popPersonViewWithFrame:(CGRect)frame {
    NSMutableDictionary *businessAttributesDictionary;
    
    if ([self.cards count] == 0) {
        if(!gettingMoreCards) {
            // NSLog(@"low on cards, getting more");
            gettingMoreCards = true;
            [self getMoreYelp];
        }
        outOfCards = true;
        return nil;
    } else {
        businessAttributesDictionary = self.cards[0];
    }
    
    while ( self.cards.count > 0 && ( [self businessExists:businessAttributesDictionary[@"id"]] ||
                                     ![self isWithInDistnaceRange:businessAttributesDictionary[@"distance"]] ||
                                     ![self isWithInPriceRange:@""] ||
                                     ![self isWithInRatingRange:businessAttributesDictionary[@"rating"]] ) ) {
        NSLog(@"ChoosePersonViewController - popPersonViewWithFrame - cards.count: %lu",(unsigned long)self.cards.count);
        
        [self.cards removeObjectAtIndex:0];
        
        if ([self.cards count] == 0) {
            if(!gettingMoreCards) {
                NSLog(@"low on cards, getting more");
                gettingMoreCards = true;
                [self getMoreYelp];
            }
            return nil;
        } else {
            businessAttributesDictionary = self.cards[0];
        }
    }
    
    // Specify the view controller as a delegate, and provide a custom callback that moves the back card view based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        //CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = [self backCardViewFrame];
    };
    
    // Create a personView with the top person in the people array, then pop that person off the stack.
    MDCSwipeToChooseView *personView = [[MDCSwipeToChooseView alloc] initWithFrame:self.cardView.frame options:options];
    personView.information.text = businessAttributesDictionary[@"Name"];
    personView.bizid = businessAttributesDictionary[@"id"];
    [self requestScrape:businessAttributesDictionary[@"url"] forView:personView];
    NSDictionary* locations = businessAttributesDictionary[@"location"];
    personView.city = locations[@"city"];
    NSArray* tempArrayToFixAddress = locations[@"address"];
    
    if(tempArrayToFixAddress.count > 0) {
            personView.address = tempArrayToFixAddress[0];
    }
    
    personView.state = locations[@"state_code"];
    personView.zipcode = locations[@"postal_code"];
    
    if(businessAttributesDictionary[@"ImageURL"] != nil) {
        NSString* newString = businessAttributesDictionary[@"ImageURL"];
        NSString* new2String = [newString stringByReplacingOccurrencesOfString:@"/ms.jpg" withString:@"/o.jpg"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:new2String]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                personView.imageView.image  = tempImage;
            });
        });
    }
    
    if(businessAttributesDictionary[@"rating"] != nil) {
        NSNumber *k = businessAttributesDictionary[@"rating"];
        personView.rating.text  = [NSString stringWithFormat:@"%.1f Rating",[k doubleValue]];
    }
    
    if(businessAttributesDictionary[@"distance"] != nil) {
        NSNumber *k = businessAttributesDictionary[@"distance"];
        double meters = [k doubleValue];
        double miles = meters/1600.0;
        personView.distance.text  = [NSString stringWithFormat:@"%.1f mi",miles];
    }
    
    if(businessAttributesDictionary[@"Category"] != nil) {
        NSArray *cats = businessAttributesDictionary[@"Category"];
        NSString* catsString = @"";
        for(int i = 0; i < cats.count;i++) {
            catsString = [NSString stringWithFormat:@"%@ %@",catsString,cats[i]];
        }
        personView.categories.text  = catsString;
    }
    
    if(businessAttributesDictionary[@"price"] != nil)
    {
        NSString *k = [self priceFix:businessAttributesDictionary[@"price"]];
        personView.Price.text  = [NSString stringWithFormat:@"%@",k];
    }
    
    if(businessAttributesDictionary[@"hours"] != nil)
    {
        NSString *k = businessAttributesDictionary[@"hours"];
        personView.hours.text  = [NSString stringWithFormat:@"%@",k];
    }
    
    [self.cards removeObjectAtIndex:0];
    return personView;
}

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
    
    button.frame = CGRectMake(CGRectGetMinX(self.cardView.frame), CGRectGetMaxY(self.cardView.frame) + ChoosePersonButtonVerticalPadding, image.size.width, image.size.height);
    
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:247.f/255.f green:91.f/255.f blue:37.f/255.f alpha:1.f]];
    [button addTarget:self action:@selector(nopeFrontCardView) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    
    button.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - image.size.width - ChoosePersonButtonHorizontalPadding, CGRectGetMaxY(self.cardView.frame) + ChoosePersonButtonVerticalPadding, image.size.width, image.size.height);
    
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:29.f/255.f green:245.f/255.f blue:106.f/255.f alpha:1.f]];
    [button addTarget:self action:@selector(likeFrontCardView) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:button];
}

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [ self.frontCardView mdc_swipe:MDCSwipeDirectionLeft ];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [ self.frontCardView mdc_swipe:MDCSwipeDirectionRight ];
}
#pragma mark - locations
/**
 * --------------------------------------------------------------------------
 * Locations
 * --------------------------------------------------------------------------
 */

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"ChoosePersonViewController - Locationmanager - Location: %@", newLocation);
    currentLocation = newLocation;
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.latitude) forKey:@"User Location Latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLocation.coordinate.longitude) forKey:@"User Location Longitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getMoreYelp];
    [manager stopUpdatingLocation];
}

#pragma mark - Network Communication
/**
 * --------------------------------------------------------------------------
 * Network Communication
 * --------------------------------------------------------------------------
 */

-(void)requestScrape:(NSString*)myurl forView:(MDCSwipeToChooseView *)myview {
    NSString *fixedURL = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/scrape"];
    NSURL *url = [NSURL URLWithString:fixedURL];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:myurl forKey:@"url"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger responseStatusCode = [httpResponse statusCode];
            if (responseStatusCode == 200 && data) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    //NSLog(@"Scrape Success");
                    NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@",fetchedData);
                    myview.hours.text = fetchedData[@"hour"];
                    myview.Price.text = [self priceFixer:fetchedData[@"price"]];
                }); //Dispatch main queue block
            } else {
                NSLog(@"ERROR: ChoosePersonViewController - requestScrape");
            }
        }];//upload task Block
        [uploadTask resume];
        //NSLog(@"Connected to server");
    } else {
        NSLog(@"Cannot connect to server");
    }
}

-(void)getMoreYelp {
    if( [ [NSUserDefaults standardUserDefaults] objectForKey:@"Yelp Search Term" ] == nil ) {
        [ [NSUserDefaults standardUserDefaults] setObject:@"Restaurants" forKey:@"Yelp Search Term" ];
        [ [NSUserDefaults standardUserDefaults] synchronize ];
    }
    NSLog(@"ChoosePersonViewController - getMoreYelp - offeset: %d",self.offset);
    NSString *fixedURL = [ NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/yelp/%@/%@/%@/%d",
                          [ [NSUserDefaults standardUserDefaults] objectForKey:@"User Location Latitude" ],
                          [ [NSUserDefaults standardUserDefaults] objectForKey:@"User Location Longitude" ],
                          [ [NSUserDefaults standardUserDefaults] objectForKey:@"Yelp Search Term" ],
                          self.offset ];
    NSURL *url = [NSURL URLWithString:fixedURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if (responseStatusCode == 200 && data) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSArray*fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"choosePersonViewController - getMoreYelp: got more cards");
                [self.cards addObjectsFromArray:fetchedData];
                self.offset += 20;
                if(self.frontCardView == nil) {
                    NSLog(@"choosePersonViewController - getMoreYelp: nofrontcardview");
                    [self loadFront];
                }
                if(self.backCardView == nil) {
                    NSLog(@"choosePersonViewController - getMoreYelp: noBackcardview");
                    [self loadBack];
                }
                if(outOfCards) {
                    outOfCards = false;
                }
                gettingMoreCards = false;
            });
        } else {
            NSLog(@"choosePersonViewController - getMoreYelp: error");
            // error handling
        }
    }]; // Data Task Block
    [dataTask resume];
}

#pragma mark - Fixer methods
/**
 * --------------------------------------------------------------------------
 * Fixer methods and soon to be implemented features
 * --------------------------------------------------------------------------
 */

-(NSString*)priceFix:(NSString*) str {
    NSString* tempStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return tempStr;
}



-(BOOL)businessExists:(NSString*)businessID {
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bizid = %@", businessID];
    [fetch setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext executeFetchRequest:fetch error:&error];
    if(results.count > 0) {
        NSLog(@"choosePersonViewController - businessExists: duplicate");
        return true;
    } else {
        NSLog(@"choosePersonViewController - businessExists: new");
        return false;
    }
}

-(BOOL)isWithInPriceRange:(NSString*) price {
    return true;
     if([price containsString:@"-"]) {
        NSArray* str= [price componentsSeparatedByString:@"-"];
        NSString* min = str[0];
        min = [min stringByReplacingOccurrencesOfString:@"$" withString:@""];
        NSString* max = str[1];
        max = [max stringByReplacingOccurrencesOfString:@"$" withString:@""];
    if(max.intValue <= [NetworkCommunication sharedManager].maxPrice) {
            return true;
        } else {
            return false;
        }
    } else if( [price containsString:@"Under"] ) {
        //NSString* min = @"0";
        NSString* max = [price stringByReplacingOccurrencesOfString:@"Under$" withString:@""];
        
        if(max.intValue<=[NetworkCommunication sharedManager].maxPrice) {
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}

-(BOOL)isWithInDistnaceRange:(NSString*) distance {
    double dbleval = [distance doubleValue];
    dbleval = dbleval/1600.0;
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"maxDistance"] == nil ) {
         [[NSUserDefaults standardUserDefaults] setObject:@"20.0" forKey:@"maxDistance"];
         [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (dbleval <= [ ((NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"maxDistance"]) doubleValue] ) {
        return true;
    } else {
        return false;
    }
}

-(BOOL)isWithInRatingRange:(NSNumber*) rating {
    double dbleval = [rating doubleValue];
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"minRating"] == nil ) {
         [[NSUserDefaults standardUserDefaults] setObject:@"0.0" forKey:@"minRating"];
         [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (dbleval >= [((NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"minRating"]) doubleValue]) {
            return true;
    } else {
            return false;
    }
}

-(NSString*)priceFixer:(NSString*) mystr {
    NSString* newString = [mystr stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return newString;
}


- (IBAction)unwindToChoosePersonViewController:(UIStoryboardSegue *)unwindSegue {
    
}

@end
