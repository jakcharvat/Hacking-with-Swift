//
//  ViewController.m
//  Bindings-objc
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *numbers = @[ @1, @2, @3, @4, @9 ];
    NSLog(@"%@", [numbers valueForKey:@"@count"]);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
