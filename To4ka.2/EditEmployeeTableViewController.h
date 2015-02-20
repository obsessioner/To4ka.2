//
//  EditEmployeeTableViewController.h
//  To4ka.2
//
//  Created by Air on 28.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"
#import "CancelSave.h"


@interface EditEmployeeTableViewController : CancelSave


@property (nonatomic,strong)Employee *editEmployee;
@property (strong, nonatomic)IBOutletCollection(UITextField) NSArray *arreyTextField;

@property (weak, nonatomic) IBOutlet UITextField *employeeShop;
@property (weak, nonatomic) IBOutlet UITextField *employeeFirstName;
@property (weak, nonatomic) IBOutlet UITextField *employeeLastName;
@property (weak, nonatomic) IBOutlet UITextField *employeePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *employeeSecondPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *employeeEmail;
@property (weak, nonatomic) IBOutlet UITextView *employeeNoteView;
@property (weak, nonatomic) NSDate *employeeDateOfBirth;

@property (assign, nonatomic) BOOL atPresent;
@property (assign, nonatomic) bool hideSecondPhoneSection;
@property (assign, nonatomic) bool hideSectionAddPhone;

@property (weak, nonatomic) IBOutlet UIButton *addSecondPhoneNumberButtone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)editSave:(UIBarButtonItem *)sender;

@end
