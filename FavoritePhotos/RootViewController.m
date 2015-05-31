//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Brent Dady on 5/30/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import "RootViewController.h"
#import "ImageDetailViewController.h"
#import "ImageObject.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableDictionary *instaRootDictionary;
@property NSMutableDictionary *instaSecondNestedDictionary;
@property NSMutableDictionary *instaThirdNestedDictionary;
@property NSMutableDictionary *instaFourthNestedDictionary;
@property NSMutableDictionary *instaFifthNestedDictionary;
@property NSMutableArray *instaNestedArray;

@property NSMutableArray *arrayContainingImageURLs;
@property NSMutableArray *tempArray;
@property NSMutableArray *tempArrayTwo;

@property NSMutableArray *imageObjectsArray;

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

    self.imageObjectsArray = [NSMutableArray new];

    self.tempArray = [NSMutableArray new];

    self.imageView.hidden = YES;
}

#pragma mark SEARCH API METHODS

- (IBAction)searchOnButtonTapped:(id)sender {
    self.interpolatedString = [self.textToSearch.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.tagToSearchFor = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?count=10&client_id=5c15d427b87c46e1bbc09f39ed8741e4", self.interpolatedString];
    [self searchMethod];
}

- (void)searchMethod {
    NSURL *url = [NSURL URLWithString:self.tagToSearchFor];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        self.instaRootDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.instaNestedArray = [self.instaRootDictionary objectForKey:@"data"];
        ImageObject *imageObject = [ImageObject new];

        for (NSDictionary *dictionary in self.instaNestedArray) {

            // capturing URL of images
            self.instaSecondNestedDictionary = [dictionary objectForKey:@"images"];
            self.instaThirdNestedDictionary = [self.instaSecondNestedDictionary objectForKey:@"standard_resolution"];
            imageObject.url = [self.instaThirdNestedDictionary objectForKey:@"url"];
            [self.arrayContainingImageURLs addObject:[self.instaThirdNestedDictionary objectForKey:@"url"]];

            // capturing usernames
            self.instaFourthNestedDictionary = [dictionary objectForKey:@"user"];
            imageObject.username = [self.instaFourthNestedDictionary objectForKey:@"username"];

            // converting URLs to NSData to properly display in Table View
            NSURL *imageURL = [NSURL URLWithString:[self.instaThirdNestedDictionary objectForKey:@"url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            self.imageView.image = [UIImage imageWithData:imageData];

            // adding image objects to an array
            [self.imageObjectsArray addObject:imageObject];
        }

        [self.tableView reloadData];
    }];
}

#pragma mark TABLE VIEW METHODS

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageObjectsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self.arrayContainingImageURLs objectAtIndex:indexPath.row]]];
    cell.imageView.image = [UIImage imageWithData:imageData];
    NSLog(@"index row touched: %ld", (long)indexPath.row);
    return cell;
}

#pragma mark PREPARE FOR SEGUE METHOD

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ImageDetailViewController *imgVC = segue.destinationViewController;
    imgVC.imageObject = [self.imageObjectsArray objectAtIndex:indexPath.row];
}

@end
