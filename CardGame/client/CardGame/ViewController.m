//
//  ViewController.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize serverErrModel;

@synthesize logModel;

@synthesize homeModel;

@synthesize loadModel;

@synthesize roomModel;

@synthesize appLabel;

@synthesize loginField;

@synthesize addUser;

@synthesize loginUser;

@synthesize loginProgress;

@synthesize createGameButton;

@synthesize joinPrivateGameButton;

@synthesize gameName;

@synthesize bgImageView;

@synthesize firstNameLabel;

@synthesize secondNameLabel;

@synthesize thirdnameLabel;

@synthesize fourthNameLabel;

@synthesize fifthNameLabel;

@synthesize sixthNameLabel;

@synthesize seventhNameLabel;

@synthesize eightNameLabel;

@synthesize startGameButton;

@synthesize mainView;

@synthesize ownCardTwoView;

@synthesize ownCardOneView;

@synthesize deckCardOne;

@synthesize deckCard2;

@synthesize deckCard3;

@synthesize deckCard4;

@synthesize deckCard5;

@synthesize potImageView;

@synthesize potLabel;

@synthesize initialBankLabel;

@synthesize recentBetLabel;

@synthesize bankLabel;

@synthesize raiseTextField;

@synthesize raiseButton;

@synthesize callButton;

@synthesize foldButton;

@synthesize blindImage;

@synthesize messageNotifyingUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup for login screen

    if([[self title] isEqualToString: @"login"]){
        
        appLabel.text = @"PubNub Poker";
        [loginField configureTextField: @"Type user name here" color:[UIColor blackColor] hideSelf:YES];
        [addUser setTitle:@"Add" forState:UIControlStateNormal];
        [loginUser setTitle:@"Login" forState:UIControlStateNormal];
        if([[[Globals sharedInstance] udid] isEqualToString: @""]) {
            CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
            NSString * uid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;
            [[Globals sharedInstance] setuDID: uid];
            
        }
        
        loginProgress.hidden = YES;
        
        logModel = [[LoginModel alloc] init];
        
    }
    // Setup for home screen
    // Setup for button
    else if([[self title] isEqualToString: @"home"]){
        
        [createGameButton setTitle: @"Create a game" forState: UIControlStateNormal];
        [joinPrivateGameButton setTitle: @"Join private" forState:
         UIControlStateNormal];
    
        [gameName configureTextField: @"Type game name here" color:[UIColor whiteColor]returnHidesKB:YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:createGameButton, joinPrivateGameButton, nil]];
        
        homeModel = [[HomeModel alloc] init];
    }
    // Make all labels hidden
    else if([[self title] isEqualToString: @"load"]){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelNames) name:@"updateLabelNames" object:nil];

        
        firstNameLabel.hidden = YES;
        secondNameLabel.hidden = YES;
        thirdnameLabel.hidden = YES;
        fourthNameLabel.hidden = YES;;
        fifthNameLabel.hidden = YES;
        sixthNameLabel.hidden = YES;
        seventhNameLabel.hidden = YES;
        eightNameLabel.hidden = YES;
        startGameButton.hidden = YES;
        [startGameButton setTitle:@"Start!" forState:UIControlStateNormal];
        
        loadModel = [[LoadModel alloc] init];
    }
    // For game setup
    else if([[self title] isEqualToString: @"room"]) {
        
        roomModel =[[RoomModel alloc] init];
        deckCardOne.hidden = YES;
        deckCard2.hidden = YES;
        deckCard3.hidden = YES;
        deckCard4.hidden = YES;
        deckCard5.hidden = YES;
        potLabel.hidden = YES;
        initialBankLabel.hidden = YES;
         bankLabel.hidden = YES;
        recentBetLabel.hidden = YES;
        raiseTextField.hidden = YES;
        raiseButton.hidden = YES;
        callButton.hidden = YES;
        foldButton.hidden = YES;
        blindImage.hidden = YES;
        
        [raiseButton setTitle:@"Raise" forState:UIControlStateNormal];
        [callButton setTitle:@"Call" forState:UIControlStateNormal];
        [foldButton setTitle:@"Fold" forState:UIControlStateNormal];
        
        [self setCards: roomModel.card1 cardView:ownCardOneView];
        [self setCards: roomModel.card2 cardView:ownCardTwoView];
        
        if([roomModel.blind isEqualToString: @"smallblind"] || [roomModel.blind isEqualToString: @"bigblind"]){
            [self setBlind: roomModel.blind];
            roomModel.isBlind = YES;
        }
        
        initialBankLabel.text = roomModel.initialFunds;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLabels) name:@"updateGameLabels" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFlopCards) name:@"updateFlopCards" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTurnCard) name:@"updateTurnCard" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRiverCard) name:@"updateRiverCard" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlind) name:@"removeBlind" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlind) name:@"updateMinRaise" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableInteractionForTurn) name:@"enableInteractionForTurn" object:nil];

        [raiseTextField configureTextField: @"Current Bet: $0" color:[UIColor blackColor] returnHidesKB: YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:potLabel, ownCardOneView, ownCardTwoView, ownCardTwoView, deckCardOne, deckCard2, deckCard3, deckCard4, deckCard5, potImageView, recentBetLabel, potImageView, initialBankLabel, bankLabel, raiseButton, callButton, foldButton,  nil]];

    }
    
    else if([[self title] isEqualToString: @"serverError"]) {
        
        serverErrModel = [[ServerErrorModel alloc] init];

        messageNotifyingUser.text = @"Server not running :( \n There seems to be a error in the space time continuum; we're doing everything we can to rectify it";
    }
        
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(saveVaraiables) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlind) name:@"removeBlind" object:nil];
}

-(void)enableInteractionForTurn{
    [self enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                                           raiseTextField,
                                                            raiseButton,
                                                            callButton,
                                                            foldButton,
                                                            nil]];

}

-(void)updateFlopCards{
    
    [self setCards:roomModel.communityCard1 cardView:deckCardOne];
    deckCardOne.hidden = NO;
    [self setCards:roomModel.communityCard2 cardView:deckCard2];
    deckCard2.hidden = NO;
    [self setCards:roomModel.communityCard3 cardView:deckCard3];
    deckCard3.hidden = NO;
}

-(void)updateTurnCard{
    [self setCards:roomModel.communityCard4 cardView:deckCard4];
    deckCard4.hidden = NO;

}

-(void)updateRiverCard{
    [self setCards:roomModel.communityCard5 cardView:deckCard5];
    deckCard5.hidden = NO;

}

-(void)updateMinRaise{
    raiseTextField.placeholder = roomModel.minRaise;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateLabelNames {

    switch(loadModel.numberOfNames)
    {
        case 8:
            eightNameLabel.text = loadModel.playerNames[7];
            eightNameLabel.hidden = NO;
        case 7:
            seventhNameLabel.text = loadModel.playerNames[6];
            seventhNameLabel.hidden = NO;
        case 6:
            sixthNameLabel.text = loadModel.playerNames[5];
            sixthNameLabel.hidden = NO;

        case 5:
            fifthNameLabel.text = loadModel.playerNames[4];
            fifthNameLabel.hidden = NO;

        case 4:
            fourthNameLabel.text = loadModel.playerNames[3];
            fourthNameLabel.hidden = NO;

        case 3:
            thirdnameLabel.text = loadModel.playerNames[2];
            thirdnameLabel.hidden = NO;

        case 2:
            secondNameLabel.text = loadModel.playerNames[1];
            secondNameLabel.hidden = NO;
            [self setGameButton];
        case 1:
            firstNameLabel.text = loadModel.playerNames[0];
            firstNameLabel.hidden = NO;
    }
}

#pragma mark - Start screen buttons

- (IBAction)addUser:(id)sender {
    [self genericLogin:@"create-user"];
}

- (IBAction)loginUser:(id)sender {
    
    
    [self genericLogin:@"login"];
}

#pragma mark - Home screen buttons

- (IBAction)createGameButton:(id)sender {
    
    if([gameName.text isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [[Globals sharedInstance] setCreator: YES];
        [self doGameSetup:@"create" game:gameName.text];
        [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, nil]] ;
        [[Globals sharedInstance] checkIfHereNow];

    }
}

- (IBAction)joinPrivateGameButton:(id)sender {
    
    if([gameName.text isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self doGameSetup:@"joinable" game:gameName.text];
        [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, nil]];
        [[Globals sharedInstance] checkIfHereNow];
    }

}

#pragma mark - Load screen buttons

- (IBAction)startButton:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    NSString * user =  [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    [dict setObject:@"start" forKey:@"type"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey:@"username"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects:startGameButton, nil]];
    
    [[Globals sharedInstance] checkIfHereNow];

}

#pragma Mark- room Buttons


- (IBAction)raiseButton:(id)sender {
    
    if([raiseTextField.text isEqualToString: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"You must raise a value" message: @"Type a value in the field" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    int raise = [raiseTextField.text intValue];
        
    int maxRaise = [bankLabel.text intValue];
    
    if(raise < [roomModel.minRaise intValue]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid raise amount" message: @"The value is less than the minimum raise" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
        
    }

    if(raise > maxRaise){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid raise amount" message: @"The value is greater than the money you have" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"raise" forKey:@"type"];
    
    [dict setObject:raiseTextField.text forKey:@"amount"];
    
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];
    
    raiseTextField.text = @"";
    
    [[Globals sharedInstance] checkIfHereNow];

}

- (IBAction)callButton:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"call" forKey:@"type"];
        
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];

    [[Globals sharedInstance] checkIfHereNow];

}

- (IBAction)foldButton:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"fold" forKey:@"type"];
    
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];
    
    [[Globals sharedInstance] checkIfHereNow];
}


// Helper Funtions
#pragma mark - Auxilliary Functions

-(void) enableInteraction:(BOOL) shouldInteract arrayOfViews:(NSArray *)arrayOfViews{
    
    for(UIView * view in arrayOfViews){
        [view setUserInteractionEnabled:shouldInteract];

    }
}

-(void) genericLogin:(NSString *) type {
    [loginField resignFirstResponder];
    
    if([loginField.text isEqualToString: @""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User not logged in" message: @"User name must be specified" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:loginField.text forKey: @"username"];
        [dict setObject: [[Globals sharedInstance] udid] forKey:@"uuid"];
        [dict setObject: type forKey:@"type"];

        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
        loginProgress.hidden = NO;
    }
}

-(void) doGameSetup:(NSString *)type game:(NSString * ) game{
    
    NSString * user =  [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:game forKey: @"game"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey: @"username"];
    [dict setObject:type forKey:@"type"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
    PNChannel * chan = [PNChannel channelWithName:gameName.text shouldObservePresence:YES];
    
    [[Globals sharedInstance] setGameChannel: chan];
    
}

-(void) setCards :(NSString *) card cardView:(UIImageView *) cardView{
    
    card = [card stringByAppendingString: @".png"];
        
    [cardView setImage:[UIImage imageNamed:card]];
    
}

-(void) setInitialFunds:(NSString *) initialFunds {
    
    initialBankLabel.hidden = NO;
    initialBankLabel.text = initialFunds;
}

-(void) setBlind: (NSString *) img {
    
    blindImage.hidden = NO;
    img = [img stringByAppendingString: @".png"];
    
    UIImage *image1 = [UIImage imageNamed:img];
    
    [blindImage setImage:image1];
}

-(void) setGameButton {
    
    startGameButton.hidden = NO;
    startGameButton.enabled = YES;
}

-(void) saveVaraiables {
    
    [[Globals sharedInstance] saveVariables];
}


- (void)setLabels {
    
    potLabel.text = roomModel.pot;
    potLabel.hidden = NO;
    
    recentBetLabel.text = roomModel.lastAct;
    recentBetLabel.hidden = NO;
    
    bankLabel.text = roomModel.myFunds;
    bankLabel.hidden = NO;
    
    raiseTextField.text = [@"Curent bet: " stringByAppendingString: roomModel.currBet];
    
    raiseTextField.hidden = NO;
    
}

- (void)removeBlind {
    
    blindImage.hidden = YES;
    
    raiseButton.hidden = NO;
    
    callButton.hidden = NO;

    foldButton.hidden = NO;
    
}

-(void) setUIDAndUserName:(NSMutableDictionary *) dict {
    
    [dict setObject: [[Globals sharedInstance] udid] forKey: @"uuid"];
    [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex {
    if(alertView.tag == 1) {
        if(buttonIndex == 0){
            [self enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, raiseTextField, startGameButton, raiseButton, callButton, foldButton, nil]];
        }
    }
}

@end
