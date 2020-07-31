public with sharing class QBFileHeader {
    
	public String recordType { get; private set; } { this.recordType = '1'; } /* length: 1 */
    public String communityCode { get; private set; }  /* lenght 10 */
    public String fileCreationDate { get; set; } /* length: 8, format: YYYYMMDD */
    public String fileCreationTime { get; set; } { this.fileCreationTime = DateTime.now().format('HHMM'); } /* length: 4, format: HHMM */
    public String clientName { get; set; }  /* lenght 30 */
    public String uniqueFileId { get; set; } { this.uniqueFileId = String.valueOf(system.now()).remove(':').remove(' ').remove('-'); this.uniqueFileId = this.uniqueFileId.rightPad(20,'');}
    public String filler { get; set; } { this.filler = ''; this.filler = this.filler.rightPad(177,'');}
    
    public QBFileHeader()  {
        //get from Custom Metadata and populate required header attributes here and finally call generate method
        
        WIBS_Configuration__mdt qbConstantsMeta = [SELECT Label, nameOfUserSupplyingFile__c, qvalent_communityCode__c
												   FROM WIBS_Configuration__mdt 
                                                   WHERE DeveloperName = 'QB_Constants'];
        this.communityCode = qbConstantsMeta.qvalent_communityCode__c;
        this.clientName = qbConstantsMeta.nameOfUserSupplyingFile__c;
        
		Date dateToday = Date.today();
        String sMonth = String.valueof(dateToday.month());
        String sDay = String.valueof(dateToday.day());
        if(sMonth.length()==1){
          sMonth = '0' + sMonth;
        }
        if(sDay.length()==1){
          sDay = '0' + sDay;
        }
        this.fileCreationDate = String.valueof(dateToday.year()) + sMonth + sDay;
    }
    
    override public String toString()  {
        String header = '';
        header += this.recordType;
        header += this.communityCode.rightPad(10, '');
        header += this.fileCreationDate;
        header += this.fileCreationTime;
        header += this.clientName.rightPad(30, '');
        header += this.uniqueFileId;
        header += this.filler;
        header += '\r\n';
        return header;
    }
}