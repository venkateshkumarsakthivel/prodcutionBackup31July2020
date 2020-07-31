public class QBBatchFooter {
	
    public String recordType {get;set;} { this .recordType = '7';}
    public String batchTxnCount {get;set;} // length 6
    public String batchTxnAmount {get;set;} // length 10
    public String companyCode {get;set;} // length 10
    public String uniqueBatchId {get;set;} //should be same as batch header, lenght 15
    public String filler {get;set;} { this.filler = ''; this.filler = this.filler.rightpad(208,'');}
    
    public QBBatchFooter(Integer batchtxnCount, Decimal batchTxnAmount, String companyCode, String uniqueBatchId) {
        this.batchtxnCount = String.valueOf((batchTxnCount));
        this.batchTxnAmount = String.valueOf((batchTxnAmount * 100).intValue());
        this.companyCode = companyCode;
        this.uniqueBatchId = uniqueBatchId;
    }
    
    override public String toString() {
        String header = '';
        header += this.recordType;
        header += this.batchTxnCount.leftPad(6,'0');
        header += this.batchTxnAmount.leftPad(10,'0');
        header += this.companyCode.rightPad(10, '');
        header += this.uniqueBatchId.rightPad(15, '');
        header += this.filler;
        header += '\r\n';
        return header;
    }
}