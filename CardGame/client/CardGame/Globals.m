//
//  Globals.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-17.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "Globals.h"

@implementation Globals

@synthesize serverIsRunning;

@synthesize udid;

@synthesize userName;

@synthesize serverChannel;

@synthesize gameChannel;

@synthesize isCreator;

@synthesize card1;

@synthesize card2;

@synthesize initialBlind;

@synthesize initialFunds;

+(Globals *)sharedInstance {
    static Globals *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

-(id)init {
    if (self = [super init]) {
        
        self.udid = [[NSString alloc] init];
        self.userName = @"";
        self.serverChannel = [PNChannel channelWithName:@"PokerServer" shouldObservePresence:YES];
        self.isCreator = NO;
    }
    return self;
}

-(void)setuDID: (NSString *) uid{
    udid = [NSString stringWithString: uid];
}

-(void)setUserName: (NSString *) str {
    userName = [NSString stringWithString: str];
}

-(void)setGameChannel: (PNChannel *) chan {
    gameChannel = chan;
}

-(void)setCreator: (BOOL) flag {
    isCreator = flag;
}

-(void)setCard1: (NSString *) str {
    card1 = [NSString stringWithString: str];
}

-(void)setCard2: (NSString *) str {
    card2 = [NSString stringWithString: str];
}

-(void)setInitialBlind: (NSString *) str {
    initialBlind = [NSString stringWithString: str];
}

-(void)setInitialFunds: (NSString *) str {
    initialFunds = [NSString stringWithString: str];
}

-(void) loadVariables {
    
    NSMutableDictionary *dictionary;
    
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
    }
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    [[Globals sharedInstance] setuDID:[dictionary objectForKey:@"udid"]];
    [[Globals sharedInstance] setUserName:[dictionary objectForKey:@"userName"]];

}

-(void) saveVariables {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects:
                                [[Globals sharedInstance] udid],
                                [[Globals sharedInstance] userName],
                                nil]
                                                          forKeys:[NSArray arrayWithObjects: @"udid",
                                                                   @"userName",
                                                                   nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    //[plistData writeToFile:@"/Users/ajanjayant/Code/DevelopmentiOS/CardGame/CardGame/Data.plist"  atomically:YES];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    
}

-(void) checkIfHereNow{
    
    [PubNub requestParticipantsListForChannel:[[Globals sharedInstance] serverChannel]withCompletionBlock:^(NSArray *udids,
                                                                                                            PNChannel *channel,
                                                                                                            PNError *error) {
        if (error == nil) {
            
            if([udids count] == 0) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"serverNotRunning" object:self];
                
                serverIsRunning = NO;
            }
            else {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"serverIsRunning" object:self];
                
                serverIsRunning = YES;
            }
        }
        else {
            
            // Handle participants request error
        }
    }];;
}


@end
