public with sharing class P2PRMSOvtResponseParserVisitor implements AWSC_ResponseParserVisitor{

    private List<Case> toBeUpdateCaseList;

    public String requestParameters { get; set; }
   	
   	public P2PRMSOvtResponseParserVisitor(){
        toBeUpdateCaseList = new List<Case>();
    }

    private void addCase(Case caseInstance){ 
    	if(caseInstance != null && caseInstance.id != null) 
    	toBeUpdateCaseList.add(caseInstance); 
    }
    
    public void visit(AWSC_ResponseParser responseParser){
        System.debug('Visitor: Adding Case to list for bulk updates ');
        P2PRMSOvtResponseParser p2pOvtResponseParser = (P2PRMSOvtResponseParser)responseParser;
            
        Case caseInstance = p2pOvtResponseParser.getUpdatedCase();
        addCase(caseInstance);

        system.debug('---=p2pOvtResponseParser.getOriginal().getRequestParameters()======'+p2pOvtResponseParser.getOriginal().getRequestParameters());

        this.requestParameters = String.valueOf(p2pOvtResponseParser.getOriginal().getRequestParameters());
     
    }
        
    public void updateResponses() {
        System.debug('toBeUpdateCaseList: '+toBeUpdateCaseList);
        try{
            if(!toBeUpdateCaseList.isEmpty()) {
                update toBeUpdateCaseList;
            }
            System.debug('Visitor: Bulk updated Case'+toBeUpdateCaseList);

            ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                applicationLogMessage.debugLevel = GlobalConstants.INFO; 
                //applicationLogMessage.payload = requestParameters.get(p2POSRAssessmentResponse.levyAssessmentID);
                applicationLogMEssage.logCode = 'RMS Criminal Charge Correction Request Parameters';
                applicationLogMessage.logMessage = requestParameters + ', Status='+ Label.RMS_Overturn_Status; 
                applicationLogMessage.source = 'P2PRMSOvtResponseParserVisitor '; 
                applicationLogMessage.sourceFunction = 'updateResponses';
                //logList.add(applicationLogMessage);
                 ApplicationLogUtility.logMessage(applicationLogMessage);
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage('Error','P2PRMSOvtResponseParserVisitor','updateResponses',ex.getMessage(),ex);
        }
    }
}