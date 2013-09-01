/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Joakim Fernstad
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

//
//  BTC2ViewController.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/18/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import "BTC2ViewController.h"
#import "ImageRequest.h"
#import "BTC2RobotView.h"
#import "UIColor+BTC2Extensions.h"
#import <QuartzCore/QuartzCore.h>

typedef enum BTC2Scene {
    BTC2SceneName = 0,
    BTC2SceneWallet,
    BTC2SceneDiscovery,
    BTC2SceneSend,
    BTC2SceneReceive
}BTC2Scene;

@interface BTC2ViewController ()
@property (nonatomic, assign) BTC2Scene currentScene;
@property (nonatomic, strong) UIView* currentView;
-(UIView*)nameScene;
-(UIView*)walletScene;
-(UIView*)discoveryScene;
-(UIView*)sendScene;
-(UIView*)receiveScene;
@end

@implementation BTC2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor btc2RandomColor].CGColor,
                        (id)[UIColor btc2RandomColor].CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.currentScene = BTC2SceneName;
}

- (void)setCurrentScene:(BTC2Scene)currentScene{

    UIView* thisScene = self.currentView;
    UIView* nextView = nil;
    
    switch (currentScene) {
        case BTC2SceneName:
            nextView = [self nameScene];
            break;
        case BTC2SceneWallet:
            nextView = [self walletScene];
            break;
        case BTC2SceneDiscovery:
            nextView = [self discoveryScene];
            break;
        case BTC2SceneSend:
            nextView = [self sendScene];
            break;
        case BTC2SceneReceive:
            nextView = [self receiveScene];
            break;
            
        default:
            break;
    }
    
    nextView.alpha = 0;
    [self.view addSubview:nextView];
    
    [UIView animateWithDuration:1
                     animations:^{
                         thisScene.alpha = 0;
                         nextView.alpha = 1;
                     } completion:^(BOOL finished) {
                         [thisScene removeFromSuperview];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scenes

-(UIView*)nameScene{
    UIView* thisView = [[UIView alloc] initWithFrame:self.view.bounds];
    thisView.backgroundColor = [UIColor redColor];
    
    CGRect roboRect = CGRectMake(50, 50, 0, 0);
    
    BTC2RobotView* robo = [[BTC2RobotView alloc] initWithFrame:roboRect];
    robo.roboName = @"haxxor";
    robo.roboSize = CGSizeMake(100, 100);
    [robo retrieveRobot];
    
    [thisView addSubview:robo];
    
    return thisView;
}
-(UIView*)walletScene{
    UIView* thisView = [[UIView alloc] initWithFrame:self.view.bounds];
    thisView.backgroundColor = [UIColor greenColor];
    return thisView;
}
-(UIView*)discoveryScene{
    UIView* thisView = [[UIView alloc] initWithFrame:self.view.bounds];
    thisView.backgroundColor = [UIColor blueColor];
    return thisView;
}
-(UIView*)sendScene{
    UIView* thisView = [[UIView alloc] initWithFrame:self.view.bounds];
    thisView.backgroundColor = [UIColor yellowColor];
    return thisView;
}
-(UIView*)receiveScene{
    UIView* thisView = [[UIView alloc] initWithFrame:self.view.bounds];
    thisView.backgroundColor = [UIColor orangeColor];
    return thisView;
}


@end
