//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Brent Dady on 5/30/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableDictionary *instaRootDictionary;
@property NSMutableDictionary *instaSecondNestedDictionary;
@property NSMutableDictionary *instaThirdNestedDictionary;
@property NSMutableDictionary *instaFourthNestedDictionary;
@property NSMutableArray *instaNestedArray;

@property NSMutableArray *arrayContainingImageURLs;
@property NSMutableArray *tempArray;
@property NSMutableArray *tempArrayTwo;

@property (weak, nonatomic) IBOutlet UITextField *textToSearch;
@property NSMutableString *tagToSearchFor;
@property NSString *interpolatedString;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

    self.arrayContainingImageURLs = [NSMutableArray new];


    self.tempArray = [NSMutableArray new];
    self.tempArrayTwo = [NSMutableArray new];

    self.imageView.hidden = YES;
}

#pragma mark SEARCH API METHODS

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

            // capturing URL of images
            self.instaSecondNestedDictionary = [dictionary objectForKey:@"images"];
            self.instaThirdNestedDictionary = [self.instaSecondNestedDictionary objectForKey:@"standard_resolution"];
            [self.arrayContainingImageURLs addObject:[self.instaThirdNestedDictionary objectForKey:@"url"]];
            NSLog(@"%@", self.arrayContainingImageURLs);

            // capturing name of filter
            [self.tempArrayTwo addObject:[dictionary objectForKey:@"filter"]];

            // capturing usernames
            self.instaFourthNestedDictionary = [dictionary objectForKey:@"user"];
            [self.tempArray addObject:[self.instaFourthNestedDictionary objectForKey:@"username"]];

        }

        NSURL *imageURL = [NSURL URLWithString:[self.instaThirdNestedDictionary objectForKey:@"url"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        self.imageView.image = [UIImage imageWithData:imageData];
        
        [self.tableView reloadData];
    }];
}

#pragma mark TABLE VIEW METHODS

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tempArrayTwo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.tempArray[indexPath.row];
    cell.detailTextLabel.text = self.tempArrayTwo[indexPath.row];

    NSData *imageData= [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self.arrayContainingImageURLs objectAtIndex:indexPath.row]]];
    cell.imageView.image = [UIImage imageWithData:imageData];

    return cell;
}

@end
