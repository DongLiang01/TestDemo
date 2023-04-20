//
//  XCNavigationController.h
//  君臣论
//
//  Created by LYX on 2017/10/25.
//  Copyright © 2017年 LYX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCNavigationController : UINavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;
- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

@end
