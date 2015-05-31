//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Brent Dady on 5/30/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property NSMutableDictionary *instaRootDictionary;
@property NSMutableDictionary *instaSecondNestedDictionary;
@property NSMutableDictionary *instaThirdNestedDictionary;
@property NSMutableDictionary *instaFourthNestedDictionary;
@property NSMutableArray *instaNestedArray;

@property NSMutableArray *arrayContainingFilters;
@property NSMutableArray *arrayContainingUsername;
@property NSMutableArray *arrayContainingImageURLs;

@property (weak, nonatomic) IBOutlet UITextField *textToSearch;
@property NSString *interpolatedString;
@property NSMutableString *tagToSearchFor;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RootViewController

// https://api.instagram.com/v1/tags/todayskicks/media/recent?client_id=5c15d427b87c46e1bbc09f39ed8741e4
// https://api.instagram.com/v1/tags/todaykicks/media/recent?count=10&client_id=5c15d427b87c46e1bbc09f39ed8741e4

//  Dictionary where 3rd object 'Data' is an array
//  Inside data, we have dictionaries
//      'location' contains 'latitude' and 'longitude' keys
//      'images' contains 3 dictionaries, with 'standard_resolution' containing the 'url' key that has the photo
//      'caption' contains the key 'text'
//      'user' contains the key 'username'

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tagToSearchFor = [NSMutableString new];
    self.interpolatedString = [NSString new];

    self.instaRootDictionary = [NSMutableDictionary new];
    self.instaNestedArray = [NSMutableArray new];
    self.instaSecondNestedDictionary = [NSMutableDictionary new];
    self.instaThirdNestedDictionary = [NSMutableDictionary new];
    self.instaFourthNestedDictionary = [NSMutableDictionary new];

    self.arrayContainingFilters = [NSMutableArray new];
    self.arrayContainingUsername = [NSMutableArray new];
    self.arrayContainingImageURLs = [NSMutableArray new];
}

- (IBAction)searchOnButtonTapped:(id)sender {
    self.interpolatedString = [self.textToSearch.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.tagToSearchFor = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?count=10&client_id=5c15d427b87c46e1bbc09f39ed8741e4", self.interpolatedString];
    NSLog(@"%@", self.tagToSearchFor);
    [self searchMethod];
}

- (void)searchMethod {
    NSURL *url = [NSURL URLWithString:self.tagToSearchFor];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        self.instaRootDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.instaNestedArray = [self.instaRootDictionary objectForKey:@"data"];

        for (NSDictionary *dictionary in self.instaNestedArray) {

            NSString *filter = [dictionary objectForKey:@"filter"];
            [self.arrayContainingFilters addObject:filter];

            self.instaSecondNestedDictionary = [dictionary objectForKey:@"user"];
            [self.arrayContainingUsername addObject:[self.instaSecondNestedDictionary objectForKey:@"username"]];

            NSLog(@"%@", self.arrayContainingUsername);

            self.instaThirdNestedDictionary = [dictionary objectForKey:@"images"];
            self.instaFourthNestedDictionary = [self.instaThirdNestedDictionary objectForKey:@"standard_resolution"];
        }
        // self.testLabel.text = [NSString stringWithFormat:@"%@", [self.arrayContainingFilters lastObject]];
        // self.testLabelTwo.text = [NSString stringWithFormat:@"%@", [self.instaSecondNestedDictionary objectForKey:@"username"]];
        // self.testLabelThree.text = [NSString stringWithFormat:@"%@", [self.instaFourthNestedDictionary objectForKey:@"height"]];

        NSURL *imageURL = [NSURL URLWithString:[self.instaFourthNestedDictionary objectForKey:@"url"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        self.imageView.image = [UIImage imageWithData:imageData];
        
        // [self.tableView reloadData];
    }];
}

@end
