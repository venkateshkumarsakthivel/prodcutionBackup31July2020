public class QBFileFooter {
	
    public String recordType {get;set;} { this.recordType = '9';}    // length 1
    public String fileBatchCount {get; set;} { this.fileBatchCount = '02';} // length 2
    public String fileTxnCount {get; set;} { this.fileTxnCount = '';} // length 8 
    public String fileTxnAmount {get;set;} { this.fileTxnAmount = '';} // length 12
    public String communityCode {get;set;} { this.communityCode = '';} // length 10
    public String clientName {get;set;} { this.clientName = '';} // length 30
    public String uniqueFileIdentifier {get;set;} { this.uniqueFileIdentifier = '';} // length 30
    public String filler {get;set;} { this.filler = ''; this.filler = this.filler.rightpad(167,'');} // length 167
    
    public QBFileFooter(Integer batchCount, Integer txnCount, Decimal txnAmount, String commCode, String cName, String uniqueFileId) {
        this.fileBatchCount = String.valueOf(batchCount);
        this.fileTxnCount = String.valueOf(txnCount);
        this.fileTxnAmount = String.valueOf((txnAmount*100).intValue());
        this.communityCode = commCode;
        this.clientName = cName;
        this.uniqueFileIdentifier = uniqueFileId;
    }
    override public String toString()  {
        String header = '';
        header += this.recordType;
        header += this.fileBatchCount.leftPad(2, '0');
        header += this.fileTxnCount.leftPad(8, '0');
        header += this.fileTxnAmount.leftPad(12,'0');
        header += this.communityCode.rightPad(10, '');
        header += this.clientName.rightPad(30, '');
        header += this.uniqueFileIdentifier.rightPad(30,'');
        header += this.filler;
        header += '\r\n';
        return header;
    }   
}