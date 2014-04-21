//
//  VideoViewController.h
//  MagnaVision
//
//  Created by eSecForte on 22/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/Opentok.h>

@interface VideoViewController : UIViewController <OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate>
{
    NSString *strToke;
    NSString *strSession;
    IBOutlet UIButton *btnConnection;
    IBOutlet UIButton *btnDisconnect;
    NSString *strFrmuType;
    NSString *strPassKey_Id;
    BOOL isDisConnected;
}
@property (retain, nonatomic) IBOutlet UILabel *lblConnectivity;
@property (retain, nonatomic) IBOutlet UIButton *btnExit;
@property (nonatomic,retain)NSString *strToke;
@property (nonatomic,retain)NSString *strSession;
@property (nonatomic,retain)    NSString *strFrmuType;
@property (nonatomic,retain)    NSString *strPassKey_Id;
@property (weak, nonatomic) IBOutlet UIView *streamView;

- (void)doConnect;
- (void)doDisconnect;
- (void)doPublish;
- (void)doUnpublish;
- (IBAction)disconnectButtonClicked:(UIButton*)button;
- (IBAction)connectButtonClicked:(UIButton*)button;
- (IBAction)exitButtonClicked:(UIButton*)button;
@end
