public class QBTransaction {
	
    public String recordType {get; set;} { this.recordType = '5';}
    public String filler1 { get; set; } { this.filler1 = ''; this.filler1 = this.filler1.rightpad(2,'');}
    public String bsbORexpDate { get; set; } { this.bsbORexpDate = ''; this.bsbORexpDate = this.bsbORexpDate.rightpad(8,'0');}
    public String accountNumber { get; set; } { this.accountNumber = ''; } 
    public String amount { get; set; } { this.amount = ''; }
    public String customerNumber { get; set; } { this.customerNumber = '';}
    public String customerName { get; set; } { this.customerName = '';}
    public String txnNumber { get; set; } { this.txnNumber = '';}
    public String captureTxnNumber { get; set; } { this.captureTxnNumber = ''; this.captureTxnNumber = this.captureTxnNumber.rightpad(15,''); }
    public String authId { get; set; } { this.authId = ''; this.authId = this.authId.rightpad(6,'');}
    public String electronicCommerceIndicator { get; set; } { this.electronicCommerceIndicator = ''; this.electronicCommerceIndicator = this.electronicCommerceIndicator.rightpad(3,'');}
    public String filler2 { get; set; } { this.filler2 = ''; this.filler2 = this.filler2.rightpad(136,''); }
    
    public QBTransaction(String pregisteredToken, Decimal pamount, String orderNumber  ) {
        this.accountNumber = pregisteredToken.rightpad(17,'');
		this.amount = String.valueOf((pamount * 100).intValue()); 
        this.customerNumber = this.customerNumber.leftPad(15,'');
    	this.customerName = this.customerName.leftPad(22,'');
        this.txnNumber = orderNumber.rightpad(15,'');
    }
	
    override public String toString() {
        String header = '';
        header += this.recordType;
        header += this.filler1;
        header += this.bsbORexpDate;
        header += this.accountNumber;
        header += this.amount.leftPad(10, '0');
        header += this.customerNumber;
        header += this.customerName;
        header += this.txnNumber;
        header += this.captureTxnNumber;
        header += this.authId;
        header += this.electronicCommerceIndicator;
        header += this.filler2;
        header += '\r\n';
        return header;
    }
    
}