public with sharing class DDCCPendingPaymentProcessorScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        DDCCPendingPaymentProcessor.process(System.today());
    }
}