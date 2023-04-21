//
//  Person.m
//  sdk_Test
//
//  Created by 董良 on 2022/9/25.
//

#import "Person.h"

@implementation Person

-(void)eatBreakfast:(NSString *)foodName{
    NSLog(@"董良早上喜欢吃：%@",foodName);
}

-(void)createAppWithTitle:(NSString *)title{
    NSLog(@"董良做了一个app：%@",title);
}

@end
