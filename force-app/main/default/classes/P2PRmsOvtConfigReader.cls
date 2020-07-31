/**
 * @Description: Helper class to custom metadata config setting for RMS criminal charge overturn service
 * @TestClass: P2PRmsOvtConfigReaderTest
 */
 public with sharing class P2PRmsOvtConfigReader{
    private static final RMS_OVT_Configuration__mdt ovtConfig;
    static{
        Organization orgInfo = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if(orgInfo.IsSandbox)
            ovtConfig = [SELECT Certificate_Name__c, Location_Type__c, Location_Id__c, Endpoint__c,  
                            Client_System_Id__c , Client_Id__c, Channel_Type__c, Call_Priority__c
                        FROM RMS_OVT_Configuration__mdt 
                        WHERE DeveloperName='Sandbox_Config' LIMIT 1];
        else 
            ovtConfig = [SELECT Certificate_Name__c, Location_Type__c, Location_Id__c, Endpoint__c, 
                            Client_System_Id__c , Client_Id__c, Channel_Type__c, Call_Priority__c 
                        FROM RMS_OVT_Configuration__mdt 
                        WHERE DeveloperName='Production_Config' LIMIT 1];
    }

    public static String getCertificateName(){ return ovtConfig.Certificate_Name__c;}
    
    public static String getLocationType(){ return ovtConfig.Location_Type__c;}
    
    public static String getLocationId(){ return ovtConfig.Location_Id__c;}
    
    public static String getEndpoint(){ return ovtConfig.Endpoint__c;}
    
    public static String getClientSystemId(){ return ovtConfig.Client_System_Id__c;}
    
    public static String getClientId(){ return ovtConfig.Client_Id__c;}
    
    public static String getChannelType(){ return ovtConfig.Channel_Type__c;}
    
    public static Decimal getCallPriority(){ return ovtConfig.Call_Priority__c;}    
}