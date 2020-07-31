/**
* 
*/
global with sharing class P2POSRUpdatePRBatchable  implements Database.Batchable<P2POSRRequestParameter>, Database.Stateful, Database.AllowsCallouts  {
 
    public List<P2POSRAuthorisationResponseParserVisitor> p2POSRAuthorisationResponseParserVisitors { get; private set; } 
 
    public P2POSRUpdatePRBatchable(){
        this.p2POSRAuthorisationResponseParserVisitors = new List<P2POSRAuthorisationResponseParserVisitor>();
    }
    
    global Iterable<P2POSRRequestParameter> start(Database.BatchableContext batchableContext)  {
        return new P2POSRFacade().updateProviderRequestParameters();
    }
    
    /** perform DMLs based on status and response data available in each of response visitor for OSR requests. */
    global void finish(Database.BatchableContext batchableContext) {
        Map<String, Sobject> updateOrInserts = null;
        List<Sobject> updates = new List<Sobject>();
        List<Sobject> inserts = new List<Sobject>();
        for(P2POSRAuthorisationResponseParserVisitor visitor : this.p2POSRAuthorisationResponseParserVisitors)  {
            updateOrInserts = visitor.finalize();
            if(null != updateOrInserts)  {
                updates.add(updateOrInserts.get('tpr'));
                inserts.add(updateOrInserts.get('al'));
            }
        }
        
        Database.insert(inserts, false); 
        Database.update(updates, false);
    }
    
    private static P2POSRClient.OSR_REQUEST_TYPE type()  {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<P2POSRRequestParameter> scope)  {
        P2POSRAuthorisationResponseParserVisitor visitor;
        P2POSRClient p2POSRClient = new P2POSRClient();
        for(P2POSRRequestParameter p2POSRRequestParameter : scope)  {
            System.debug(p2POSRRequestParameter);
            visitor = new P2POSRAuthorisationResponseParserVisitor();
            p2POSRClient = new P2POSRClient();
            p2POSRClient.call(P2POSRUpdatePRBatchable.type(), visitor, p2POSRRequestParameter);
            this.p2POSRAuthorisationResponseParserVisitors.add(visitor);
        }
    }
}