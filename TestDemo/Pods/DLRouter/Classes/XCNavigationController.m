//
//  XCNavigationController.m
//  君臣论
//
//  Created by LYX on 2017/10/25.
//  Copyright © 2017年 LYX. All rights reserved.
//

#import "XCNavigationController.h"

@interface XCNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) void(^animationBlock)(BOOL finished);

@end

@implementation XCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;//不透明的操作栏

    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    
//    [[UIBarButtonItem appearance]setBackButtonTitlePositionAdjustment:UIOffsetMake(-100,0) forBarMetrics:UIBarMetricsDefault];
//
//    [[UINavigationBar appearance] setTintColor:UIColor.blackColor];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    
}

/**
 *  重写Pop方法(显示底部的tabbar)
 */

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
    //判断即将到栈底
    if (self.viewControllers.count == 0) {
        self.hidesBottomBarWhenPushed = NO;
    }
    //  pop出栈
    return [super popViewControllerAnimated:animated];
}

-(NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    if (self.viewControllers.count == 0) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return [super popToRootViewControllerAnimated:animated];
}

//返回按钮方法
- (void)backAction
{
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    [self pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    UIViewController *vc = [self popViewControllerAnimated:animated];
    if (!vc) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return vc;
}

-(NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    NSArray *popedViewControllers = [self popToViewController:viewController animated:animated];
    if (!popedViewControllers || popedViewControllers.count == 0) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return popedViewControllers;
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    NSArray *popedViewControllers = [self popToRootViewControllerAnimated:animated];
    if (!popedViewControllers || popedViewControllers.count == 0) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return popedViewControllers;
}

#pragma mark - UINavigationController Delegate
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.animationBlock){
        self.animationBlock(YES);
        self.animationBlock = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    [self.topViewController.view endEditing:YES];
    
    // 当前控制器是根控制器时，不可以侧滑返回，所以不能使其触发手势
    if(self.childViewControllers.count == 1)
    {
    
        return NO;
    }
   
    return YES;
}



- (BOOL)shouldAutorotate
{
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}




@end
