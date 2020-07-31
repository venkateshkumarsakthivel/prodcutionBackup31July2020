@IsTest
private with sharing class DDPendingPaymentProcessorTest {
    
    private static testMethod void testForNonBusinessDaySun(){
        Date receivedDate = Date.newInstance(2017, 8, 20);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        System.assert(DDPendingPaymentProcessor.startDatesToProcess == null);
    }
    
    private static testMethod void testForNonBusinessDaySat(){
        Date receivedDate = Date.newInstance(2017, 8, 19);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        System.assert(DDPendingPaymentProcessor.startDatesToProcess == null);
    }
    
    private static testMethod void testForBusinessDayOnMon(){
        Date receivedDate = Date.newInstance(2017, 8, 21);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        
        List<Date> expectedStartDatesToProcess = new List<Date>{ Date.newInstance(2017, 8, 21), Date.newInstance(2017, 8, 20),Date.newInstance(2017, 8, 19)};
        expectedStartDatesToProcess.sort();
        
        List<Date> actualStartDatesToProcess = DDPendingPaymentProcessor.startDatesToProcess;
        actualStartDatesToProcess.sort();
        
        System.assert(actualStartDatesToProcess.size() == expectedStartDatesToProcess.size());
        System.assert(actualStartDatesToProcess[0].isSameDay(expectedStartDatesToProcess[0]));
        System.assert(actualStartDatesToProcess[1].isSameDay(expectedStartDatesToProcess[1]));
        System.assert(actualStartDatesToProcess[2].isSameDay(expectedStartDatesToProcess[2]));
    }
    
    private static testMethod void testForBusinessDayOnTue(){
        Date receivedDate = Date.newInstance(2017, 8, 15);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        
        List<Date> expectedStartDatesToProcess = new List<Date>{ Date.newInstance(2017, 8, 15)};
        List<Date> actualStartDatesToProcess = DDPendingPaymentProcessor.startDatesToProcess;
        
        System.assert(actualStartDatesToProcess.size() == expectedStartDatesToProcess.size());
        System.assert(actualStartDatesToProcess[0].isSameDay(expectedStartDatesToProcess[0]));
    }
    
    private static testMethod void testForBusinessDayOnWed(){
        Date receivedDate = Date.newInstance(2017, 8, 16);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        
        List<Date> expectedStartDatesToProcess = new List<Date>{ Date.newInstance(2017, 8, 16)};
        List<Date> actualStartDatesToProcess = DDPendingPaymentProcessor.startDatesToProcess;
        
        System.assert(actualStartDatesToProcess.size() == expectedStartDatesToProcess.size());
        System.assert(actualStartDatesToProcess[0].isSameDay(expectedStartDatesToProcess[0]));
    }
    
    private static testMethod void testForBusinessDayOnThr(){
        Date receivedDate = Date.newInstance(2017, 8, 17);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        
        List<Date> expectedStartDatesToProcess = new List<Date>{ Date.newInstance(2017, 8, 17)};
        List<Date> actualStartDatesToProcess = DDPendingPaymentProcessor.startDatesToProcess;
        
        System.assert(actualStartDatesToProcess.size() == expectedStartDatesToProcess.size());
        System.assert(actualStartDatesToProcess[0].isSameDay(expectedStartDatesToProcess[0]));
    }
    
    private static testMethod void testForBusinessDayOnFri(){
        Date receivedDate = Date.newInstance(2017, 8, 18);
        System.Test.startTest();
        DDPendingPaymentProcessor.process(receivedDate);
        System.Test.stopTest();
        
        List<Date> expectedStartDatesToProcess = new List<Date>{ Date.newInstance(2017, 8, 18)};        
        List<Date> actualStartDatesToProcess = DDPendingPaymentProcessor.startDatesToProcess;
        
        System.assert(actualStartDatesToProcess.size() == expectedStartDatesToProcess.size());
        System.assert(actualStartDatesToProcess[0].isSameDay(expectedStartDatesToProcess[0]));
    }
    
       
}