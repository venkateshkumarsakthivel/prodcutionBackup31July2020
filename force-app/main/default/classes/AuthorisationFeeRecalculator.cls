public class AuthorisationFeeRecalculator {

    public void checkWithPreviousYearAuthorisationFee(List<OrderItem> newOrderItems) {
        
        List<OrderItem> newAuthFeeOrderItems = new List<OrderItem>();
        Set<String> accountIds = new Set<String>();
        Set<String> orderIds = new Set<String>();
        Map<String, Decimal> accountIdVsPaymentInLastYear = new Map<String, Decimal>();
        Map<String, String> orderIdVsAccountId = new Map<String, String>();
        
        //List of new OrderItem of type = 'Authorisation Fee'
        for(OrderItem ordItem : newOrderItems) {
            
            if(ordItem.Transaction_Type__c == 'Authorisation Fee') {
                newAuthFeeOrderItems.add(ordItem);
                orderIds.add(ordItem.OrderId);
            }
        }
        
        if(newAuthFeeOrderItems.size() > 0) {
            
            //list of respective account ids for new OrderItem of type = 'Authorisation Fee'
            for(Order payment : [SELECT Id, AccountId FROM Order WHERE Id IN :orderIds]) {
                
                accountIds.add(payment.AccountId);
                orderIdVsAccountId.put(payment.Id, payment.AccountId);
            }
            
            //Query on Previous year payment of type = 'Authorisation Fee'
            List<Order> ordersCreatedInPreviousYear = [SELECT Id, TotalAmount, AccountId 
                                                       FROM Order 
                                                       WHERE AccountId IN :accountIds
                                                       AND	Type = 'Authorisation fee'
                                                       AND EffectiveDate = LAST_YEAR];
            
            //create map of account id vs previous year payment amount
            for(Order paymentLastYear : ordersCreatedInPreviousYear) {
                accountIdVsPaymentInLastYear.put(paymentLastYear.AccountId , paymentLastYear.TotalAmount);
            }
            
            //if the current year auth fee is less than previous year then update it with previous year fee
            for(OrderItem ordItem : newAuthFeeOrderItems) {
                
                String accId = orderIdVsAccountId.get(ordItem.OrderId);
                Decimal lastYearFee = accountIdVsPaymentInLastYear.get(accId);
                
                if(ordItem.UnitPrice < lastYearFee) {
                    ordItem.UnitPrice = lastYearFee;
                }
            }
            
        }
        
    }
    
    public void calculateAuthorisationFee(Map<Id, OrderItem> newOrderItems, Map<Id, OrderItem> oldOrderItems) {
        
        //Query All Base fees
        List<Base_Fee_Confi__mdt> baseFeelst = [SELECT Low__c, High__c, Base_Fee__c 
                                                FROM Base_Fee_Confi__mdt order by Low__c asc limit 1000];
        
        //Query Cpi
        Consumer_Price_Index_Configuration__mdt cpiObj = [SELECT CPI__c, Previous_CPI__c 
                                                          FROM Consumer_Price_Index_Configuration__mdt 
                                                          WHERE DeveloperName = 'Consumer_Price_Index' limit 1];
        
        //Recalculate Auth Fee Only if the Annual BSP Count and Annual TSP Count are edited  
        for(String Id : newOrderItems.keySet()) {
            
            if(newOrderItems.get(Id).Summation_Of_BSP_TSP_Count__c != oldOrderItems.get(Id).Summation_Of_BSP_TSP_Count__c ) {
                
                Decimal baseFee = getBaseFee(newOrderItems.get(Id).Summation_Of_BSP_TSP_Count__c, baseFeelst);
                
                //Authorization Fee (F) = Base Fee (F) x ( Current CPI (A)/ Previous CPI (B))
                newOrderItems.get(Id).UnitPrice = baseFee * (cpiObj.CPI__c/cpiObj.Previous_CPI__c); 
            }
        }
        
    }
    
   public Decimal getBaseFee(Decimal totalTripCount, list<Base_Fee_Confi__mdt> baseFeelst){
    	
    	Decimal baseFee = 0;
    	for(Base_Fee_Confi__mdt bsFeeObj : baseFeelst){
    		   		
    		if(totalTripCount >= bsFeeObj.Low__c && totalTripCount <= bsFeeObj.High__c){
    			return bsFeeObj.Base_Fee__c;
    		}
    		baseFee = bsFeeObj.Base_Fee__c;
    	}
    	return baseFee;
    }
}