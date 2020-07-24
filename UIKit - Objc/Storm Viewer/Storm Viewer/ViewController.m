//
//  ViewController.m
//  Storm Viewer
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

#import "ViewController.h"
#import "DetailVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Storm Viewer";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    _pictures = [NSMutableArray new];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSArray *items = [fm contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *tempPictures = [NSMutableArray new];
    
    for (NSString *item in items) {
        if ([item hasPrefix:@"nssl"]) {
            [tempPictures addObject:item];
        }
    }
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    _pictures = [tempPictures sortedArrayUsingDescriptors:@[sd]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_pictures count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Picture" forIndexPath:indexPath];
    cell.textLabel.text = _pictures[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    
    vc.selectedImage = _pictures[indexPath.row];
    vc.totalImages = [_pictures count];
    vc.selectedImageIndex = indexPath.row + 1;
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
