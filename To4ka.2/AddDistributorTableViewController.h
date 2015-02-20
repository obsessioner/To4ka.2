//
//  AddDistributorTableViewController.h
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CancelSave.h"
#import "Distributor.h"
#import "MultiSelectSegmentedControl.h"


@interface AddDistributorTableViewController : CancelSave

@property (strong,nonatomic) Distributor *addDistributor;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *distributorCompanyName;
@property (weak, nonatomic) IBOutlet UITextField *distributorFirstName;
@property (weak, nonatomic) IBOutlet UITextField *distributorLastName;
@property (weak, nonatomic) IBOutlet UITextField *distributorPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *distributorSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *distributorOfficePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *distributorSecondOfficePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *distributorNote;
@property (weak, nonatomic) IBOutlet UITextField *distributorEmail;
@property (retain,nonatomic)NSMutableArray *arrayRequest;
@property (strong,nonatomic)NSMutableArray *arrayDelivery;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;
@property (assign, nonatomic) bool hideSecondOfficePhoneSection;

@property (weak, nonatomic) IBOutlet UIButton *addSecondPhoneNumberButtone;
@property (weak, nonatomic) IBOutlet UIButton *addSecondOfficePhoneNumberButtone;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;


@end

