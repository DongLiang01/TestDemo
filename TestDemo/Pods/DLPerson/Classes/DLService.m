//
//  DLService.m
//  DLPerson
//
//  Created by 董良 on 2022/10/6.
//

#import "DLService.h"
#import "DLServiceManager.h"
#import "Person.h"

EXPORT_SERVICE_DL(EatProtocal, DLService)

@implementation DLService

#pragma mark 实现EatProtocal协议方法
-(void)breakfastEat:(NSString *)str{
    Person *dl = [[Person alloc] init];
    [dl eatBreakfast:str];
}

-(void)createAppWithTitle:(NSString *)title{
    Person *dl = [[Person alloc] init];
    [dl createAppWithTitle:title];
}

@end
