//
//  LTEatProtocol.h
//  DLService
//
//  Created by 董良 on 2022/10/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LTEatProtocol <NSObject>

-(void)lt_breakfastEat:(NSString *)str;
-(void)wirteANewWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
