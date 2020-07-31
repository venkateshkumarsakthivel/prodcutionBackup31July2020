public with sharing class AuthorisationFeeCalculationBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Date previousFinancialYearEnd {get; set;}
    private Date previousFinancialYearStart {get; set;}
    private list<Base_Fee_Confi__mdt> baseFeelst {get; set;}
    private Consumer_Price_Index_Configuration__mdt cpiObj {get; set;}
    private String priceBookEntryID {get; set;}
    private SET<String> statusValues {get; set;}
    private Date TwentyFirstBusinessDay {get; set;}
    private SET<String> processedAccountIds {get; set;}
    private String pricebook2ID {get; set;}
    private String orderDesciption {get; set;}
    private BusinessHours businessHours {get; set;}
    public static final boolean SendAuthorisationNotice = false; 
    public set<ID> setCheck = new set<ID>();
    //public set<ID> setAccountDuplicateCheck = new set<ID>();
    private void populateRequiredData() {
        
        //set to store Ids of account after processing on it
        processedAccountIds = new SET<String>();
        
        // fetch previoud financial year period
        Integer currentYear = System.now().Year();
        
        Auth_Fee_Collection_Period_Configuration__mdt  FeeCollectionPeriod = [SELECT Start_Date__c, End_Date__c 
                                                                              FROM Auth_Fee_Collection_Period_Configuration__mdt
                                                                              WHERE Year__c = :String.valueOf(currentYear) LIMIT 1];
        
        previousFinancialYearStart = FeeCollectionPeriod.Start_Date__c;
        previousFinancialYearEnd = FeeCollectionPeriod.End_Date__c;
        
        //Set order description according to fee colletion period
        List<String> months = new List<String>{' ','Jan','Feb','Mar','Apr','May','June','July','Aug','Sept','Oct','Nov','Dec'};
            
            String periodStartMonth = months[previousFinancialYearStart.month()];
        String periodEndMonth = months[previousFinancialYearEnd.month()];
        
        orderDesciption = 'Authorisation fee Period: ' + previousFinancialYearStart.day() + ' ' + periodStartMonth + ' ' + previousFinancialYearStart.year();
        orderDesciption += ' to ' + previousFinancialYearEnd.day() + ' ' + periodEndMonth + ' '+ previousFinancialYearEnd.year();
        
        // fetch base price configuration custom metadata
        baseFeelst = [SELECT Low__c, High__c, Base_Fee__c FROM Base_Fee_Confi__mdt order by Low__c asc limit 1000];
        
        // fetch CPI configuration custom metadata
        cpiObj = [SELECT CPI__c, Previous_CPI__c FROM Consumer_Price_Index_Configuration__mdt WHERE DeveloperName = 'Consumer_Price_Index' limit 1];
        
        // fetch pricebookEntry Id using product name and pricebookname
        priceBookEntryID = [SELECT Id FROM PriceBookEntry 
                            WHERE PriceBook2.Name = 'P2P Default' AND Product2.Name = 'Authorisation Fees - Annual'
                           ].Id;
        
        // fetch pricebook2Id for order
        pricebook2ID = [SELECT Id FROM Pricebook2 WHERE Name = :System.Label.ASP_Pricebook].Id;
        
        
        //Find all Status picklist values and remove unnecessary
        statusValues= new SET<String>();
        Schema.DescribeFieldResult fieldResult = Assessment__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusValues.add(pickListVal.getLabel());
        }  
        statusValues.remove('Open');
        statusValues.remove('Superseded');
        
        //Find 32 business Day as the email is sent on Aug 12th and batch job is run at Aug 1st. Actual due days is 21 days.
        businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
        Date refDate = system.today();
        refDate = refDate.addDays(32);
        TwentyFirstBusinessDay = getBusinessDay(refDate);
    }        
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        populateRequiredData();
        
        //Auth required status
        SET<String> AuthStatusSet = new SET<String>{'Granted With Conditions','Granted Unconditionally',
            'Lapsed','Granted','Suspended'};      
                
                SET<String> authTypeSet = new SET<String>{'TSP', 'BSP'};
                    
                    SET<String> AuthStatusSet2 = new SET<String>{'Cancelled'};
                        // String authid='a0G6F0000227Vkc'; 
                        //'AND (id=:authid) ' +
                        // Status__c = \'Cancelled\' 
                        //  'AND Do_not_send_Authorisation_Fee_notice__c =:SendAuthorisationNotice ' +  
                        //  + 'LIMIT 50' 
                        //                   'OR (Status__c IN : AuthStatusSet2 AND (Decision_Date__c <= :previousFinancialYearEnd AND Decision_Date__c >= :previousFinancialYearStart))) ';                                       
                        String query = 'SELECT Id, Service_Provider__c,decision_reason__c FROM Authorisation__c '+
                        'WHERE (Authorisation_Type__c IN :authTypeSet) '  + 
                        'AND ((Status__c IN :AuthStatusSet AND (Start_Date__c <= :previousFinancialYearEnd AND End_Date__c >= :previousFinancialYearStart)) '+
                        'OR (Status__c IN : AuthStatusSet2 AND (Decision_Date__c >= :previousFinancialYearStart))) ';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        try {
            
            SET<String> accountsIds = new SET<String>();
            
            Map<String, String> accountIdVsPrimaryContactId = new Map<String, String>();
            SET<String> authIdsInScope = new SET<String>();
            List<Authorisation__c> authsInScope = new List<Authorisation__c>();
            map<String, AuthorisationFeeWrapper> acctIDVsAuthFeeWrp = new map<String, AuthorisationFeeWrapper>();
            list<Order> orderRecordsToBeCreated = new list<Order>();
            list<OrderItem> orderItemRecordsToBeCreated = new list<OrderItem>(); 
            Integer sumOfTripCounts=0;
            Integer sumOfBSPCounts=0;
            Integer sumOfTSPCounts=0;
            Integer baseFee = 0;
            
            authsInScope = (List<Authorisation__c>) scope;
            system.debug(authsInScope);
            
            
            
            for(Authorisation__c auth : authsInScope) {
                
                System.debug('Account Info' + auth.Service_Provider__c);
                
                
                if(!processedAccountIds.contains(auth.Service_Provider__c)) {
                    processedAccountIds.add(auth.Service_Provider__c);
                    
                    if(String.isBlank(auth.decision_reason__c)){
                        accountsIds.add(auth.Service_Provider__c);
                     	setCheck.add(auth.Service_Provider__c);
                    }
                    else if(auth.decision_reason__c != Null ){
                        
                        if(!auth.decision_reason__c.contains('Voluntary withdraw by applicant')){
                            accountsIds.add(auth.Service_Provider__c);
                            setCheck.add(auth.Service_Provider__c);
                        }
                        
                    }
                    
                } 
                
                else if(!setCheck.contains(auth.Service_Provider__c))  {
                    
                    if(String.isBlank(auth.decision_reason__c)){
                        accountsIds.add(auth.Service_Provider__c);
                        setCheck.add(auth.Service_Provider__c);
                    } else if(auth.decision_reason__c != Null ){
                        
                        if(!auth.decision_reason__c.contains('Voluntary withdraw by applicant')){
                            accountsIds.add(auth.Service_Provider__c);
                            setCheck.add(auth.Service_Provider__c);
                        }
                    }  
                }
            }
            
            
            
            Map<Id, Tax_Payer_Registration__c> newRegistrations = new map<Id, Tax_Payer_Registration__c>();
            Map<Id, Id> taxPayerLookup = new map<Id, Id>();    
            List<Tax_Payer_Registration__c> updateTPRList = new List<Tax_Payer_Registration__c>();
            //SET<String> tprIds = new SET<String>();
            List<Account> accList =[select Id,(select Id,Rebate_Approved__c,Exemption_Approved__c,Service_Provider_Name__c from Tax_Payer_Registrations__r where status__c ='Active' limit 1) from Account where Id in: accountsIds];
            for(Account acc: accList){
                if(acc.Tax_Payer_Registrations__r.Size() > 0 ){
                    //tprIds.add(acc.Tax_Payer_Registrations__r[0].Id);
                    //acc.Tax_Payer_Registrations__r[0].Id
                    newRegistrations.put(acc.Tax_Payer_Registrations__r[0].Id,acc.Tax_Payer_Registrations__r[0]);
                    taxPayerLookup.put(acc.Id,acc.Tax_Payer_Registrations__r[0].Id);
                    system.debug('Tax Payer');
                }
            }     
            
            
            //Query Primary Contact on Account
            for(Contact primaryContact : [SELECT Id, AccountId FROM Contact WHERE Primary_Contact__c = True AND AccountId IN :accountsIds]) {
                accountIdVsPrimaryContactId.put(primaryContact.AccountId, primaryContact.Id);
            }
            
            //Query on Assessment to get Sum of BSP_Transaction_Count__c, TSP_Transaction_Count__c
            //with status not equal 'Open' and 'Suspended'
            //period end date in previous financial year
            AggregateResult[] groupedAssessments = [SELECT Account__c, SUM(BSP_Transaction_Count__c), SUM(TSP_Transaction_Count__c)
                                                    FROM Assessment__c
                                                    WHERE Account__c IN :accountsIds
                                                    AND Status__c IN :statusValues
                                                    AND Period_End_Date__c >= :previousFinancialYearStart
                                                    AND Period_End_Date__c <= :previousFinancialYearEnd
                                                    GROUP BY Account__c];
            
            
            //set data in AuthorisationFeeWrapper
            for (AggregateResult ar : groupedAssessments)  {
                
                sumOfBSPCounts = Integer.valueOf(ar.get('expr0'))!= null ? Integer.valueOf(ar.get('expr0')) : 0;
                sumOfTSPCounts = Integer.valueOf(ar.get('expr1'))!= null ? Integer.valueOf(ar.get('expr1')) : 0;
                String accId = String.valueOf(ar.get('Account__c'));
                
                System.debug('account id>>' + accId + sumOfBSPCounts + sumOfTSPCounts);
                AuthorisationFeeWrapper authFee = new AuthorisationFeeWrapper(sumOfTSPCounts, sumOfBSPCounts, accId);
                authFee.baseFee = getBaseFee(authFee.totalBSPAndTSPCount, baseFeelst);
                acctIDVsAuthFeeWrp.put(accId, authFee);
            }
            for(Tax_Payer_Registration__c taxpayer: newRegistrations.values()){
                
                if(acctIDVsAuthFeeWrp.containskey(taxpayer.Service_Provider_Name__c))
                {
                    system.debug('Count');
                    taxpayer.Total_BSP_Transaction_Count__c = acctIDVsAuthFeeWrp.get(taxpayer.Service_Provider_Name__c).BSPCount;
                    taxpayer.Total_TSP_Transaction_Count__c = acctIDVsAuthFeeWrp.get(taxpayer.Service_Provider_Name__c).TSPCount;
                    taxpayer.Authorisation_fee__c = acctIDVsAuthFeeWrp.get(taxpayer.Service_Provider_Name__c).baseFee * (cpiObj.CPI__c/cpiObj.Previous_CPI__c);
                    updateTPRList.add(taxpayer);
                    system.debug('UpdateTpRList' + updateTPRList);
                }
                
                
            }
            
            for(String acctID : accountsIds){
                
                //If assessment exist for the account
                if(acctIDVsAuthFeeWrp.containsKey(acctID)){
                    Order ordObj = new Order();
                    ordObj.accountId = acctID;
                    ordObj.Tax_Payer_Registration__c = taxPayerLookup.get(acctID);
                    ordObj.pricebook2ID = pricebook2ID;
                    ordObj.Status = 'Payment Due';
                    ordObj.EffectiveDate = TwentyFirstBusinessDay; // due date
                    ordObj.Description = orderDesciption;
                    ordObj.Type = 'Authorisation fee'; // Portal type
                    ordObj.BillToContactId = accountIdVsPrimaryContactId.get(acctID);
                    ordObj.Internal_Order_Number__c = Label.Internal_Order_Number;
                    orderRecordsToBeCreated.add(ordObj);
                }
                //If there is no assessment for the account
                else{
                    AuthorisationFeeWrapper authFee = new AuthorisationFeeWrapper(0, 0, acctID);
                    authFee.baseFee = getBaseFee(authFee.totalBSPAndTSPCount, baseFeelst);
                    System.debug('base fee >> ' + authFee.baseFee );
                    acctIDVsAuthFeeWrp.put(acctID, authFee);
                    
                    Order ordObj = new Order();
                    ordObj.accountId = acctID;
                    ordObj.Tax_Payer_Registration__c = taxPayerLookup.get(acctID);
                    ordObj.pricebook2ID = pricebook2ID;
                    ordObj.Status = 'Payment Due';
                    ordObj.EffectiveDate = TwentyFirstBusinessDay; // due date
                    ordObj.Description = orderDesciption;
                    ordObj.Type = 'Authorisation fee'; // Portal type
                    ordObj.BillToContactId = accountIdVsPrimaryContactId.get(acctID);
                    ordObj.Internal_Order_Number__c = Label.Internal_Order_Number;
                    orderRecordsToBeCreated.add(ordObj);
                    
                } 
                
            }
            insert orderRecordsToBeCreated;
            
            Decimal unitPrice;
            for(Order ordObj : orderRecordsToBeCreated){
                OrderItem ordItem = new OrderItem();
                ordItem.OrderId = ordObj.Id;
                ordItem.Annual_BSP_Count__c = acctIDVsAuthFeeWrp.get(ordObj.accountID).BSPCount;
                ordItem.Annual_TSP_Count__c = acctIDVsAuthFeeWrp.get(ordObj.accountID).TSPCount;
                
                unitPrice = (acctIDVsAuthFeeWrp.get(ordObj.accountID).baseFee * (cpiObj.CPI__c/cpiObj.Previous_CPI__c));
                ordItem.UnitPrice = Math.round(unitPrice);
                ordItem.priceBookEntryID = priceBookEntryID;
                ordItem.Quantity= 1;
                ordItem.Description = 'Annual authorisation fee for ASP';
                ordItem.Transaction_Type__c = 'Authorisation Fee';
                orderItemRecordsToBeCreated.add(ordItem);
            }
            
            insert orderItemRecordsToBeCreated;
            if(updateTPRList.Size() > 0 )
                update updateTPRList;
            /*
List<Order> AuthorisationfeeorderList =[select TotalAmount,Payment_Reference__c from order where Type='Authorisation fee'] ;
List<Order> AuthorisationfeeupdateorderList = new List<Order>(); 
for( Order ord : AuthorisationfeeorderList)
{
Order ordupdate= new Order(Id=ord.Id);
ordupdate.Bpay_Reference_Authfee__c=  BPAYiCRNUtility.generateICRN(ord.TotalAmount,ord.Payment_Reference__c);
system.debug( ordupdate.Bpay_Reference_Authfee__c);
AuthorisationfeeupdateorderList.add(ordupdate);
system.debug(AuthorisationfeeupdateorderList);
system.debug(AuthorisationfeeupdateorderList.Size());
}
if(AuthorisationfeeupdateorderList.Size() > 0 )
update AuthorisationfeeupdateorderList;  
*/      
            
        }catch (Exception ex) {
            //Insert Application Log
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AuthorisationFeeCalculationBatch', 'execute', ex.getMessage(), null, ex, null, null, null, null);        
        }
    }
    
    
    //get business day
    public Date getBusinessDay(Date refDate) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, refDate);
        
        if(isInBusinessHours) {
            return refDate;
        } else {
            refDate = refDate.addDays(1);
            return getBusinessDay(refDate);
        }
    }
    
    private Decimal getBaseFee(Integer totalTripCount, list<Base_Fee_Confi__mdt> baseFeelst){
        
        Decimal baseFee = 0;
        for(Base_Fee_Confi__mdt bsFeeObj : baseFeelst){
            
            if(totalTripCount >= bsFeeObj.Low__c && totalTripCount <= bsFeeObj.High__c){
                return bsFeeObj.Base_Fee__c;
            }
            baseFee = bsFeeObj.Base_Fee__c;
        }
        return baseFee;
    }
    
    public void finish(Database.BatchableContext batchableContext) { 
        
        Database.executeBatch(new BatchToUpdateBpayReferenceAuthFee());
        
    }
    
    public class AuthorisationFeeWrapper{
        
        public Integer BSPCount;
        public Integer TSPCount;
        public Integer totalBSPAndTSPCount;
        public String accountID;
        public String orderID;
        public Decimal baseFee;
        
        public AuthorisationFeeWrapper(Integer TSPCount, Integer BSPCount, String accountID){
            baseFee = 0;
            this.totalBSPAndTSPCount = TSPCount + BSPCount;
            this.TSPCount = TSPCount;
            this.BSPCount = BSPCount;
            this.accountID = accountID;         
        }       
    }
}