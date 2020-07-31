@IsTest
private with sharing class TPlusThreePaidPaymentProcessorTest {
    
    private static testMethod void testForNonBusinessDaySun(){
        Date receivedDate = Date.newInstance(2017, 8, 20);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        System.assert(TPlusThreePaidPaymentProcessor.startDateToProcess == null);
    }
    
    private static testMethod void testForBusinessDayOnMon(){
        Date receivedDate = Date.newInstance(2017, 8, 21);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        Date startDateToProcess = Date.newInstance(2017, 8, 16);
        System.assert(startDateToProcess
            .isSameDay(TPlusThreePaidPaymentProcessor.startDateToProcess));
    }
    
    private static testMethod void testForBusinessDayOnTue(){
        Date receivedDate = Date.newInstance(2017, 8, 22);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        Date startDateToProcess = Date.newInstance(2017, 8, 17);
        System.assert(startDateToProcess
            .isSameDay(TPlusThreePaidPaymentProcessor.startDateToProcess));
    }
    
    private static testMethod void testForBusinessDayOnWed(){
        Date receivedDate = Date.newInstance(2017, 8, 23);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        Date startDateToProcess = Date.newInstance(2017, 8, 18);
        System.assert(startDateToProcess
            .isSameDay(TPlusThreePaidPaymentProcessor.startDateToProcess));
    }
    
    private static testMethod void testForBusinessDayOnThr(){
        Date receivedDate = Date.newInstance(2017, 8, 17);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        Date startDateToProcess = Date.newInstance(2017, 8, 14);
        System.assert(startDateToProcess
            .isSameDay(TPlusThreePaidPaymentProcessor.startDateToProcess));
    }
    
    private static testMethod void testForBusinessDayOnFri(){
        Date receivedDate = Date.newInstance(2017, 8, 18);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        Date startDateToProcess = Date.newInstance(2017, 8, 15);
        System.assert(startDateToProcess
            .isSameDay(TPlusThreePaidPaymentProcessor.startDateToProcess));
    }
    
    private static testMethod void testForNonBusinessDaySat(){
        Date receivedDate = Date.newInstance(2017, 8, 19);
        System.Test.startTest();
        TPlusThreePaidPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        System.assert(TPlusThreePaidPaymentProcessor.startDateToProcess == null);
    }   
}