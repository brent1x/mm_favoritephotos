//
//  ImageDetailViewController.m
//  FavoritePhotos
//
//  Created by Brent Dady on 5/31/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import "ImageDetailViewController.h"


@interface ImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.imageObject.url);


    NSString *title = [NSString stringWithFormat:@"Photo by %@", self.imageObject.username];
    self.navigationItem.title = title;

    NSURL *imageURL = [NSURL URLWithString:self.imageObject.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    self.imageView.image = [UIImage imageWithData:imageData];

}


@end
