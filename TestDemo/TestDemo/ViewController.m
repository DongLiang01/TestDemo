//
//  ViewController.m
//  TestDemo
//
//  Created by dong liang on 2023/4/20.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.orangeColor;
    
    id<LTEatProtocol> service = [[DLServiceManager sharedManager] createService:@protocol(LTEatProtocol)];
    [service lt_breakfastEat:@"三明治"];
    [service wirteANewWithTitle:@"户外骑行"];
}


@end
