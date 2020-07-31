@isTest
public class AuthorisationContactCreatorTest {	        
    
    @isTest
    public static void AuthorisationContactCreatorTest(){
        
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000') ;
        insert ac;                             
        
        test.startTest();
        List<Authorisation__c> authList = new List<Authorisation__c>();
        List<Contact> contList = new List<Contact>();
        List<Authorisation_Contact__c> authCont = new List<Authorisation_Contact__c>();                
        
        Contact conRec = new Contact(LastName ='testCon', AccountId = ac.Id, Email='test@contest.com');
        contList.add(conRec);
        insert contList;
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = ac.Id);        
        authList.add(authRec);  
        insert authList;
        
        AuthorisationContactCreator auth = new AuthorisationContactCreator(contList, authList);
        authCont = auth.create();        
        test.stopTest();

		system.assert(authCont != null);
        
    }   
}