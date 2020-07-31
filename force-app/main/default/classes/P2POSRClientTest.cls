/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

@isTest
private class P2POSRClientTest {
    
    private static P2POSRRequestParameter parameter = new P2POSRRequestParameter();

    /** generates test data for request with mandatory fields populated */
    public static void buildTestDataOnlyMandatoryFields()  {
        
        P2POSRClientTest.parameter.providerDetail.TfNSWProviderNumber = 'TfNSWProviderNumber';
        P2POSRClientTest.parameter.providerDetail.providerType = 'providerType';
        P2POSRClientTest.parameter.providerDetail.email = '';
        P2POSRClientTest.parameter.providerDetail.tradingName = '';
        P2POSRClientTest.parameter.providerDetail.abn = 'abn';
        P2POSRClientTest.parameter.providerDetail.providerPostalAddress = new P2POSRPostalAddress('addressLine1', '', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerDetail.providerStreetAddress = null;
        P2POSRClientTest.parameter.providerDetail.clientDetails = new P2POSRClientDetails();
        /* just for code coverage */
        P2POSRClientTest.parameter.providerDetail.clientDetails.individual = new P2POSRIndividualClient();
        P2POSRClientTest.parameter.providerDetail.clientDetails.company = new P2POSRCompanyClient();
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations();
        P2POSRClientTest.parameter.providerDetail.clientDetails = new P2POSRClientDetails(new P2POSRIndividualClient('givenName', 'familyName', 'birthDate', '', '', 'M'), new P2POSRCompanyClient('name', '', '', ''));
   
    }
    
    /** generates test data for request with all fields populated */
    public static void buildTestDataAllFields()  {
        P2POSRClientTest.parameter.providerDetail.TfNSWProviderNumber = 'TfNSWProviderNumber';
        P2POSRClientTest.parameter.providerDetail.providerType = 'providerType';
        P2POSRClientTest.parameter.providerDetail.email = 'email';
        P2POSRClientTest.parameter.providerDetail.tradingName = 'tradingName';
        P2POSRClientTest.parameter.providerDetail.abn = 'abn';
        P2POSRClientTest.parameter.providerDetail.providerPostalAddress = new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerDetail.providerStreetAddress = new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerDetail.clientDetails = new P2POSRClientDetails();
        /* just for code coverage */
        P2POSRClientTest.parameter.providerDetail.clientDetails.individual = new P2POSRIndividualClient();
        P2POSRClientTest.parameter.providerDetail.clientDetails.company = new P2POSRCompanyClient();
        
        P2POSRClientTest.parameter.providerDetail.clientDetails = new P2POSRClientDetails(new P2POSRIndividualClient('givenName', 'familyName', 'birthDate', 'driversLicenceNumber', 'driversLicenceState', 'M'), new P2POSRCompanyClient('name', 'contactName', 'abn', 'arbn'));
        /* just for code coverage */
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation = new P2POSRAuthorisation();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.type = 'type';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.effectiveDate = 'effectiveDate';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.BSB = 'BSB';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountNumber = 'bankAccountNumber';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountName = 'bankAccountName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactName = 'contactName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactPhone = 'contactPhone';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactEmail = 'contactEmail';
        /* just for code coverage */
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress();
        
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        
        P2POSRClientTest.parameter.providerAuthorisations.bspAuthorisation = new P2POSRAuthorisation('type', 'effectiveDate', 'BSB', 'bankAccountNumber', 'bankAccountName', 'contactName', 'contactPhone','contactEmail'
        , new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'), new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'));

    }
    
    @isTest
    private static void p2POSRCreateProviderAuthorisationWithAllFieldsTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail('', '', '', '', null, null, '', null);
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail();
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations(null, null);
        P2POSRClientTest.buildTestDataAllFields();
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRCreateProviderAuthorisationTWithOnlyMandatoryFieldsTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail('', '', '', '', null, null, '', null);
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail();
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations(null, null);
        P2POSRClientTest.buildTestDataOnlyMandatoryFields();
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRCreateOrUpdateProviderAuthorisationFaultTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail('', '', '', '', null, null, '', null);
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail();
        P2POSRClientTest.buildTestDataOnlyMandatoryFields();
        P2POSRClientTest.parameter.providerDetail.TfNSWProviderNumber = 'RESPONSEWITHFAULT';
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(500 == visitor.responseStatus);
    }
    
    @isTest
    private static void p2POSRUpdateProviderAuthorisationWithErrorsTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail('', '', '', '', null, null, '', null);
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail();
        P2POSRClientTest.buildTestDataOnlyMandatoryFields();
        P2POSRClientTest.parameter.providerDetail.TfNSWProviderNumber = 'RESPONSEWITHERRORS';
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert(1 == visitor.p2POSRAuthorisationResponse.errors.size());
    }
    
    @isTest
    private static void p2POSRUpdateProviderAuthorisationTWithMandatoryFieldsOnlyTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail('', '', '', '', null, null, '', null);
        P2POSRClientTest.parameter.providerDetail = new P2POSRProviderDetail();
        P2POSRClientTest.buildTestDataOnlyMandatoryFields();
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRNullRequestTypeTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        P2POSRRequestParameter parameter = new P2POSRRequestParameter();
        try {
            client.call(null, visitor, parameter);   
        } catch (Exception noRequestTypeException)  {
            System.assert(0 == noRequestTypeException.getMessage().compareTo('No OSR REQUEST requestType value set. Unable to understand which query to fire.'));
        }
    }
    
    @isTest
    private static void p2POSRCreateAuthorisationTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        /* build request parameters. */
        P2POSRClientTest.parameter.tfNSWProviderNumber = '9999999999';
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation = new P2POSRAuthorisation();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.type = 'type';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.effectiveDate = 'effectiveDate';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.BSB = 'BSB';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountNumber = 'bankAccountNumber';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountName = 'bankAccountName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactName = 'contactName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactPhone = 'contactPhone';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactEmail = 'contactEmail';
        /* just for code coverage */
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress();
        
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        
        P2POSRClientTest.parameter.providerAuthorisations.bspAuthorisation = new P2POSRAuthorisation('type', 'effectiveDate', 'BSB', 'bankAccountNumber', 'bankAccountName', 'contactName', 'contactPhone','contactEmail'
        , new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'), new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'));

        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRUpdateAuthorisationTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        /* build request parameters. */
        P2POSRClientTest.parameter.tfNSWProviderNumber = '9999999999';
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation = new P2POSRAuthorisation();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.type = 'type';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.effectiveDate = 'effectiveDate';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.BSB = 'BSB';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountNumber = 'bankAccountNumber';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountName = 'bankAccountName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactName = 'contactName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactPhone = 'contactPhone';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactEmail = 'contactEmail';
        /* just for code coverage */
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress();
        
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        
        P2POSRClientTest.parameter.providerAuthorisations.bspAuthorisation = new P2POSRAuthorisation('type', 'effectiveDate', 'BSB', 'bankAccountNumber', 'bankAccountName', 'contactName', 'contactPhone','contactEmail'
        , new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'), new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'));

        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRCancelAuthorisationTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRAuthorisationResponseParserVisitor visitor = new P2POSRAuthorisationResponseParserVisitor();
        /* build request parameters. */
        P2POSRClientTest.parameter.tfNSWProviderNumber = '9999999999';
        P2POSRClientTest.parameter.providerAuthorisations = new P2POSRAuthorisations();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation = new P2POSRAuthorisation();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.type = 'type';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.effectiveDate = 'effectiveDate';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.BSB = 'BSB';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountNumber = 'bankAccountNumber';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.bankAccountName = 'bankAccountName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactName = 'contactName';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactPhone = 'contactPhone';
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.contactEmail = 'contactEmail';
        /* just for code coverage */
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress();
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress();
        
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.postalAddress = new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        P2POSRClientTest.parameter.providerAuthorisations.tspAuthorisation.streetAddress = new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state');
        
        P2POSRClientTest.parameter.providerAuthorisations.bspAuthorisation = new P2POSRAuthorisation('type', 'effectiveDate', 'BSB', 'bankAccountNumber', 'bankAccountName', 'contactName', 'contactPhone','contactEmail'
        , new P2POSRPostalAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'), new P2POSRStreetAddress('addressLine1', 'addressLine2', 'suburb', 'postCode', 'state'));

        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CANCEL_AUTHORISATION_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('99999' == visitor.p2POSRAuthorisationResponse.tfNSWProviderNumber);
        System.assert('1111111111' == visitor.p2POSRAuthorisationResponse.RNSWCustomerID);
    }
    
    @isTest
    private static void p2POSRCreateAssessmentTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRCUAssessmentResponseParserVisitor visitor = new P2POSRCUAssessmentResponseParserVisitor();
        P2POSRClientTest.parameter.p2pOSRAssessments = new P2POSRAssessments();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment('123456789', 'TT', '10100550', null, 200.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment('123456789', 'TB', '20100550', null, 300.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert(2 == visitor.p2POSRAssessmentResponses.size());
    }
    
    @isTest
    private static void p2POSRCreateAssessmentWithErrorsTest()  {
         /* Account with Company RecordType */
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth;
        
        tspauth.Start_Date__c = Date.parse('10/12/2017');
        update tspauth;  
        
        /* Authorisation__c Related to Individual account */
        Authorisation__c bspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'BSP');
        insert bspauth;
        
        bspauth.Start_Date__c = Date.parse('10/12/2017');
        update bspauth;  
        
        /* Lookup to TSP and BSP both */
        Tax_Payer_Registration__c taxpayerRegistrationRecord = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                             Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS,
                                                                                             Taxi_Service_Provider_Number__c = tspauth.Id, Booking_Service_Provider_Number__c = bspAuth.Id,
                                                                                             BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                             Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                             Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                             Levy_Notification_Address_Street__c = 'castle');
        insert taxpayerRegistrationRecord;
        
        Date firstDateOfPreviousMonth = Date.newInstance(2017, 12, 1);
        Date lastDateOfPreviousMonth = Date.newInstance(2017, 12, 31);
        
        Assessment__c assessmentRecord = new Assessment__c();
        assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecord.Status__c = 'Issued';
        assessmentRecord.Assessment_Type__c = 'Assessment';
        assessmentRecord.Period_Start_Date__c = firstDateOfPreviousMonth;
        assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
        assessmentRecord.Levy__c = Decimal.valueOf(System.Label.Levy_Amount_Per_Trip);
        assessmentRecord.Payment_Due_Date__c = Date.newInstance(2018, 02, 26);
        assessmentRecord.Annual_Estimates__c = '151 to 400';
        assessmentRecord.TSP_Transaction_Count__c = 100;
        assessmentRecord.BSP_Transaction_Count__c = 200;
        assessmentRecord.Total_Levy_Amount__c = 300;
        assessmentRecord.TSP_Levy_Amount__c = 100;
        assessmentRecord.BSP_Levy_Amount__c = 200;
        insert assessmentRecord;
        
        Id accountRecId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecordId = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountRecId];
        Assessment__c assessmentRec = [SELECT Id, Name, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecordId.Id];
      
        system.debug('xxx '+ assessmentRec.Name);
        
        P2POSRClient client = new P2POSRClient();
        P2POSRCUAssessmentResponseParserVisitor visitor = new P2POSRCUAssessmentResponseParserVisitor();
        P2POSRClientTest.parameter.p2pOSRAssessments = new P2POSRAssessments();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment('123456789', 'TTE', '10100550', null, 200.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment('123456789', 'TB', '20100550', null, 300.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST, visitor, P2POSRClientTest.parameter);
        
        //visitor.finalize();
        List<P2POSRAssessmentResponse> p2POSRAssessmentResponses = new List<P2POSRAssessmentResponse>();
        Map<String, String> levyAssessmentIdVsRequestParameter = new Map<String, String>();
    	Map<String, String> levyAssessmentIdVsRequestType = new Map<String, String>();
        p2POSRAssessmentResponses.addAll(visitor.p2POSRAssessmentResponses);
        for (P2POSRAssessmentResponse response : visitor.p2POSRAssessmentResponses) {
            levyAssessmentIdVsRequestParameter.put(response.levyAssessmentID, visitor.requestParameters);
            levyAssessmentIdVsRequestType.put(response.levyAssessmentID, visitor.requestType);
        }
        P2POSRCUAssessmentResponseParserVisitor.finalize(p2POSRAssessmentResponses, levyAssessmentIdVsRequestParameter, levyAssessmentIdVsRequestType);

        System.assert(200 == visitor.responseStatus);
        System.assert(2 == visitor.p2POSRAssessmentResponses.size());
        System.assert(0 < visitor.p2POSRAssessmentResponses.get(0).errors.size());
        System.assert(0 < visitor.p2POSRAssessmentResponses.get(1).errors.size());
    }

    @isTest
    private static void p2POSRCreateAssessmentWithFaultTest()  {
         /* Account with Company RecordType */
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth;
        
        tspauth.Start_Date__c = Date.parse('10/12/2017');
        update tspauth;  
        
        /* Authorisation__c Related to Individual account */
        Authorisation__c bspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'BSP');
        insert bspauth;
        
        bspauth.Start_Date__c = Date.parse('10/12/2017');
        update bspauth;  
        
        /* Lookup to TSP and BSP both */
        Tax_Payer_Registration__c taxpayerRegistrationRecord = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                             Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS,
                                                                                             Taxi_Service_Provider_Number__c = tspauth.Id, Booking_Service_Provider_Number__c = bspAuth.Id,
                                                                                             BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                             Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                             Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                             Levy_Notification_Address_Street__c = 'castle');
        insert taxpayerRegistrationRecord;
        
        Date firstDateOfPreviousMonth = Date.newInstance(2017, 12, 1);
        Date lastDateOfPreviousMonth = Date.newInstance(2017, 12, 31);
        
        Assessment__c assessmentRecord = new Assessment__c();
        assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecord.Status__c = 'Issued';
        assessmentRecord.Assessment_Type__c = 'Assessment';
        assessmentRecord.Period_Start_Date__c = firstDateOfPreviousMonth;
        assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
        assessmentRecord.Levy__c = Decimal.valueOf(System.Label.Levy_Amount_Per_Trip);
        assessmentRecord.Payment_Due_Date__c = Date.newInstance(2018, 02, 26);
        assessmentRecord.Annual_Estimates__c = '151 to 400';
        assessmentRecord.TSP_Transaction_Count__c = 100;
        assessmentRecord.BSP_Transaction_Count__c = 200;
        assessmentRecord.Total_Levy_Amount__c = 300;
        assessmentRecord.TSP_Levy_Amount__c = 100;
        assessmentRecord.BSP_Levy_Amount__c = 200;
        insert assessmentRecord;
        
        Id accountRecId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecordId = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountRecId];
        Assessment__c assessmentRec = [SELECT Id, Name, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecordId.Id];
      
        system.debug('xxx '+ assessmentRec.Name);
        
        P2POSRClient client = new P2POSRClient();
        P2POSRCUAssessmentResponseParserVisitor visitor = new P2POSRCUAssessmentResponseParserVisitor();
        P2POSRClientTest.parameter.p2pOSRAssessments = new P2POSRAssessments();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForTspAuthorisation = new P2POSRAssessment('123456789', 'TTE', '10100550', null, 200.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessments.assessmentForBspAuthorisation = new P2POSRAssessment('123456789', 'TB', '20100550', null, 300.89, null, '2018-02-26', '2017-12-01', '2017-12-31');
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST, visitor, P2POSRClientTest.parameter);
        //visitor.finalize();
        
        List<P2POSRAssessmentResponse> p2POSRAssessmentResponses = new List<P2POSRAssessmentResponse>();
        Map<String, String> levyAssessmentIdVsRequestParameter = new Map<String, String>();
    	Map<String, String> levyAssessmentIdVsRequestType = new Map<String, String>();
        p2POSRAssessmentResponses.addAll(visitor.p2POSRAssessmentResponses);
        for (P2POSRAssessmentResponse response : visitor.p2POSRAssessmentResponses) {
            levyAssessmentIdVsRequestParameter.put(response.levyAssessmentID, visitor.requestParameters);
            levyAssessmentIdVsRequestType.put(response.levyAssessmentID, visitor.requestType);
        }
        P2POSRCUAssessmentResponseParserVisitor.finalize(p2POSRAssessmentResponses, levyAssessmentIdVsRequestParameter, levyAssessmentIdVsRequestType);
		        
        System.assert(200 == visitor.responseStatus);
        System.assert(2 == visitor.p2POSRAssessmentResponses.size());
        System.assert(0 < visitor.p2POSRAssessmentResponses.get(0).errors.size());
        System.assert(0 < visitor.p2POSRAssessmentResponses.get(1).errors.size());
    }    
    /*@isTest
    private static void p2POSRUpdateAssessmentTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRCUAssessmentResponseParserVisitor visitor = new P2POSRCUAssessmentResponseParserVisitor();
        P2POSRClientTest.parameter.p2pOSRAssessment = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessment = new P2POSRAssessment('123456789', 'TT', '123456789', '123456789', 1200.89, 1200.89, '2008-12-31', '2008-12-31', '2012-12-31');
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_ASSESSMENT_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('123456789' == visitor.p2POSRAssessmentResponse.levyAssessmentID);
    }
    
    @isTest
    private static void p2POSRGetAssessmentTest()  {
        P2POSRClient client = new P2POSRClient();
        P2POSRGetAssessmentResponseParserVisitor visitor = new P2POSRGetAssessmentResponseParserVisitor();
        P2POSRClientTest.parameter.p2pOSRAssessment = new P2POSRAssessment();
        P2POSRClientTest.parameter.p2pOSRAssessment.TfNSWProviderNumber = '999999';
        P2POSRClientTest.parameter.p2pOSRAssessment.regnType = 'TT';
        P2POSRClientTest.parameter.p2pOSRAssessment.reportingPeriodStartDate = '2008-12-31';
        P2POSRClientTest.parameter.p2pOSRAssessment.reportingPeriodEndDate = '2008-12-31';
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
    }
    
    @isTest
    private static void p2POSRGetPaymentStatusRecordCountTest()  {
        P2POSRClient client = new P2POSRClient();
        OSRPaymentStatusRCResponseParserVisitor visitor = new OSRPaymentStatusRCResponseParserVisitor();
        P2POSRClientTest.parameter.paymentStatusReportDate = '2018-02-16';
        client.call(P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST, visitor, P2POSRClientTest.parameter);
        System.assert(200 == visitor.responseStatus);
        System.assert('2018-02-16' == visitor.p2POSRGetPaymentStatusReportResponse.reportDate);
        System.assert(5 == visitor.p2POSRGetPaymentStatusReportResponse.totalRecordCount);
        System.assert(1 == visitor.p2POSRGetPaymentStatusReportResponse.totalPageCount);
    }*/
}