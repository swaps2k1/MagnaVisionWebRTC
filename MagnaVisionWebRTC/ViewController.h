//
//  ViewController.h
//  MagnaVision
//
//  Created by eSecForte on 22/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSTimer *aTimer;
    UIAlertView *progressAlert;
    UIActivityIndicatorView *tempActi;
    BOOL isWatingHit;
}
@property (retain, nonatomic) IBOutlet UILabel *lblEnterAccesCode;
@property (retain, nonatomic) IBOutlet UIImageView *background;
@property (retain, nonatomic) IBOutlet UITextField *txtPromoCode;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *tempAct;
@property (retain, nonatomic) IBOutlet UIButton *btnGo;
@property (retain, nonatomic) IBOutlet UILabel *lblDown;
-(IBAction)clickToGo:(id)sender;
-(IBAction)info:(id)sender;

@end
