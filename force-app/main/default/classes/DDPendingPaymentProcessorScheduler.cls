public with sharing class DDPendingPaymentProcessorScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        DDPendingPaymentProcessor.process(System.today());
    }
}