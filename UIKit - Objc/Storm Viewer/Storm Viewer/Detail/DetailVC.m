//
//  DetailVC.m
//  Storm Viewer
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

#import "DetailVC.h"

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Image %ld of %ld", _selectedImageIndex, _totalImages];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    _imageView.image = [UIImage imageNamed:_selectedImage];
    _isNavbarHidden = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [_imageView addGestureRecognizer:tapGesture];
    [_imageView setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGesture];
    
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _imageViewConstraints = @[];
    [self configureImageViewConstraintsAnimated:NO];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(configureImageViewConstraints) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.hidesBarsOnTap = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.hidesBarsOnTap = NO;
}


//MARK: - Tap Handling
- (void)imageViewTapped:(UITapGestureRecognizer *)sender {
    _isNavbarHidden = !_isNavbarHidden;
    [self.navigationController setNavigationBarHidden:_isNavbarHidden animated:YES];
    
    [self configureImageViewConstraints];
}

- (void)configureImageViewConstraints {
    [self configureImageViewConstraintsAnimated:YES];
}

- (void)configureImageViewConstraintsAnimated:(BOOL)animated {
    if (_imageView.image == nil) { return; }
    
    UIColor *backgroundColor;
    
    if (_isNavbarHidden) {
        CGSize imageSize = _imageView.image.size;
        double imageAspectRatio = imageSize.width / imageSize.height;
        
        NSLayoutConstraint *heightConstraint = [_imageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor];
        NSLayoutConstraint *widthConstraint = [_imageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor];
        [heightConstraint setPriority:UILayoutPriorityDefaultLow];
        [widthConstraint setPriority:UILayoutPriorityDefaultLow];
        
        NSLayoutConstraint *centreXAnchor = [_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
        NSLayoutConstraint *centreYAnchor = [_imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor];
        [centreXAnchor setPriority:UILayoutPriorityDefaultHigh];
        [centreYAnchor setPriority:UILayoutPriorityDefaultHigh];
        
        [NSLayoutConstraint deactivateConstraints:_imageViewConstraints];
        
        _imageViewConstraints = @[
            // force it to not exceed the view's size
            [_imageView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_imageView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor],
            [_imageView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor],
            [_imageView.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor],
            
            // make it try to take up as much space as it can
            heightConstraint,
            widthConstraint,
            
            // force it into a fixed aspect ratio to match that of the image
            [_imageView.widthAnchor constraintEqualToAnchor:_imageView.heightAnchor multiplier:imageAspectRatio],
            
            // centre it along the axis where it doesn't take up all available space
            centreYAnchor,
            centreXAnchor
        ];
        
        [NSLayoutConstraint activateConstraints:_imageViewConstraints];
        
        backgroundColor = UIColor.blackColor;
    } else {
        [NSLayoutConstraint deactivateConstraints:_imageViewConstraints];
        
        _imageViewConstraints = @[
            [_imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ];
        
        [NSLayoutConstraint activateConstraints:_imageViewConstraints];
        
        backgroundColor = UIColor.systemBackgroundColor;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view setBackgroundColor:backgroundColor];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) { }];
    } else {
        [self.view setBackgroundColor:backgroundColor];
        [self.view layoutIfNeeded];
    }
}

@end
