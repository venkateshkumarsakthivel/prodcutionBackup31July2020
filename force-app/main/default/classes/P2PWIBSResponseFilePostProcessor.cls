/** queueable interface to process deletion of processed files */
public with sharing class P2PWIBSResponseFilePostProcessor implements Queueable, Database.AllowsCallouts {
    private List<P2PWIBSResponseFileProcessor> processors;
    
    public P2PWIBSResponseFilePostProcessor(List<P2PWIBSResponseFileProcessor> processors)  {
    		this.processors = processors;
    }
    
    public void execute(QueueableContext queueableContext)  {
		P2PWIBSClient.WIBSRequestParam wibsRequestParameters;

		for (P2PWIBSResponseFileProcessor processor : this.processors)  {
			if(processor.success)  {
				wibsRequestParameters = new P2PWIBSClient.WIBSRequestParam();
				wibsRequestParameters.fileName = processor.name;
				P2PWIBSClient wibsClient = new P2PWIBSClient();
				System.debug(' file deletion : ' + processor.name);
				wibsClient.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDELETE, null, wibsRequestParameters);				
			}

		}
    }
    
}