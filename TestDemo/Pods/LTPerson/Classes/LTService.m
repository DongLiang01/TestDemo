//
//  LTService.m
//  LTPerson
//
//  Created by 董良 on 2022/10/6.
//

#import "LTService.h"
#import "DLServiceManager.h"
#import "LTPerson.h"

EXPORT_SERVICE_DL(LTEatProtocol, LTService)

@implementation LTService

- (void)lt_breakfastEat:(NSString *)str{
    LTPerson *lt = [LTPerson new];
    [lt eatBreakfast:str];
}

-(void)wirteANewWithTitle:(NSString *)title{
    LTPerson *lt = [LTPerson new];
    [lt writeNewsWithTitle:title];
}

@end
