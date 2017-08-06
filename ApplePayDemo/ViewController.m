//
//  ViewController.m
//  ApplePayDemo
//
//  Created by Liujinjun on 2017/8/7.
//  Copyright © 2017年 Liujinjun. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PKPaymentButton *payButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    payButton.center = self.view.center;
    [payButton addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];
}

- (void)payAction:(UIButton *)button {
    if ([PKPaymentAuthorizationController canMakePayments]) {
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        request.countryCode = @"CN";
        request.currencyCode = @"CNY";
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkChinaUnionPay, PKPaymentNetworkDiscover, PKPaymentNetworkInterac, PKPaymentNetworkMasterCard, PKPaymentNetworkPrivateLabel, PKPaymentNetworkVisa, PKEncryptionSchemeECC_V2];
        request.merchantCapabilities = PKMerchantCapabilityDebit | PKMerchantCapabilityCredit | PKMerchantCapabilityEMV;
        request.merchantIdentifier = @"merchant.com.example.ApplePayLjj";
        
        // 配送信息和账单信息
        request.requiredBillingAddressFields = PKAddressFieldAll;
        request.requiredShippingAddressFields = PKAddressFieldAll;
        
        // 运输方式
        NSDecimalNumber *shippingPrice = [NSDecimalNumber decimalNumberWithString:@"11.0"];
        PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"快递公司" amount:shippingPrice];
        method.detail = @"24小时送到！";
        method.identifier = @"kuaidi";
        request.shippingMethods = @[method];
        request.shippingType = PKShippingTypeServicePickup;
        
        request.applicationData = [@"商品ID: 123456" dataUsingEncoding:NSUTF8StringEncoding];
        
        PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"商品1" amount:[NSDecimalNumber decimalNumberWithString:@"20.0"]];
        PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem summaryItemWithLabel:@"商品2" amount:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
        request.paymentSummaryItems = @[item1, item2];
        
        // 显示认证视图
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        NSLog(@"设备不支持支付");
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    PKPaymentToken *token = payment.token;
    NSLog(@"获取token: %@", token);
    NSString *address = payment.billingContact.postalAddress.city;
    NSLog(@"获取地址: %@", address);
    NSLog(@"验证通过，请继续完成交易");
    
    // 给服务器验证
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"取消或者交易完成");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
