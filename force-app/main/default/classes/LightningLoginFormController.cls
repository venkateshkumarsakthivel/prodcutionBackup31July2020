global class LightningLoginFormController {

    public LightningLoginFormController() {
        
    }

    //redirect to login page
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            System.debug('START URL = ' + startUrl);
            
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    //returns self registration form url
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        System.debug('authConfig === '+authConfig);
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    //returns forgot password page link
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        System.debug('authConfig === '+authConfig);
        return authConfig.getForgotPasswordUrl();
    }
    
    //returns authentication configuration
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        //Id networkId = Network.getNetworkId();
        Id networkId = [SELECT Id,Name FROM Network WHERE Name = 'Industry Portal'].Id;
        //System.debug('myCommunity == '+myCommunity);
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
    
    //function to check if current time is within configured downtime
    //if yes then returns appropriate downtime message, else returns NULL
    @AuraEnabled
    public static String validateASPDowntimeAlert() {
    
     String priorDowntimeResult = GlobalUtility.validateIsASPDowntimeMessageConfigured(GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_PRIOR_OUTAGE);
     String downtimeResult = priorDowntimeResult == NULL ? GlobalUtility.validateIsASPDowntimeMessageConfigured(GlobalConstants.INDEX_LOGIN_PAGE_MESSAGE_DURING_OUTAGE) : priorDowntimeResult;
    
     return downtimeResult;
    }
}