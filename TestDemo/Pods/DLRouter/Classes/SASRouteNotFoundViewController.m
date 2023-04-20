//
//  SASRouteNotFoundViewController.m
//  RightBTC
//
//  Created by 董良 on 2022/9/15.
//  Copyright © 2022 LYX. All rights reserved.
//

#import "SASRouteNotFoundViewController.h"

@interface SASRouteNotFoundViewController ()

@end

@implementation SASRouteNotFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = @"页面丢失";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    label.text = @"页面丢失了～";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.center = self.view.center;
    label.textColor = UIColor.blackColor;
    [self.view addSubview:label];
}

- (BOOL)willDealloc {
    return NO;
}

@end
