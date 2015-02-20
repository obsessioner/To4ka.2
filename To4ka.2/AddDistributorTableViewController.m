//
//  AddDistributorTableViewController.m
//  To4ka.2
//
//  Created by Air on 30.12.14.
//  Copyright (c) 2014 Bogdanov. All rights reserved.
//

#import "AddDistributorTableViewController.h"
#import "MultiSelectSegmentedControl.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>


@import AddressBook;

@interface AddDistributorTableViewController () <UITextFieldDelegate, EKEventEditViewDelegate, MultiSelectSegmentedControlDelegate>

@property (strong, nonatomic) IBOutlet MultiSelectSegmentedControl *daysRequestControl;
@property (strong, nonatomic) IBOutlet MultiSelectSegmentedControl *daysDeliveryControl;

// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;
// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;
// Array of all events happening within the next 24 hours
@property (nonatomic, strong) NSMutableArray *eventsList;
// Used to add events to Calendar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation AddDistributorTableViewController

@synthesize addDistributor;
@synthesize hideSecondPhoneSection;
@synthesize hideSecondOfficePhoneSection;
@synthesize arrayRequest;
@synthesize arrayDelivery;




- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self arrayRequestDays];
    [self arrayDeliveryDays];
    
    hideSecondPhoneSection = YES;
    hideSecondOfficePhoneSection = YES;
    for (UITextField *anyTextField in self.arreyTextField) {
        anyTextField.delegate = self;
    }
    // Initialize the event store
    self.eventStore = [[EKEventStore alloc] init];
    // Initialize the events list
    self.eventsList = [[NSMutableArray alloc] initWithCapacity:0];
    // The Add button is initially disabled
    self.addButton.enabled = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Check whether we are authorized to access Calendar
    [self checkEventStoreAccessForCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - AddressBook Button AddDistributorAddressBook


- (IBAction)addToPhoneBookButton:(UIButton *)sender {
    
    if ([addDistributor.distributorCompanyName = _distributorCompanyName.text length] == 0 && [addDistributor.distributorFirstName = _distributorFirstName.text length] == 0 &&
        [addDistributor.distributorLastName = _distributorLastName.text length] == 0 )
    {
        UIAlertView *empty = [[UIAlertView alloc]initWithTitle:@"Fill Up The Form" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [empty show];
        NSLog(@"Empty ");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
             ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1 This checks to see if the user has either denied your app access to the Address Book in the past, or it is restricted because of parental controls. In this case, all you can do is inform the user that you can’t add the contact because the app does not have permission.
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
        //NSLog(@"Denied");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2 This checks to see if the user has already given your app permission to use their Address Book. In this case, you are free to modify the Address Book however you want.
        [self createGroupAddressBook];
        [self addDistributorToContacts];
        NSLog(@"Authorized");
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3 This checks to see if the user hasn’t decided yet whether not to give permission to your app.
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4 executes only if the user denies permission when your app asks.
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [cantAddContactAlert show];
                // NSLog(@"Just denied");
                return;
            }
            //5 executes if the user gives permission for you to use the Address Book.
            NSLog(@"Just authorized");
        });
        NSLog(@"Not determined");
    }
}

#pragma mark -
#pragma mark - AddressBook Create Group Phone Book


- (void)createGroupAddressBook {
    
    NSString *newGroupName = @"To4ka";
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook){
        BOOL groupNameIsEqual = NO;
        
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)ABRecordCopyValue(group,
                                                                             kABGroupNameProperty);
                
                if ([groupName isEqualToString:newGroupName]) {
                    groupNameIsEqual = YES;
                    break;
                }
            }
        }
        CFRelease(allGroups);
        
        if (groupNameIsEqual) {
            NSLog(@"This Group in Address Book Already Exists");
        } else {
            ABRecordRef group = ABGroupCreate();
            if (!group){
                NSLog(@"Error Creating Group in Address Book");
                return;
            }
            
            CFErrorRef error = nil;
            BOOL couldSetGroupName = ABRecordSetValue(group,
                                                      kABGroupNameProperty,
                                                      (__bridge CFStringRef)newGroupName,
                                                      &error);
            if (couldSetGroupName){
                if (ABAddressBookAddRecord(addressBook, group, &error)){
                    NSLog(@"New Group in Address Book Added");
                    [self saveAddressBook:addressBook];
                } else {
                    NSLog(@"Unable Add New Group in Address Book");
                }
            } else {
                NSLog(@"Error Installing Name Group");
            }
        }
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Distributor Info For Phone Book


- (void)addDistributorToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook) {
        NSString *firstName = _distributorFirstName.text;
        NSString *lastName = _distributorLastName.text;
        NSString *phone = _distributorPhoneNumber.text;
        NSString *companyName = _distributorCompanyName.text;
        NSString *note = _distributorNote.text;
        NSString *secondPhone = _distributorSecondPhoneNumber.text;
        NSString *officePhoneNumber = _distributorOfficePhoneNumber.text;
        NSString *secondOfficePhoneNumber = _distributorSecondOfficePhoneNumber.text;
        NSString *email = _distributorEmail.text;
        
        ABRecordRef person = ABPersonCreate();
        if (!person) {
            NSLog(@"Can Not Create Distributor");
            return;
        }
        
        CFErrorRef error = nil;
        
        BOOL couldSetFirstName = ABRecordSetValue(person,
                                                  kABPersonFirstNameProperty,
                                                  (__bridge CFStringRef)firstName,
                                                  &error);
        BOOL couldSetLastName = ABRecordSetValue(person,
                                                 kABPersonLastNameProperty,
                                                 (__bridge CFStringRef)lastName,
                                                 &error);
        
        BOOL couldSetCompanyName = ABRecordSetValue(person,
                                                    kABPersonOrganizationProperty,
                                                    (__bridge CFStringRef) companyName,
                                                    &error);
        BOOL coulSetNotes = ABRecordSetValue(person,
                                             kABPersonNoteProperty,
                                             (__bridge CFStringRef) note,
                                             &error);
        
        ABMutableMultiValueRef emailSet = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel (emailSet,
                                      (__bridge CFStringRef) email,
                                      kABOtherLabel,
                                      NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailSet, nil);
        CFRelease(emailSet);
        // setup Phone Numbers
        ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)phone,
                                     kABPersonPhoneMobileLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)secondPhone,
                                     kABPersonPhoneHomeFAXLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)officePhoneNumber,
                                     kABPersonPhoneWorkFAXLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)secondOfficePhoneNumber,
                                     kABPersonPhoneWorkFAXLabel,
                                     NULL);
        
        BOOL couldSetPhoneNumber = ABRecordSetValue(person,
                                                    kABPersonPhoneProperty,
                                                    phones,
                                                    &error);
        CFRelease(phones);
        
        if (couldSetFirstName && couldSetLastName && couldSetPhoneNumber && couldSetCompanyName && coulSetNotes && emailSet) {
            NSLog(@"Connection Whith Address Book");
        }
        
        if (ABAddressBookAddRecord(addressBook, person, &error)) {
            NSLog(@"Distributor Added To Address Book");
        }
        
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id record in allContacts){
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                                ABRecordCopyCompositeName(person), 0) == kCFCompareEqualTo){
                //The contact already exists!
                UIAlertView *SameContactExistsAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"There can only be one %@", firstName] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [SameContactExistsAlert show];
                return;
            }
        }
        
        [self saveAddressBook:addressBook];
        //Add to Group
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *) ABRecordCopyValue(group, kABGroupNameProperty);
                
                if ([groupName isEqualToString:@"To4ka"]) {
                    if (ABGroupAddMember(group, person, &error)) {
                        NSLog(@"Distributor Added To Group");
                    } else {
                        NSLog(@"Failed! Distributor Failed Add To Group");
                    }
                    break;
                }
            }
        }
        CFRelease(allGroups);
        [self saveGroupAddressBook:addressBook];
        //Adding In Group
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Save Method To Phone Book Group & Person


- (void)saveAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        if (ABAddressBookSave(addressBook, &error)){
            UIAlertView *disAddedContactAlert = [[UIAlertView alloc] initWithTitle: @"Done" message: @"Distributor Added To Address Book" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [disAddedContactAlert show];
        } else {
            UIAlertView *cantDisAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Sorry" message: @"Can Not Add Distributor To Address Book" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [cantDisAddContactAlert show];
        }
    }
}

- (void)saveGroupAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        
        if (ABAddressBookSave(addressBook, &error)){
            NSLog(@"Distributor in Group Added To Address Book");
        } else {
            NSLog(@"Can Not Add Distributor in Group To Address Book");
        }
    }
}

#pragma mark -
#pragma mark - Hiden Second Phone Number Section


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 4 && hideSecondPhoneSection) {
        return 0;
    }
    if (section == 6 && hideSecondOfficePhoneSection) {
        return 0;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 4 && hideSecondPhoneSection) {
        cell.hidden = YES;
        return 0;
    }
    if (indexPath.section == 6 && hideSecondOfficePhoneSection) {
        cell.hidden = YES;
        return 0;
    }else {
        cell.hidden = NO;
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - Button Add Second Office Phone Number Button


- (IBAction)addSecondOfficePhoneNumber:(id)sender {
   
    hideSecondOfficePhoneSection = NO;
    [self.tableView reloadData];
    [self.distributorSecondOfficePhoneNumber becomeFirstResponder];
    self.addSecondOfficePhoneNumberButtone.hidden = YES;
}

#pragma mark -
#pragma mark - Button Add Second Phone Number Button


- (IBAction)addSecondPhoneNumber:(id)sender {
    
    hideSecondPhoneSection = NO;
    [self.tableView reloadData];
    [self.distributorSecondPhoneNumber becomeFirstResponder];
    self.addSecondPhoneNumberButtone.hidden = YES;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Email


- (BOOL)checkEmailTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *validation = [NSCharacterSet characterSetWithCharactersInString:@"?±~!#$%^,/|&*()<>=+{}][:;'\" \\"];
    NSArray * components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (([newString rangeOfString:@"@"].length) < 1) {
        self.atPresent = NO;
    }
    if ([newString length] < 2 && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([newString length] > 30) {
        return NO;
    }
    if (self.atPresent && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([string isEqualToString:@"@"]) {
        self.atPresent = YES;
    }
    textField.text = newString;
    return NO;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Phone


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL yesOrNot = TRUE;
    if ([textField isEqual:self.distributorPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.distributorOfficePhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.distributorSecondPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.distributorSecondOfficePhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.distributorEmail]) {
        yesOrNot = [self checkEmailTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return yesOrNot;
}

#pragma mark -
#pragma mark - UITextFieldDelegate Phone Number


- (BOOL)checkPhoneTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    NSMutableString* resultString = [NSMutableString string];
    
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    static const int countryMaxLenght = 2;
    
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght + countryMaxLenght) {
        return NO;
    }
    
    NSInteger localNumberLenght = MIN([newString length], localNumberMaxLenght);
    
    if (localNumberLenght > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLenght];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    if ([newString length] > localNumberMaxLenght) {
        
        NSInteger areaCodeLenght = MIN((int)[newString length] - localNumberMaxLenght, areaCodeMaxLenght);
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLenght - areaCodeLenght, areaCodeLenght);
        NSString* area = [newString substringWithRange:areaRange];
        area = [NSString stringWithFormat:@"(%@) ", area];
        [resultString insertString:area atIndex:0];
        
    }
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght) {
        
        NSInteger countryCodeLenght = MIN((int)[newString length] - localNumberMaxLenght - areaCodeMaxLenght, countryMaxLenght);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLenght);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        [resultString insertString:countryCode atIndex:0];
    }
    textField.text = resultString;
    return NO;
}

#pragma mark -
#pragma mark - Return key


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.distributorCompanyName]) {
        [self.distributorFirstName becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorFirstName]) {
        [self.distributorLastName becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorLastName]) {
        [self.distributorPhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorPhoneNumber]) {
        [self.distributorOfficePhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorNote]) {
        [self.distributorNote becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorSecondPhoneNumber]) {
        [self.distributorOfficePhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorOfficePhoneNumber]) {
        [self.distributorEmail becomeFirstResponder];
    }
    if ([textField isEqual:self.distributorSecondOfficePhoneNumber]) {
        [self.distributorEmail becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark - Cance And Save


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    
    if ([addDistributor.distributorCompanyName = _distributorCompanyName.text length] == 0 && [addDistributor.distributorFirstName = _distributorFirstName.text length] == 0 &&
        [addDistributor.distributorLastName = _distributorLastName.text length] == 0 )
    {
        UIAlertView *empty = [[UIAlertView alloc]initWithTitle:@"Fill Up The Form" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [empty show];
    } else {
        
        NSString *stringRequest = [arrayRequest componentsJoinedByString:@" / "];
        NSString *stringDelivery = [arrayDelivery componentsJoinedByString:@" / "];
        
        addDistributor.distributorCompanyName = _distributorCompanyName.text;
        addDistributor.distributorFirstName = _distributorFirstName.text;
        addDistributor.distributorLastName = _distributorLastName.text;
        addDistributor.distributorPhoneNumber = _distributorPhoneNumber.text;
        addDistributor.distributorSecondPhoneNumber = _distributorSecondPhoneNumber.text;
        addDistributor.distributorOfficePhoneNumber = _distributorOfficePhoneNumber.text;
        addDistributor.distributorSecondOfficePhoneNumber = _distributorSecondOfficePhoneNumber.text;
        addDistributor.distributorEmail = _distributorEmail.text;
        addDistributor.distributorRequestDay = stringRequest;
        addDistributor.distributorDeliveryDay = stringDelivery;
//      addDistributor.distributorRequestTime = _distributorRequestTime.text;
        addDistributor.distributorNote = _distributorNote.text;
        
        [super saveAndDissmiss];
    }
}

#pragma mark -
#pragma mark - MultiSelectSegmentedControl Request & Delivery


-(void)arrayRequestDays{
    arrayRequest = [[NSMutableArray alloc] init];
}
-(void)arrayDeliveryDays{
    arrayDelivery = [[NSMutableArray alloc] init];
}

-(void)setDaysRequestControl:(MultiSelectSegmentedControl *)daysRequestControl{
    _daysRequestControl = daysRequestControl;
    self.daysRequestControl.tag = 1;
    self.daysRequestControl.delegate = self;
}

-(void)setDaysDeliveryControl:(MultiSelectSegmentedControl *)daysDeliveryControl {
    _daysDeliveryControl = daysDeliveryControl;
    self.daysDeliveryControl.tag = 2;
    self.daysDeliveryControl.delegate = self;
}

-(void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index {
    
    if (value) {
        if (!(multiSelecSegmendedControl.tag == 2)) {
            
            if (index == 0) {
                [self.arrayRequest addObject:@"Sun "];
            }
            else if (index == 1) {
                [self.arrayRequest addObject:@"Mon "];
            }
            else if (index == 2) {
                [self.arrayRequest addObject:@"Tue "];
            }
            else if (index == 3) {
                [self.arrayRequest addObject:@"Wed "];
            }
            else if (index == 4) {
                [self.arrayRequest addObject:@"Thu "];
            }
            else if (index == 5) {
                [self.arrayRequest addObject:@"Fri "];
            }
            else if (index == 6) {
                [self.arrayRequest addObject:@"Sat "];
            }
        } else {
            if (index == 0) {
                [self.arrayDelivery addObject:@"Sun "];
            }
            else if (index == 1) {
                [self.arrayDelivery addObject:@"Mon "];
            }
            else if (index == 2) {
                [self.arrayDelivery addObject:@"Tue "];
            }
            else if (index == 3) {
                [self.arrayDelivery addObject:@"Wed "];
            }
            else if (index == 4) {
                [self.arrayDelivery addObject:@"Thu "];
            }
            else if (index == 5) {
                [self.arrayDelivery addObject:@"Fri "];
            }
            else if (index == 6) {
                [self.arrayDelivery addObject:@"Sat "];
            }
        }
    } else if (!(multiSelecSegmendedControl.tag == 2)) {
        if (index == 0) {
            [self.arrayRequest removeObject:@"Sun "];
        }
        else if (index == 1) {
            [self.arrayRequest removeObject:@"Mon "];
        }
        else if (index == 2) {
            [self.arrayRequest removeObject:@"Tue "];
        }
        else if (index == 3) {
            [self.arrayRequest removeObject:@"Wed "];
        }
        else if (index == 4) {
            [self.arrayRequest removeObject:@"Thu "];
        }
        else if (index == 5) {
            [self.arrayRequest removeObject:@"Fri "];
        }
        else if (index == 6) {
            [self.arrayRequest removeObject:@"Sat "];
        }
    } else {
        if (index == 0) {
            [self.arrayDelivery removeObject:@"Sun "];
        }
        else if (index == 1) {
            [self.arrayDelivery removeObject:@"Mon "];
        }
        else if (index == 2) {
            [self.arrayDelivery removeObject:@"Tue "];
        }
        else if (index == 3) {
            [self.arrayDelivery removeObject:@"Wed "];
        }
        else if (index == 4) {
            [self.arrayDelivery removeObject:@"Thu "];
        }
        else if (index == 5) {
            [self.arrayDelivery removeObject:@"Fri "];
        }
        else if (index == 6) {
            [self.arrayDelivery removeObject:@"Satu "];
        }
    }
}

#pragma mark -
#pragma mark Access Calendar


// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             AddDistributorTableViewController * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         }
     }];
}

// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    // Enable the Add button
    self.addButton.enabled = YES;
    // Fetch all events happening in the next 24 hours and put them into eventsList
    self.eventsList = [self fetchEvents];
    // Update the UI with the above events
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Fetch events

// Fetch all events happening in the next 24 hours
- (NSMutableArray *)fetchEvents
{
    NSDate *startDate = [NSDate date];
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 1;
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    // We will only search the default calendar for our events
    NSArray *calendarArray = [NSArray arrayWithObject:self.defaultCalendar];
    // Create the predicate
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
    // Fetch all events that match the predicate
    NSMutableArray *events = [NSMutableArray arrayWithArray:[self.eventStore eventsMatchingPredicate:predicate]];
    
    return events;
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    AddDistributorTableViewController * __weak weakSelf = self;
    // Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // Re-fetch all events happening in the next 24 hours
                 weakSelf.eventsList = [self fetchEvents];
                 // Update the UI with the above events
                 [weakSelf.tableView reloadData];
             });
         }
     }];
}

#pragma mark -
#pragma mark Add a new event

// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEvent:(id)sender
{
    // Create an instance of EKEventEditViewController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    // Set addController's event store to the current event store
    addController.eventStore = self.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}
// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return self.defaultCalendar;
}


@end
