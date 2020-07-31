/*
 * @Description: Helper class to create payment records for licence renewal applications
 */
public with sharing class LicenceRenewalPaymentCreator {
    
    private Map<Id, Authorisation__c> applicationVsLicence;
    private static final Pricebook2 pbook;
    private static final Map<String, String> licenceProducts;
    private static final Map<String, PriceBookEntry> classVsProduct;
    private static final Decimal DAYS_IN_A_MONTH = 30.0;
    private static final String renewalProductName = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - ';
        
    static {
        licenceProducts = new Map<String, String>();
        licenceProducts.put(GlobalConstants.LICENCE_TYPE_ANNUAL, GlobalConstants.ANNUAL_TAXI_LICENCE_PRODUCT_NAME);
        licenceProducts.put(GlobalConstants.LICENCE_TYPE_ORDINARY, GlobalConstants.ORDINARY_TAXI_LICENCE_PRODUCT_NAME);
        licenceProducts.put(GlobalConstants.LICENCE_TYPE_SHORT_TERM, GlobalConstants.SHORT_TERM_TAXI_LICENCE_PRODUCT_NAME);
        
        pbook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
        
        //retrieve pricebook entries for licence renewals
        List<PriceBookEntry> pbEntries = [Select UnitPrice, Product2Id, Pricebook2Id, Name, Id, Product2.Name 
                                            FROM PricebookEntry
                                            WHERE (Product2.Name LIKE :renewalProductName + '%'
                                                OR Product2.Name IN :licenceProducts.values())
                                             AND PriceBook2Id = :pbook.Id];
        classVsProduct = new Map<String, PriceBookEntry>();
        for(PriceBookEntry pbEntry : pbEntries){
            System.debug(LoggingLevel.INFO, 'PbEntry: ' + pbEntry);
            classVsProduct.put(pbEntry.Name, pbEntry);
        }
    }
    
    public LicenceRenewalPaymentCreator(Map<Id, Authorisation__c> applicationVsLicence){
        if(applicationVsLicence == null || applicationVsLicence.isEmpty()){
            throw new InvalidDataException('Failed to create payment records. Renewal application details missing.');
        }
        this.applicationVsLicence = applicationVsLicence;
    }
    
    public void create(){
        //create payment records for licence renewal application
        List<Order> allPayments = new List<Order>();
        List<Order> payments = new List<Order>();
        List<Order> recurringPayments = new List<Order>();
        
        //create payment records for licence renewal application fee
        for(Id applicationId : applicationVsLicence.keySet()){
            payments.add(createOrder(applicationId, applicationVsLicence.get(applicationId)));
        }
        
        //create payment records for recurring payment method
        Map<Id, List<Decimal>> licenceVsMonthlyInstallments = new Map<Id, List<Decimal>>();
        Map<Id, List<Order>> licenceVsMonthlyPayments = new Map<Id, List<Order>>();
        for(Id applicationId : applicationVsLicence.keySet()){
            //create 12 recurring debit payment records for licence with monthly payment frequency
            if(applicationVsLicence.get(applicationId).Payment_Frequency__c == GlobalConstants.MONTHLY_PAYMENT_FREQUENCY){
                //calculate monthly installments for licence
                List<Decimal> monthlyPayments = calculateMonthlyPayments(applicationVsLicence.get(applicationId));
                licenceVsMonthlyInstallments.put(applicationVsLicence.get(applicationId).Id, monthlyPayments);
                
                List<Order> monthlyPaymentRecords = new List<Order>();
                for(Integer index = 0; index < monthlyPayments.size(); index++){
                    Order payment = createOrder(applicationId, applicationVsLicence.get(applicationId));
                    payment.EffectiveDate = applicationVsLicence.get(applicationId).Start_Date__c.addMonths(index);
                    //        Integer paymentReference = this.tokens.size() == 13 ? P2PWIBSParserFacadeBase.CAF_CUSTOMER_REFERENCE_NUMBER : P2PWIBSParserFacadeBase.RETURNS_CAF_CUSTOMER_REFERENCE_NUMBER;
                    String accountNumber = applicationVsLicence.get(applicationId).Bank_Account_Number__c;
                    String creditCardNumber = applicationVsLicence.get(applicationId).Payment_Card_Number__c;
                    if(accountNumber != NULL) {
                        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
                    }
                    if(creditCardNumber != NULL) {
                        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD;
                    }
                    payment.Description = GlobalConstants.TAXI_LICENCE_RECURRING_FEE_DESC;
                    monthlyPaymentRecords.add(payment);
                    recurringPayments.add(payment);
                }
                licenceVsMonthlyPayments.put(applicationVsLicence.get(applicationId).Id, monthlyPaymentRecords);
            }
        }
        
        allPayments.addAll(payments);
        allPayments.addAll(recurringPayments);
        insert allPayments;
        
        
        
        //create payment line items for licence renewal application fee.
        List<OrderItem> lineItems = new List<OrderItem>();
        for(Order payment : payments){
            //create line item for renewal application fees
            String productName = renewalProductName + applicationVsLicence.get(payment.Application__c).Licence_Class__c;
            lineItems.add(createLineItem(payment, getPricebookEntry(productName), getPricebookEntry(productName).UnitPrice));
            
            //create 2nd line item for licence fee if payment frequency is not monthly
            if(applicationVsLicence.get(payment.Application__c).Payment_Frequency__c != GlobalConstants.MONTHLY_PAYMENT_FREQUENCY){
                String renewalProduct = getRenewalProductName(applicationVsLicence.get(payment.Application__c).Licence_Type__c);
                Decimal licenceFee = applicationVsLicence.get(payment.Application__c).Licence_Fee__c;
                lineItems.add(createLineItem(payment, getPricebookEntry(renewalProduct), licenceFee));
            }           
        }
        
        //create line items for recurring licence payment fee.
        Set<Id> recurringLicences = new Set<Id>();
        for(Order payment : recurringPayments){
            recurringLicences.add(payment.Application__c);
        }
        for(Id appId : recurringLicences){
            List<Decimal> monthlyInstallments = licenceVsMonthlyInstallments.get(applicationVsLicence.get(appId).Id);
            List<Order> monthlyPayments = licenceVsMonthlyPayments.get(applicationVsLicence.get(appId).Id);
            for(Integer index = 0; index < monthlyPayments.size(); index++){
                String renewalProduct = getRenewalProductName(applicationVsLicence.get(appId).Licence_Type__c);
                Decimal licenceFee = monthlyInstallments[index];
                lineItems.add(createLineItem(monthlyPayments[index], getPricebookEntry(renewalProduct), licenceFee));
            }           
        }
        
        insert lineItems;
    }
    
    private String getRenewalProductName(String licenceType){
        System.debug(LoggingLevel.INFO, 'Identifying product name for licence type ' + licenceType);
        if(!licenceProducts.containsKey(licenceType)){
            throw new InvalidDataException('Failed to create payment records for licence renewal. Invalid Licence Type');
        }
        return licenceProducts.get(licenceType);
    }
    
    private PriceBookEntry getPricebookEntry(String productName){
        System.debug(LoggingLevel.INFO, 'Retrieving pricebook entry for product ' + productName);
        if(!classVsProduct.containsKey(productName)){
            throw new InvalidDataException('Failed to create payment records for licence renewal. Product details missing');
        }
        return classVsProduct.get(productName);
    }
    
    private List<Decimal> calculateMonthlyPayments(Authorisation__c licence){
        Integer months = (Integer)(licence.Start_Date__c.daysBetween(licence.End_Date__c)/DAYS_IN_A_MONTH).round();
        Decimal licenceFee = licence.Licence_Fee__c;
        Decimal monthlyInstallment = (licenceFee * 1.0/months ).setScale(2);
        List<Decimal> monthlyPayments = new List<Decimal>();
        for(Integer index = 1; index < months; index++){
            monthlyPayments.add(monthlyInstallment);
            licenceFee -= monthlyInstallment;
        }
        monthlyPayments.add(licenceFee);
        return monthlyPayments;
    }
    
    private OrderItem createLineItem(Order payment, PricebookEntry pbEntry, Decimal fee){
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = payment.Id;
        lineItem.Quantity = 1;
        lineItem.Transaction_Type__c = GlobalConstants.LICENCE_RENEWAL_TRANSACTION_TYPE;
        lineItem.Description = pbEntry.Product2.Name;
        lineItem.PriceBookEntryId = pbEntry.Id;
        lineItem.UnitPrice = fee;
        
        return lineItem;
    }
    
    private Order createOrder(Id applicationId, Authorisation__c licence){
        Order payment = new Order();
        
        payment.Application__c = applicationId;
        payment.AccountId = licence.Service_Provider__c;
        payment.Authorisation__c = licence.Id;
        //payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_CONTACT_P2P;
        payment.EffectiveDate = licence.Start_Date__c;
        payment.PriceBook2Id = pbook.Id;
        payment.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        payment.Description = GlobalConstants.TAXI_LICENCE_RENEWAL_DESC;
        
        return payment;
    }
    
    public class InvalidDataException extends Exception {}
}