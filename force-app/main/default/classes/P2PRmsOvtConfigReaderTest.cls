@IsTest
private with sharing class P2PRmsOvtConfigReaderTest{

    private static testMethod void testRetrieveConfig(){
        System.Test.startTest();
        System.assert(P2PRmsOvtConfigReader.getCertificateName() != null);
        System.assert(P2PRmsOvtConfigReader.getCallPriority() != null);
        System.assert(P2PRmsOvtConfigReader.getChannelType() != null);
        System.assert(P2PRmsOvtConfigReader.getClientId() != null);
        System.assert(P2PRmsOvtConfigReader.getClientSystemId() != null);
        System.assert(P2PRmsOvtConfigReader.getEndpoint() != null);
        System.assert(P2PRmsOvtConfigReader.getLocationId() != null);
        System.assert(P2PRmsOvtConfigReader.getLocationType() != null);
        System.Test.stopTest();
    }
}