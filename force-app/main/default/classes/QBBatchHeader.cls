public class QBBatchHeader {
	
    public String recordType { get; private set; } { this.recordType = '3'; } /* length: 1 */
    public String companyName { get; private set; }    /* lenght 30 */
    public String communityCode { get; private set; }  /* lenght 10 */
    public String batchType { get; set; } /* CC or DD */
    public String batchDescription { get; set; } { this.batchDescription = DateTime.now().format('ddmm'); } /* length: 18 */
    public String uniqueBatchId { get; set; } { this.uniqueBatchId = generateRandomString(8)+DateTime.now().format('HHMMSS'); this.uniqueBatchId = this.uniqueBatchId.rightPad(15,'');}
    public String refundFlag { get; set; } { this.refundFlag = ' ';}
    public String txnCurrency { get; set; } { this.txnCurrency = 'AUD';}
    public String filler { get; set; } { this.filler = ''; this.filler = this.filler.rightPad(170,'');}
    
    public QBBatchHeader(String batchType) {
        WIBS_Configuration__mdt qbConstantsMeta = [SELECT Label, nameOfUserSupplyingFile__c, qvalent_supplierBusinessCode__c
												   FROM WIBS_Configuration__mdt 
                                                   WHERE DeveloperName = 'QB_Constants'];
        this.companyName = qbConstantsMeta.nameOfUserSupplyingFile__c;
        this.communityCode = qbConstantsMeta.qvalent_supplierBusinessCode__c;
        this.batchType = batchType;
		this.batchDescription = 'Batch '+this.batchDescription;
        
    }
    
    override public String toString()  {
        String header = '';
        header += this.recordType;
        header += this.companyName.rightPad(30, '');
        header += this.communityCode.rightPad(10, '');
        header += this.batchType;
        header += this.batchDescription.rightPad(18, '');
        header += this.uniqueBatchId.rightPad(15, '');
        header += this.refundFlag;
        header += this.txnCurrency;
        header += this.filler;
        header += '\r\n';
        return header;
    }    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
	}
}