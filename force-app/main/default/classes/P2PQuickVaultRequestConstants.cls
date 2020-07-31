/*
    Will pull the configurations required for doing authentication
*/
public class P2PQuickVaultRequestConstants {
   
    public String username { get; set; }
    public String password { get; set; }
    public String supplierBusinessCode { get; set; }
    public String connectionType { get; set; }
    public String product { get; set; }
    public String communityCode { get; set; }
    public String serverReturnUrl { get; set; }
    public String internalStaffReturnUrl { get; set; }
    public String internalStaffCancelUrl { get; set; }
    public String redirectURL { get; set; }
    public String errorEmailToAddress { get; set; }
        
    public P2PQuickVaultRequestConstants()  {
        
        String wibsConfigDevName;
        
        //querying current organisation
        Organization currentOrg = [SELECT isSandbox 
                                   FROM Organization
                                   WHERE Id = :UserInfo.getOrganizationId()];
        
        /* Checking if org. is sandbox or production instance and
         * accrodingly referring sandbox/production configuration 
         */
        wibsConfigDevName = currentOrg.isSandbox ? 'WIBS_Quick_Vault_Constants_SB' : 'WIBS_Quick_Vault_Constants';
        
        //get from Custom Metadata and populate required request parameter constants
        WIBS_Configuration__mdt wibsPaymentConstants = [SELECT  DeveloperName, Label, qvalent_username__c, qvalent_password__c, qvalent_supplierBusinessCode__c, 
                                                                qvalent_connectionType__c, qvalent_product__c, qvalent_communityCode__c, qvalent_serverReturnUrl__c, 
                                                                qvalent_errorEmailToAddress__c, qvalent_ASP_returnUrl__c, qvalent_ASP_cancelUrl__c, qvalent_TAXI_returnUrl__c, 
                                                                qvalent_TAXI_cancelUrl__c, qvalent_redirectUrl__c, Internal_staff_qvalent_cancelUrl__c, Internal_staff_qvalent_returnUrl__c
                                                                FROM WIBS_Configuration__mdt WHERE DeveloperName = :wibsConfigDevName];
        this.username = wibsPaymentConstants.qvalent_username__c;
        this.password = wibsPaymentConstants.qvalent_password__c;
        this.supplierBusinessCode = wibsPaymentConstants.qvalent_supplierBusinessCode__c;
        this.connectionType = wibsPaymentConstants.qvalent_connectionType__c;
        this.product = wibsPaymentConstants.qvalent_product__c;
        this.communityCode = wibsPaymentConstants.qvalent_communityCode__c;
        this.serverReturnUrl = wibsPaymentConstants.qvalent_serverReturnUrl__c;
        this.redirectURL = wibsPaymentConstants.qvalent_redirectUrl__c;
        this.errorEmailToAddress = wibsPaymentConstants.qvalent_errorEmailToAddress__c;
        this.internalStaffReturnUrl = wibsPaymentConstants.Internal_staff_qvalent_returnUrl__c;
        this.internalStaffCancelUrl = wibsPaymentConstants.Internal_staff_qvalent_cancelUrl__c;
    }
}