/**
*  Description: Authorisation trigger handler class
*/
public with sharing class AuthorisationTriggerHandler {
    
    //before update handler
    public static void beforeUpdate(Map<Id, Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisations) {
        
        LicenceRenewalValidator renewalValidator = new LicenceRenewalValidator(newAuthorisations, oldAuthorisations);
       renewalValidator.validateRenewal();
        
        RelatedContactToAccountContactConversion relatedContactConverter = new RelatedContactToAccountContactConversion(newAuthorisations, oldAuthorisations);
        relatedContactConverter.validateContactAccountCreation();
        
        UpdateRelatedRegistrationsAuthHelper authRelatedRegistrationUpdate = new UpdateRelatedRegistrationsAuthHelper(newAuthorisations, oldAuthorisations);
        authRelatedRegistrationUpdate.processRelatedRegistrations();
        
        RenewalCountFinalExpiryDateCalculator renewalCountExpiryDateCalculator = new RenewalCountFinalExpiryDateCalculator();
        renewalCountExpiryDateCalculator.calculateRenwalCountFinalExpiryDate(newAuthorisations.Values(), oldAuthorisations);
        
        AuthorisationClassInformation authorisationClassInformation = new AuthorisationClassInformation();
        authorisationClassInformation.populateExisitingAuthorisationClassInformation(newAuthorisations.Values(), oldAuthorisations);  
    }
    
    //before insert handler
    public static void beforeInsert(List<Authorisation__c> newAuthorisations) {
        
        System.debug(LoggingLevel.INFO, 'Invoking before insert process for authorisation');
        AuthorisationNumberGenerator numberGenerator = new AuthorisationNumberGenerator();
        numberGenerator.generate(newAuthorisations);
        
        RenewalCountFinalExpiryDateCalculator renewalCountExpiryDateCalculator = new RenewalCountFinalExpiryDateCalculator();
        renewalCountExpiryDateCalculator.calculateRenwalCountFinalExpiryDate(newAuthorisations, NULL);
        
        AuthorisationClassInformation authorisationClassInformation = new AuthorisationClassInformation();
        authorisationClassInformation.mapNewAuthorisationClassInformation(newAuthorisations); 
    }
    
    //after update handler
    public static void afterUpdate(Map<Id, Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisations){
        
            UpdateRelatedAccountHelper UpdateRelatedAccount = new UpdateRelatedAccountHelper(newAuthorisations, oldAuthorisations);
            UpdateRelatedAccount.updateAccountASPCategory();
    } 
    
}