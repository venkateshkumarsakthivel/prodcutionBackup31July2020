public with sharing class TPlusThreePaidPaymentScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        TPlusThreePaidPaymentProcessor.process(System.today());
    }
}