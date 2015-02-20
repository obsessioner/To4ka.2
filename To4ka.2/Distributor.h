//
//  Distributor.h
//  To4ka.2
//
//  Created by Air on 16.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Distributor : NSManagedObject

@property (nonatomic, retain) NSString * distributorCompanyName;
@property (nonatomic, retain) NSString * distributorDeliveryDay;
@property (nonatomic, retain) NSString * distributorEmail;
@property (nonatomic, retain) NSString * distributorFirstName;
@property (nonatomic, retain) NSString * distributorLastName;
@property (nonatomic, retain) NSString * distributorNote;
@property (nonatomic, retain) NSString * distributorOfficePhoneNumber;
@property (nonatomic, retain) NSString * distributorPhoneNumber;
@property (nonatomic, retain) NSString * distributorRequestDay;
@property (nonatomic, retain) NSString * distributorRequestTime;
@property (nonatomic, retain) NSString * distributorSecondOfficePhoneNumber;
@property (nonatomic, retain) NSString * distributorSecondPhoneNumber;

@end
