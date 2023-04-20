//
//  UIViewController+SetParams.h
//  RightBTC
//
//  Created by 董良 on 2022/9/15.
//  Copyright © 2022 LYX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SetParams)

@property (strong ,nonatomic) NSDictionary *routerParamDic;
@property (strong ,nonatomic) NSDictionary *popResultParamDic;

@end

NS_ASSUME_NONNULL_END
