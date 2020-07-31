/*
 * Helper class to update condition type on authorisations
 */
public with sharing class ConditionTypeIdentifier {
    private List<Condition__c> conditions;
    
    public ConditionTypeIdentifier(List<Condition__c> conditions){
        if(conditions == null ){
            throw new InvalidDataException('Failed to identify condition type. ' 
                + 'Condition details missing.');
        }
        this.conditions = conditions;
    }
    
    public void identify(){
        Map<Id, Authorisation__c> authorisationsToUpdate = new Map<Id,Authorisation__c>();
        for(Condition__c condition : conditions) {
            authorisationsToUpdate.put(condition.Authority__c, 
                    new Authorisation__c(Id = condition.Authority__c, 
                        Condition_Type__c = GlobalConstants.UNCONDITIONAL_AUTHORISATION));
        }
        
        //retrieve authorisations with condition
        List<AggregateResult> agResults = [ SELECT Count(Id) conditionCount, Authority__c authId
                                            FROM Condition__c
                                            WHERE Id IN :conditions
                                            GROUP By Authority__c];
        for(AggregateResult result : agResults){
            authorisationsToUpdate.put((Id)result.get('authId'), 
                    new Authorisation__c(Id = (Id)result.get('authId'), 
                        Condition_Type__c = GlobalConstants.CONDITIONAL_AUTHORISATION));
        }
        
        update authorisationsToUpdate.values();
    }
    
    public class InvalidDataException extends Exception {}
}