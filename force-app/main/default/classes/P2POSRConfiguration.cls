public class P2POSRConfiguration {

    public static Revenue_NSW_Config__mdt get()  {
        
        String revenueConfigDevName;
        
        //querying current organisation
        Organization currentOrg = [SELECT isSandbox 
                                   FROM Organization
                                   WHERE Id = :UserInfo.getOrganizationId()];
        
        /* Checking if org. is sandbox or production instance and
         * accrodingly referring sandbox/production configuration 
         */
        revenueConfigDevName = currentOrg.isSandbox ? 'RNSW_Integration_SB' : 'RNSW_Integration';
        
        return [SELECT Username__c, Password__c, Endpoint__c, Certificate__c
                FROM Revenue_NSW_Config__mdt
                WHERE DeveloperName = :revenueConfigDevName];
    }
}