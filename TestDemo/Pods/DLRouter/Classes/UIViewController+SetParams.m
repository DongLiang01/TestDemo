//
//  UIViewController+SetParams.m
//  RightBTC
//
//  Created by 董良 on 2022/9/15.
//  Copyright © 2022 LYX. All rights reserved.
//

#import "UIViewController+SetParams.h"
#import <objc/runtime.h>

static NSString *pushPassValueKey = @"pushPassValueKey";
static NSString *popPassValueKey = @"popPassValueKey";

@implementation UIViewController (SetParams)

- (void)setRouterParameter:(NSDictionary *_Nullable)params{
    self.routerParamDic = params;
    NSLog(@"push: [%@]收到了参数%@",[self class],self.routerParamDic);
}

- (void)onNextPopResult:(NSDictionary *_Nullable)params{
    self.popResultParamDic = params;
    NSLog(@"pop: [%@]收到了参数%@",[self class],self.popResultParamDic);
}

-(void)setRouterParamDic:(NSDictionary *)routerParamDic{
    objc_setAssociatedObject(self, &pushPassValueKey, routerParamDic, OBJC_ASSOCIATION_RETAIN);
}

-(NSDictionary *)routerParamDic{
    return objc_getAssociatedObject(self, &pushPassValueKey);
}

-(void)setPopResultParamDic:(NSDictionary *)popResultParamDic{
    objc_setAssociatedObject(self, &popPassValueKey, popResultParamDic, OBJC_ASSOCIATION_RETAIN);
}

-(NSDictionary *)popResultParamDic{
    return objc_getAssociatedObject(self, &popPassValueKey);
}

@end
