/*
 * @Description: Helper class to create payment/order record for transfer levy due from buyer of licence
 */
public with sharing class TransferLevyPaymentCreator{
    
    private Case buyerCase;
    
    public TransferLevyPaymentCreator(Case buyerCase){
        if(buyerCase == null || buyerCase.Id == null){
            throw new InvalidDataException('Failed to create payments for transfer levy. Buyer case details missing');
        }
        this.buyerCase = buyerCase;
    }
    
    public void create(){
        Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
            
        Order paymentRecord = new Order();
        paymentRecord.AccountId = buyerCase.AccountId;
        paymentRecord.Application__c = buyerCase.Id;
        paymentRecord.Authorisation__c = buyerCase.Authorisation__c;
        paymentRecord.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        paymentRecord.EffectiveDate = System.Today();
        paymentRecord.PriceBook2Id = priceBook.Id;
        paymentRecord.Description = GlobalConstants.TAXI_TRANSFER_APPLICATION_LEVY_DUE_DESCRIPTION;
        
        insert paymentRecord;
        
        Product2 product = [SELECT Name, Id, ProductCode, IsActive 
                            FROM Product2 
                            Where Name =: Label.Taxi_Transfer_Levy_Product_Name AND IsActive = true];

        PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name 
                                        FROM PricebookEntry 
                                        WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id AND IsActive = true];
        OrderItem paymentItem = new OrderItem(OrderId = paymentRecord.Id);
        paymentItem.Quantity = 1;
        paymentItem.Transaction_Type__c = GlobalConstants.TAXI_TRANSFER_APPLICATION_TRANSACTION_TYPE;
        paymentItem.Description = GlobalConstants.TAXI_TRANSFER_APPLICATION_LEVY_DUE_DESCRIPTION;
        paymentItem.PriceBookEntryId = pricebookEntry.Id;
        paymentItem.Product2Id = product.Id;
        paymentItem.UnitPrice = buyerCase.Levy_Due__c;
        
        insert paymentItem;
    }
    
    public class InvalidDataException extends Exception {}
}