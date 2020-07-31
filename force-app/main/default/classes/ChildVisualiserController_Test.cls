@isTest
public class ChildVisualiserController_Test{
    @istest
    public static void getFilteredRecordsTest(){
        Account acc = createAccount();
        Test.startTest();
        ChildVisualiserController.getFilterdRecords(acc.Id, 'Contact', 'Contact_fields','AccountId',
                                                   'Birthdate', 'Equals', String.valueof(Date.Today()), 'DATE');
        ChildVisualiserController.getFilterdRecords(acc.Id, 'Contact', 'Contact_fields', 'AccountId',
                                                   'Birthdate','Not Equals',String.valueof(Date.Today()),'DATE');
        ChildVisualiserController.getFilterdRecords(acc.Id, 'Contact', 'Contact_fields','AccountId',
                                                    'Birthdate','Greater Than Equals',String.valueof(Date.Today()),'DATE');
        ChildVisualiserController.getFilterdRecords(acc.Id, 'Contact', 'Contact_fields','AccountId',
                                                    'Birthdate','Less Than Equals',String.valueof(Date.Today()),'DATE');
        Test.stopTest();
    }
    @istest
    public static void getFilteredRecordsTest1(){
        Account acc = createAccount();
        Test.startTest();
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId',
                                                    'Account.AnnualRevenue','Equals','1000','CURRENCY');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId',
                                                    'Account.AnnualRevenue','Not Equals','1000','CURRENCY');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId',
                                                    'Account.AnnualRevenue','Greater Than Equals','1000','CURRENCY');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId',
                                                    'Account.AnnualRevenue','Less Than Equals','1000','CURRENCY');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId',
                                                    'Account.AnnualRevenue','Contains','1000','CURRENCY');
        Test.stopTest();
    }    
    @istest
    public static void getFilteredRecordsTest2(){
        Account acc = createAccount();
       
        Child_Visualiser_Information__c cs = new Child_Visualiser_Information__c();
        cs.Name='Account-Contact';
        cs.Field_Set_Name__c='Contact_fields';
        cs.Buttons__c ='4';
        cs.Child_Object_Name__c='Contact';
        cs.filters__c='AnnualRevenue,>=,50000,#FFFBE2';
        cs.Number_of_Columns__c=5;
        cs.Related_by_Field__c='AccountId';
        cs.Unique_Name__c ='Contacts';
        insert cs;
         Test.startTest();
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId','Name','Equals','Name','TEXT');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId','Name','Not Equals','Name','TEXT');
        ChildVisualiserController.getFilterdRecords(acc.Id,'Contact','Contact_fields','AccountId','Name','Contains','Name','TEXT');
        ChildVisualiserController.picklistValues('Contact','LeadSource');
        ChildVisualiserController.getPluralLabel('Contact');
        ChildVisualiserController.getRecords(acc.Id,'Contact','Contact_fields','AccountId','Name','ASC',true);
        ChildVisualiserController.getCustomSettingInfo('Contacts');
         Test.stopTest();
    }   
    @istest
    public static void getUserInfo(){
        ChildVisualiserController.getUserInfo();
    }   
    @istest
    public static void getFields(){
        FieldSetUtility.getFields('Contact', 'Contact_fields');
    }   
    @istest
    public static void ConfigureChildVisualiserControllerTest(){
        ConfigureChildVisualiserController.getChildRelations('Account');
        ConfigureChildVisualiserController.getFieldSetNames('Contact');
        ConfigureChildVisualiserController.CustomSettingsParser Parser = new ConfigureChildVisualiserController.CustomSettingsParser();
        Parser.uniqueName = 'Contacts';
        Parser.relatedField = 'AccountId';
        Parser.parentObjectName = 'Account';
        Parser.fieldSetName = 'Contact_fields';
        Parser.columns = '4';
        Parser.childObjectName ='Contact';
        Parser.buttons ='3';
        String record = JSON.serialize(Parser);
        Test.startTest();
        ConfigureChildVisualiserController.saveCustomSettingsRecord(record,true);
        ConfigureChildVisualiserController.saveCustomSettingsRecord(record,false);
        ConfigureChildVisualiserController.updateCustomSettingRecord(Parser);
        Test.stopTest();
    }
    @istest
    public static void TypeCastUtilityTest(){
        Account acc = createAccount();
         Test.startTest();
        TypeCastUtility.typeCastField(1000,'CURRENCY');
        TypeCastUtility.typeCastField(Date.Today(),'DATE');
        TypeCastUtility.typeCastField(System.now(),'DATETIME');
        Test.stopTest();
   }
    
    private static Account createAccount(){
        Account acc = new Account(Name = 'DEMO ACCOUNT');
        insert acc;
        
        Contact cont1 = new Contact(FirstName = 'Contact 1', LastName = 'Test', AccountId = acc.Id, Email='demo@demo.com');
        insert cont1;
        
        return acc;
    }
}