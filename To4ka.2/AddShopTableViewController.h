//
//  AddShopTableViewController.h
//  To4ka.2
//
//  Created by Air on 22.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"
#import "CancelSave.h"


@interface AddShopTableViewController : CancelSave

@property (strong,nonatomic) Shop *addShop;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *shopName;
@property (weak, nonatomic) IBOutlet UITextField *shopPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *shopSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *shopEmail;
@property (weak, nonatomic) IBOutlet UITextView *shopNoteView;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;

@property (weak, nonatomic) IBOutlet UIButton *addSecondShopPhoneNumberButtone;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;

@end
