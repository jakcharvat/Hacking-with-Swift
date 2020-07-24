//
//  DetailVC.h
//  Storm Viewer
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property NSString *selectedImage;
@property long totalImages;
@property long selectedImageIndex;

@property BOOL isNavbarHidden;
@property NSArray *imageViewConstraints;

@end

NS_ASSUME_NONNULL_END
