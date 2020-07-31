global class PaymentEnquiryDeletionScheduler implements Schedulable{
    
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
            Id PaymentEnquiryDeletionBatchJobId = Database.executeBatch(new PaymentEnquiryDeletionBatch(), 200);
            FlexQueue.moveJobToFront(PaymentEnquiryDeletionBatchJobId);   
        } else {
            Database.executeBatch(new PaymentEnquiryDeletionBatch());
        }
    }
}