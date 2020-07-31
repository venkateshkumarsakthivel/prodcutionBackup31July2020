public with sharing class PaymentEnquiryDeletionBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String customerEnquiryDevName = 'Customer_Enquiry';
        String customerEnquiryStatus = 'Draft';
        // Customer enquiry cases created in last one hour and which are in draft status
        Datetime dateTimeStamp = datetime.now().addHours(-1);
        String query = 'SELECT Id FROM Case WHERE RecordType.DeveloperName = : customerEnquiryDevName AND Status = :customerEnquiryStatus AND '+
                       ' createdDate >= : dateTimeStamp';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        try {            
            delete scope;
        }catch (Exception ex) {
            //Insert Application Log
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'PaymentEnquiryDeletionBatch', 'execute', ex.getMessage(), null, ex, null, null, null, null);        
        }
    }
    
    public void finish(Database.BatchableContext batchableContext) { }    
    
}