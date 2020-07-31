@isTest
public class ApplicationLogUtilityTest {
   @testsetup
    private static void setUp() {
        System_Settings__c cs = new System_Settings__c();
        cs.debug__c = true;
        cs.Error__c = true;
        cs.Info__c = true;
        cs.Warning__c = true;
		insert cs;
    }
    
    @isTest
    public static void testDebugLogMessage() {
        Test.startTest();
        Try {
            throw new DMLException ('Error message!'); 
        }catch(Exception e) {
        	ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ApplicationLogUtilityTest', 'testDebugLogMessage', 'Testing from test class', e);
        }
        Test.stopTest();
        Application_Log__c appLog = [select id, source__c from Application_Log__c limit 1];
        system.assertEquals(appLog.source__c, 'ApplicationLogUtilityTest');
    	
    }
    
    @isTest
    public static void testInfoLogMessage() {
        Test.startTest();
        Try {
            throw new DMLException ('Info message!'); 
        }catch(Exception e) {
        	ApplicationLogUtility.logMessage(GlobalConstants.INFO, 'ApplicationLogUtilityTest', 'testInfoLogMessage', 'Testing from test class', e);
        }
        Test.stopTest();
        Application_Log__c appLog = [select id, source__c from Application_Log__c limit 1];
        system.assertEquals(appLog.source__c, 'ApplicationLogUtilityTest');
    	
    }
    
    @isTest
    public static void testWarningLogMessage() {
        Test.startTest();
        Try {
            throw new DMLException ('Warning message!'); 
        }catch(Exception e) {
        	ApplicationLogUtility.logMessage(GlobalConstants.WARNING, 'ApplicationLogUtilityTest', 'testInfoLogMessage', 'Testing from test class', e);
        }
        Test.stopTest();
        Application_Log__c appLog = [select id, source__c from Application_Log__c limit 1];
        system.assertEquals(appLog.source__c, 'ApplicationLogUtilityTest');
    	
    }
    
    
    
     @isTest
    public static void testLogSingleMessage() {
        Test.startTest();
        Try {
            throw new DMLException ('Info message!'); 
        }catch(Exception e) {
        	ApplicationLogUtility.logMessage(GlobalConstants.WARNING, 'ApplicationLogUtilityTest', 'testLogSingleMessage', 'Testing with params', 
                                             'payLoad', e, 5, '', 'testReferenceId', 'testRefInfo');
        }
        Test.stopTest();
        Application_Log__c appLog = [select id, source__c from Application_Log__c limit 1];
        system.assertEquals(appLog.source__c, 'ApplicationLogUtilityTest');
    	
    }
}