@isTest
                    public class RequestInternalReviewControllerTest {
                        
                        @testSetup 
                        static void setup(){
                            Id ownerid = GlobalUtility.getOwnerId();
                            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
                            insert ac;
                            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
                            insert con;
                        }
                        
                        @isTest
                        private static void getAccountAndContactDetailsTest(){
                            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
                            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
                            
                            Id p = GlobalUtility.getASPProfile().id;
                            
                            User user = new User(alias = 'test123', email='test123@noemail.com',
                                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                                 contactId = conId,
                                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                            
                            insert user;
                            test.startTest();
                            system.runAs(user){
                                String str = RequestInternalReviewController.getAccountAndContactDetails();
                                system.assert(str!='');
                                
                            }
                            test.stopTest();
                            
                        }
                        
                        @isTest
                        private static void getAccountAndContactDetailsExceptionTest(){
                            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
                            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
                            
                            Id p = GlobalUtility.getASPProfile().id;
                            
                            User user = new User(alias = 'test123', email='test123@noemail.com',
                                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                                 contactId = conId,
                                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                            
                            insert user;
                            
                            test.startTest();
                            String str = RequestInternalReviewController.getAccountAndContactDetails();
                            system.assert(str!='');
                            test.stopTest();     
                            
                            
                        }
                        
                        @isTest
                        private static void saveAuthorisationRequestForInternalReviewTest(){
                            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
                            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
                            
                            Id p = GlobalUtility.getASPProfile().id;
                            
                            User user = new User(alias = 'test123', email='test123@noemail.com',
                                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                                 contactId = conId,
                                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                            
                            insert user;
                            test.startTest();
                            system.runAs(user){
                                
                                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New');
                                String caseRec = Json.serialize(c);
                                
                                String caseNum =  RequestInternalReviewController.saveAuthorisationRequestForInternalReview(caseRec);
                                system.assert(caseNum!='');   
                            }
                            test.stopTest();
                        }
                        @isTest
                        private static void saveAuthorisationRequestForInternalReviewExceptionTest(){
                            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
                            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
                            
                            Id p = GlobalUtility.getASPProfile().id;
                            
                            User user = new User(alias = 'test123', email='test123@noemail.com',
                                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                                 contactId = conId,
                                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                            
                            insert user;
                            test.startTest();
                            system.runAs(user)
                            {
                                String caseRec;
                                String caseNum =  RequestInternalReviewController.saveAuthorisationRequestForInternalReview(caseRec);
                                   String message = Json.serialize(caseNum);
                                //system.assertEquals('null' ,message );  
                                 system.assert(caseNum!='');    
                            }
                            test.stopTest();
                        }
                        
                    }