//
//  LTPerson.m
//  LTPerson
//
//  Created by 董良 on 2022/9/27.
//

#import "LTPerson.h"
#import "DLServiceManager.h"

@implementation LTPerson

-(void)eatBreakfast:(NSString *)foodName{
    NSLog(@"凉亭早饭吃：%@",foodName);
}

-(void)writeNewsWithTitle:(NSString *)title{
    NSLog(@"梁婷写了一篇文章:%@",title);
    
    id<EatProtocal> service = [[DLServiceManager sharedManager] createService:@protocol(EatProtocal)];
    [service createAppWithTitle:@"医企来"];
    [service breakfastEat:@"鸡蛋"];
}

@end
